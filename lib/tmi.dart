library tmi_dart;

import 'dart:async';
import 'dart:math';

import 'package:logger/logger.dart';
import './src/monitor.dart';
import 'src/websock/io.dart';
import 'package:eventify/eventify.dart';

import 'src/commands/command.dart';
import 'src/commands/ping.dart';
import 'src/commands/pong.dart';
import 'src/message.dart';
import 'src/utils.dart' as _;

/// Stores the clientID and debug mode for the tmi client.
///
/// The [clientID] property is the client ID given from Twitch. Default is ''.
///
/// The [debug] property is if debug logging should be printed. Default is
/// false.
class Options {
  final String clientID;
  final bool debug;

  /// Creates an [Options] object for the tmi client.
  /// Both [clientID] and [debug] are named optional parameters.
  Options({this.clientID = '', this.debug = false});
}

/// Stores the connection information for the tmi client.
///
/// The [server] property is the server domain of the connection.
/// Does not include the protocol or port. Default is 'irc-ws.chat.twitch.tv'.
///
/// The [port] property is the port number of the connection. Default is 433 if
/// secure is true, otherwise 80 if false.
///
/// The [reconnect] property is if the connection should reconnect. This changes
/// to false on unsuccessful authentication. Default is false.
///
/// The [maxReconnectAttempts] property is the maximum number of reconnection
/// attempts. Default is 2^53.
///
/// The [maxReconnectInterval] property is the maxmimum reconnect interval in
/// seconds. Default is 3000 seconds.
///
/// The [reconnectDecay] property is the reconnect intecrval decay/backing off
/// factor. Default is 1.5.
///
/// The [reconnectBaseInterval] property is the starting reconnect interval in
/// seconds. Default is 1.0.
///
/// The [reconnectCurrentInterval] property is the current reconnect interval in
/// seconds. Initially set to reconnectBaseInterval on a connection.
///
/// The [secure] property is if the connection should use SSL. Default is true.
///
/// The [timeout] property is the Duration to wait before checking if 'PONG' was
/// recieved after a 'PING' was sent. This must be less than 60 seconds.
/// Default is 10 seconds.
class Connection {
  final String server;
  late int port;
  bool reconnect;
  final int maxReconnectAttempts;
  final double maxReconnectInterval;
  final double reconnectDecay;
  final double reconnectBaseInterval;
  double reconnectCurrentInterval;
  final bool secure;
  final Duration timeout;

  /// Creates a [Connection] object for the tmi client.
  /// All named parameters are optional. The [timeout] parameter must be less
  /// than 60 seconds.
  Connection(
      {this.server = 'irc-ws.chat.twitch.tv',
      this.port = 443,
      this.reconnect = false,
      this.maxReconnectAttempts = 9007199254740992,
      this.maxReconnectInterval = 30000,
      this.reconnectDecay = 1.5,
      this.reconnectBaseInterval = 1.0,
      this.secure = true})
      : timeout = Duration(seconds: 10),
        reconnectCurrentInterval = reconnectBaseInterval {
    // Ensure timeout is less than 60 seconds
    assert(timeout.inMilliseconds < 60000);
    if (secure == false) {
      port = 80; // Override port to 80 if not secure
    }
  }
}

/// Stores the tmi client identity information.
///
/// The [username] property is the username of the client. This may change if
/// the username recieved from the IRC welcome message (code 001) is different.
///
/// The [oauthToken] property is the OAuth token for the given username.
class Identity {
  String username;
  final String oauthToken;

  /// Creates an [Identity] object for the tmi client. The first parameter is
  /// the [username], the second is the [oauthToken]. Both are required.
  Identity(this.username, this.oauthToken);
}

/// The tmi client.
///
/// The [channels] property is the channels that the client initially connected
/// to.
///
/// The [options] property is the options values for the tmi client.
///
/// The [connection] property is the connection values for the tmi client.
///
/// The [identity] property is the identity values for the tmi client.
///
/// The [currentLatency] property is the current latency of the connection
/// in milliseconds. This is calculated based on the time to recieve 'PONG'
/// after 'PING' was sent.
///
/// The [latency] property is the time the 'PING' was sent, used to
/// calculate [currentLatency].
///
/// The [globaluserstate] property is the given global user state from Twitch
/// after connecting.
///
/// The [userstate] property is the current user state from Twitch.
///
/// The [lastJoined] property is the name of the last joined channel.
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

  final IOWebsock _sok;
  late Monitor _monitor;

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

  /// The constructor for the tmi client. The [channels] paramter is required.
  /// The [options] parameter should be a [Options] object. The [connection]
  /// parameter should be a [Connection] object. The [identity] parameter should
  /// be a [Identity] object.
  Client({
    required this.channels,
    options,
    connection,
    identity,
  })  : options = options ?? Options(),
        connection = connection ?? Connection(),
        identity = identity ?? Identity(_.justinfan(), ''),
        _sok =
            IOWebsock(host: 'irc-ws.chat.twitch.tv', tls: connection.secure) {
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
    connection.reconnectCurrentInterval *= connection.reconnectDecay;
    if (connection.reconnectCurrentInterval > connection.maxReconnectInterval) {
      connection.reconnectCurrentInterval = connection.maxReconnectInterval;
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

  void _attemptReconnect() {
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
        log.d('Reconnecting in ${connection.reconnectCurrentInterval}s');
      }
      // Calc connection delay with random jitter
      var connectionDelay = connection.reconnectCurrentInterval * 1000 +
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
      _attemptReconnect();
    }
    _sok == null;
  }

  void _onError(dynamic error) {
    log.e(error);
    cancelMonitor();
    reason = !_sok.isActive ? 'Connection closed.' : 'Unable to connect.';

    emit('disconnected', [reason]);
    emit('_promiseConnect', [reason]);

    _attemptReconnect();
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

  bool get isConnected => _sok.isActive;

  void _onOpen() async {
    if (!isConnected) return;

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
                'Recieved RECONNECT request from Twitch. Disconnecting and reconnecting in ${connection.reconnectCurrentInterval}s');
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
