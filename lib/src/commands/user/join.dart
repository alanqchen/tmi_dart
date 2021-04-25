import 'package:logger/src/logger.dart';
import '../../message.dart';
import '../../../tmi.dart';
import '../../utils.dart' as _;

import '../command.dart';

class Join extends Command {
  Join(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);
    var nick = message.prefix.split('!')[0];

    // Joined a channel as a justinfan (anonymous) user.
    if (_.isJustinfan(client.identity.username) &&
        client.identity.username == nick) {
      // Set last joined channel
      client.lastJoined = channel;
      // Add channel to connected channels list
      client.channels.add(channel);
      client.emit('join', [channel, nick, true]);
    }

    // Someone else joined the channel, just emit the join event..
    if (client.identity.username != nick) {
      client.emit('join', [channel, nick, false]);
    }
  }
}
