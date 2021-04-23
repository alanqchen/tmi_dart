library tmidart;

import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:http/testing.dart';
import 'package:logger/logger.dart';
import './src/monitor.dart';
import 'src/websok/io.dart';
import 'package:eventify/eventify.dart';
import 'package:quiver/async.dart';

import 'src/commands/command.dart';
import 'src/commands/ping.dart';
import 'src/commands/pong.dart';
import 'src/message.dart';
import 'src/utils.dart' as _;

class Options {
  String clientID;
  bool debug;

  Options({this.clientID = '', this.debug = false});
}

class Connection {
  String server;
  int port;
  bool reconnect;
  int maxReconnectAttempts; // Default 2^53
  double maxReconnectInterval;
  double reconnectDecay;
  double reconnectInterval;
  double reconnectTimeInterval;
  bool secure;
  Duration timeout;

  Connection(
      {this.server = 'irc-ws.chat.twitch.tv',
      this.port = 80,
      this.reconnect = false,
      this.maxReconnectAttempts = 9007199254740992,
      this.maxReconnectInterval = 30000,
      this.reconnectDecay = 1.5,
      this.reconnectInterval = 1.0,
      this.secure = false})
      : timeout = Duration(seconds: 10),
        reconnectTimeInterval = reconnectInterval {
    if (secure = true) {
      port = 443; // Override port to 443 if secure
    }
  }
}

class Identity {
  String username;
  String oauthToken;

  Identity(this.username, this.oauthToken);
}

class Client {
  // max jitter
  static const RECONNECT_JITTER = 100;
  // random generator for jitter
  static var random = Random();
  var log = Logger(
    printer: PrettyPrinter(),
  );

  final List<String> channels;
  final EventEmitter emitter = EventEmitter();

  final IOWebsok _sok;
  late Monitor _monitor;

  // Optional properties
  Options options;
  Connection connection;
  Identity identity;

  int currentLatency = 0;
  DateTime latency = DateTime.now();
  late Map<String, dynamic> globaluserstate;
  Map<String, dynamic> userstate = {};
  String lastJoined = '';
  Map<String, List<String>> moderators = {};
  String emotes = '';
  Map<String, String> emotesets = {};
  bool wasCloseCalled = false;
  String reason = '';

  int reconnections = 0;
  bool reconnecting = false;
  bool alreadyConnected = false;

  late Map<String, Command> twitchCommands;
  late Map<String, Command> noScopeCommands;
  late Map<String, Command> userCommands;

  Client({
    this.channels = const [],
    options,
    connection,
    identity,
  })  : options = options ?? Options(),
        connection = connection ?? Connection(),
        identity = identity ?? Identity(_.justinfan(), ''),
        _sok = IOWebsok(host: 'irc-ws.chat.twitch.tv', tls: connection.secure) {
    noScopeCommands = {
      'PING': Ping(this, log),
      'PONG': Pong(this, log),
    };

    twitchCommands = {
      '001': Username(this, log),
      '002': NoOp(this, log),
      '003': NoOp(this, log),
      '004': NoOp(this, log),
      '372': NoOp(this, log),
      '375': NoOp(this, log),
      'CAP': NoOp(this, log),
      '376': Connected(this, log),
      'CLEARCHAT': ClearChat(this, log),
      'CLEARMSG': ClearMsg(this, log),
      'HOSTTARGET': HostTarget(this, log),
      'NOTICE': Notice(this, log),
      'ROOMSTATE': RoomState(this, log),
      'USERNOTICE': UserNotice(this, log),
      'USERSTATE': UserState(this, log),
      // NOT USED 'SERVERCHANGE': NoOp(this, log),
      'GLOBALUSERSTATE': GlobalUserState(this, log),
    };

    userCommands = {
      'JOIN': Join(this, log),
      'PART': Part(this, log),
      'WHISPER': Whisper(this, log),
      'PRIVMSG': PrivMsg(this, log),
      '366': NoOp(this, log),
      '353': Names(this, log),
    };

    _monitor = Monitor(this);
  }

  void connect() {
    // Add reconnect decay and clamp if exceeds max
    connection.reconnectTimeInterval *= connection.reconnectDecay;
    if (connection.reconnectTimeInterval > connection.maxReconnectInterval) {
      connection.reconnectTimeInterval = connection.maxReconnectInterval;
    }

    _sok.connect();
    _sok.listen(onData: _onData, onError: _onError, onDone: _onDone);
    _onOpen();
  }

