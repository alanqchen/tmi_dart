import 'dart:async';

import 'package:logger/logger.dart';
import '../command.dart';
import '../../message.dart';
import '../../../tmi.dart';
import '../../utils.dart' as utils;

class Connected extends Command {
  Connected(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    client
        .emit('connected', [client.connection.server, client.connection.port]);
    client.emit('_promiseConnect', ['connected']);
    client.startMonitor();

    client.reconnections = 0;
    client.connection.reconnectCurrentInterval =
        client.connection.reconnectBaseInterval;

    for (var channel in client.channels) {
      _join(channel);
    }
  }

  Future _join(String channel) async {
    channel = utils.channel(channel);

    await client.sendCommand(null, 'JOIN $channel');

    var hasFulfilled = false;
    if (!client.alreadyConnected) {
      if (client.debug) log.i('Joining...');
      client.on('_promiseJoin', (error, joinedChannel) {
        if (channel == utils.channel(joinedChannel)) {
          hasFulfilled = true;
          client.emitter.removeListener('_promiseJoin', (event, object) {});
          //client.log.i('JOINED!');
          client.alreadyConnected = true;
        }
      });
      Timer(Duration(milliseconds: client.getPromiseDelay()), () {
        if (!hasFulfilled) {
          client.emit('_promiseJoin', ['No response from Twitch.', channel]);
        }
      });
    }

    // TODO: Race timeout and return future
    //Future.delayed(Duration(seconds: 10))
    //.then((value) => if (!hasFulfilled) return false);
  }
}
