import 'package:logger/logger.dart';
import '../../src/message.dart';
import '../../tmi.dart';

import 'command.dart';

class NoOp extends Command {
  NoOp(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    // No-op
  }
}