  void close() {
    _sok.close().catchError((err) {
      if (options.debug) {
        log.e('ERROR: failed to close socket: $err');
      }
    });
    wasCloseCalled = true;
  }

  void closeTimeout() {
    _sok.close().catchError((err) {
      if (options.debug) {
        log.e('ERROR: failed to close socket: $err');
      }
    });
    wasCloseCalled = false;
  }

  void startMonitor() {
    _monitor.loop(_sok);
  }

  void cancelMonitor() {
    if (_monitor.pingLoop != null) {
      _monitor.pingLoop?.cancel();
    }
    if (_monitor.pingTimeout != null) {
      _monitor.pingTimeout?.cancel();
    }
  }

  void attemptReconnect() {
    if (connection.reconnect &&
        reconnections >= connection.maxReconnectAttempts) {
      emit('maxreconnect');
      if (options.debug) log.w('Maximum reconnection attempts reached.');
    }
    if (connection.reconnect &&
        !reconnecting &&
        reconnections < connection.maxReconnectAttempts) {
      reconnecting = true;
      reconnections++;
      if (options.debug) {
        log.d('Reconnecting in ${connection.reconnectTimeInterval}s');
      }
      // Calc connection delay with random jitter
      var connectionDelay = connection.reconnectTimeInterval * 1000 +
          random.nextInt(RECONNECT_JITTER);
      Timer(Duration(milliseconds: connectionDelay.round()), () {
        reconnecting = false;
        connect();
      });
    }
  }

  void _onDone() {
    log.d('Websocket connection done');
    cancelMonitor();
    if (wasCloseCalled) {
      wasCloseCalled = false;
      reason = 'Connection closed.';
      emits([
        '_promiseConnect',
        '_promiseDisconnect',
        'disconnected'
      ], [
        [reason],
        [],
        [reason]
      ]);
    } else {
      log.d('reconecting...');
      emit('_promiseConnect', [reason]);
      emit('disconnected', [reason]);
      attemptReconnect();
    }
    _sok == null;
  }

  void _onError(dynamic error) {
    log.e(error);
    cancelMonitor();
    reason = !_sok.isActive ? 'Connection closed.' : 'Unable to connect.';

    emit('disconnected', [reason]);
    emit('_promiseConnect', [reason]);

    attemptReconnect();
  }

  Listener on(String event, Function f) {
    return emitter.on(event, this, (ev, context) {
      var params = ev.eventData as List;
      switch (params.length) {
        case 0:
          f();
          break;
        case 1:
          f(params[0]);
          break;
        case 2:
          f(params[0], params[1]);
          break;
        case 3:
          f(params[0], params[1], params[2]);
          break;
        case 4:
          f(params[0], params[1], params[2], params[3]);
          break;
        case 5:
          f(params[0], params[1], params[2], params[3], params[4]);
          break;
        case 6:
          f(params[0], params[1], params[2], params[3], params[4], params[5]);
          break;
        default:
          throw Exception('Got more params that I can handle');
      }
    });
  }

  void send(String command) {
    if (isConnected) {
      _sok.send(command);
    }
  }

  bool get isConnected => _sok != null && _sok.isActive;

  void _onOpen() async {
    if ((_sok == null) || !_sok.isActive) return;

    log.d('Openning connection');

    emit('connecting');

    // get token for the user name
    // generate password from token
    if (options.debug) {
      log.d('Sending authentication to server..');
    }

    // Authentication
    _sok.send(
      'CAP REQ :twitch.tv/tags twitch.tv/commands twitch.tv/membership',
    );
    if (!_.isJustinfan(identity.username)) {
      _sok.send('PASS ${identity.oauthToken}');
    }
    _sok.send('NICK ${identity.username}');
  }

  void _onData(dynamic event) {
    var parts = (event as String).split('\r\n');

    parts.where((part) => part != null && part.isNotEmpty).forEach((part) {
      var msg = Message.parse(part);
      if (msg == null) return;
      _handleMessage(msg);
    });
  }

