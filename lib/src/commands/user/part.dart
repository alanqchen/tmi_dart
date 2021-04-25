import 'package:logger/src/logger.dart';
import '../../message.dart';
import '../../../tmi.dart';
import '../../utils.dart' as _;

import '../command.dart';

class Part extends Command {
  Part(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);
    var isSelf = false;
    var nick = message.prefix.split('!')[0];

    // Client left a channel..
    if (client.identity.username == nick) {
      isSelf = true;
      // Check if the channel is in the userstate map, remove it if it is
      if (client.userstate[channel] != null) {
        client.userstate.remove(channel);
      }

      // Remove channel from channels list
      client.channels.remove(channel);

      client.emit('_promisePart');
    }

    // Client or someone else left the channel, emit the part event..
    client.emit('part', [channel, nick, isSelf]);
  }
}
