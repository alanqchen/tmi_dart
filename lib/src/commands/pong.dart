import 'package:logger/src/logger.dart';
import '../../src/message.dart';
import '../../tmi.dart';

import 'command.dart';

class Pong extends Command {
  Pong(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var currDate = DateTime.now();
    client.currentLatency = (currDate.millisecondsSinceEpoch -
        client.latency.millisecondsSinceEpoch);
    client.emit('pong', [client.currentLatency]);
    client.emit('_promisePing');
  }
}