  void _handleMessage(Message message) {
    // Check if there's any listeners for the raw_message event
    if (emitter.getListenersCount('raw_message') > 0) {
      emit('raw_message', [message]);
    }

    var msgid = message.tags['msg-id'];

    // Parse badges, badge-info and emotes..
    message.tags.addAll(_.badges(_.badgeInfo(_.emotes(message.tags))));

    // Transform IRCv3 tags..
    if (message.tags.isNotEmpty) {
      var tags = message.tags;
      for (var key in tags.keys) {
        if (!['emote-sets', 'ban-duration', 'bits'].contains(key)) {
          dynamic value = tags[key];
          if (value.runtimeType == bool) {
            value = null;
          } else if (value == '1') {
            value = true;
          } else if (value == '0') {
            value = false;
          } else if (value.runtimeType == String) {
            value = _.unescapeIRC(value);
          }
          tags[key] = value;
        }
      }
    }

    // Messages with no prefix..
    if (message.prefix.isEmpty) {
      if (noScopeCommands.containsKey(message.command)) {
        noScopeCommands[message.command]!.call(message);
      } else {
        log.w('Could not parse message with no prefix:\n${message.raw}');
      }
    } else if (message.prefix == 'tmi.twitch.tv') {
      // Messages with 'tmi.twitch.tv' as a prefix..
      switch (message.command) {
        // https://github.com/justintv/Twitch-API/blob/master/chat/capabilities.md#notice
        // Received a reconnection request from the server..
        case 'RECONNECT':
          if (options.debug) {
            log.d(
                'Recieved RECONNECT request from Twitch. Disconnecting and reconnecting in ${connection.reconnectTimeInterval}s');
            close();
            reconnecting = true;
            Timer(
                Duration(
                    milliseconds:
                        (connection.maxReconnectInterval * 1000).round()), () {
              reconnecting = false;
              connect();
            });
          }
          break;
        // Wrong cluster..
        default:
          if (twitchCommands.containsKey(message.command)) {
            var command = twitchCommands[message.command];
            command?.call(message);
          } else {
            log.e(
              'Could not parse message from tmi.twitch.tv:\n${message.raw}',
            );
          }
          break;
      }
    } else if (message.prefix == 'jtv') {
      // Messages from jtv..
      var unparsedChannel = _.get(message.params, 0);
      if (unparsedChannel == null) {
        log.w('Failed to get channel name');
        return;
      }
      var channel = _.channel(unparsedChannel);
      var msg = _.get(message.params, 1);
      switch (message.command) {
        case 'MODE':
          if (msg == '+o') {
            // Add username to the moderators..
            if (!moderators.containsKey(channel)) {
              // ignore: unnecessary_statements
              moderators[channel] == [];
            }
            if (!moderators[channel]!.contains(message.params[2])) {
              moderators[channel]!.add(message.params[2]);
            }
            emit('mod', [channel, message.params[2]]);
          } else if (msg == '-o') {
            // Remove username to the moderators..
            if (!moderators.containsKey(channel)) {
              // ignore: unnecessary_statements
              moderators[channel] == [];
            }
            moderators[channel]!
                .removeWhere((username) => username == message.params[2]);
            emit('unmod', [channel, message.params[2]]);
          }
          break;
        default:
          log.e('Could not parse message from jtv:\n${message.raw}');
          break;
      }
    } // Anything else..
    else {
      if (userCommands.containsKey(message.command)) {
        userCommands[message.command]!.call(message);
      } else {
        log.e('COMMAND ${message.command} not yet implemented');
      }
    }
  }

  int getPromiseDelay() {
    return currentLatency <= 600 ? 600 : currentLatency + 100;
  }

  Future<bool> sendCommand(String? channel, String command) async {
    if (!isConnected) {
      if (options.debug) {
        log.w('Can\'t send command, no connection established.');
      }
      return false;
    }

    // Executing a command on a channel..
    if (channel != null && channel.isNotEmpty) {
      var chan = _.channel(channel);
      log.d('[${chan}] Executing command: ${command}');
      _sok.send('PRIVMSG ${chan} :${command}');

      var channelUserstate = {};
      if (userstate.containsKey(chan)) {
        channelUserstate = userstate[chan];
      }
      // Send emit
      if (command.startsWith('/me ')) {
        channelUserstate['message-type'] = 'action';
        emit('action',
            [chan, channelUserstate, command.replaceFirst('/me ', ''), true]);
        emit('message',
            [chan, channelUserstate, command.replaceFirst('/me ', ''), true]);
      } else {
        channelUserstate['message-type'] = 'chat';
        emit('chat', [chan, channelUserstate, command, true]);
        emit('message', [chan, channelUserstate, command, true]);
      }
    } else {
      // Executing a raw command..
      log.d('Executing command: ${command}');
      _sok.send(command);
    }
    return true;
  }

  void emits(List<String> types, List values) {
    for (var i = 0; i < types.length; i++) {
      var val = i < values.length ? values[i] : values[values.length - 1];
      emit(types[i], val);
    }
  }

  void emit(String type, [List? params]) {
    emitter.emit(type, null, params);
  }
}
