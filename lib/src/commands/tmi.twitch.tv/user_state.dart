import 'package:logger/src/logger.dart';
import '../../message.dart';
import '../../../tmi.dart';
import '../../utils.dart' as _;

import '../command.dart';

class UserState extends Command {
  UserState(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);

    message.tags['username'] = client.identity.username;

    // Add the client to the moderators of this room..
    if (message.tags['user-type'] == 'mod') {
      if (!client.moderators.containsKey(client.lastJoined)) {
        client.moderators[client.lastJoined] = [];
      }
      if (!client.moderators[client.lastJoined]!
          .contains(client.identity.username)) {
        client.moderators[client.lastJoined]!.add(client.identity.username);
      }
    }

    // Logged in and username doesn't start with justinfan..
    if (!_.isJustinfan(client.identity.username) &&
        !client.userstate.containsKey(channel)) {
      client.userstate[channel] = message.tags;
      client.lastJoined = channel;
      // this.channels.push(channel);
      log.i('Joined ${channel}');
      client
          .emit('join', [channel, _.username(client.identity.username), true]);
    }

    // Emote-sets has changed, update it..
    if (message.tags['emote-sets'] != client.emotes) {
      _updateEmoteset(message.tags['emote-sets']);
    }

    client.userstate[channel] = message.tags;
  }

  _updateEmoteset(String sets) {
    // this.emotes = sets;
  }
}
