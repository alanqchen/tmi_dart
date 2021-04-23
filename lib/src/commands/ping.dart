import 'package:logger/src/logger.dart';
import '../message.dart';
import '../../tmi.dart';

import 'command.dart';

class Ping extends Command {
  Ping(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    client.emit('ping');
    if (client.isConnected) {
      client.send('PONG');
    }
  }
}
