import 'package:logger/src/logger.dart';
import '../../message.dart';
import '../../../tmi.dart';

import '../command.dart';

class Username extends Command {
  Username(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    client.identity.username = message.params[0];
  }
}
