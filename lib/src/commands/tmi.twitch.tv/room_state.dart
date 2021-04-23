import 'package:logger/src/logger.dart';
import '../../message.dart';
import '../../../tmi.dart';
import '../../utils.dart' as _;

import '../command.dart';

class RoomState extends Command {
  RoomState(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);

    if (_.channel(client.lastJoined) == channel) {
      client.emit('_promiseJoin', [null, channel]);
    }

    // Provide the channel name in the tags before emitting it..
    message.tags['channel'] = channel;
    client.emit('roomstate', [channel, message.tags]);

    if (!message.tags.containsKey('subs-only')) {
      // Handle slow mode here instead of the slow_on/off notice..
      // This room is now in slow mode. You may send messages every slow_duration seconds.
      if (message.tags.containsKey('slow')) {
        if (message.tags['slow'] is bool && !message.tags['slow']) {
          var disabled = [channel, false, 0];
          client.log.i('[${channel}] This room is no longer in slow mode.');
          client.emits(['slow', 'slowmode', '_promiseSlowoff'],
              [disabled, disabled, []]);
        } else {
          var seconds = int.tryParse(message.tags['slow'].toString()) ?? 1;
          var enabled = [channel, true, seconds];
          client.log.i('[${channel}] This room is now in slow mode.');
          client.emits(
              ['slow', 'slowmode', '_promiseSlow'], [enabled, enabled, []]);
        }
      }
      // Handle followers only mode here instead of the followers_on/off notice..
      // This room is now in follower-only mode.
      // This room is now in <duration> followers-only mode.
      // This room is no longer in followers-only mode.
      // duration is in minutes (string)
      // -1 when /followersoff (string)
      // false when /followers with no duration (boolean)
      if (message.tags.containsKey('followers-only')) {
        if (message.tags['followers-only'] == '-1') {
          var disabled = [channel, false, 0];
          client.log
              .i('[${channel}] This room is no longer in followers-only mode.');
          client.emits(
              ['followersonly', 'followersmode', '_promiseFollowersoff'],
              [disabled, disabled, []]);
        } else {
          var minutes =
              int.tryParse(message.tags['followers-only'].toString()) ?? 1;
          var enabled = [channel, true, minutes];
          client.log.i('[${channel}] This room is now in followers-only mode.');
          client.emits(['followersonly', 'followersmode', '_promiseFollowers'],
              [enabled, enabled, []]);
        }
      }
    }
  }
}
