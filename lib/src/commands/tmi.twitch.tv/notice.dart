import 'package:logger/src/logger.dart';
import '../../message.dart';
import '../../../tmi.dart';
import '../../utils.dart' as _;

import '../command.dart';

class Notice extends Command {
  Notice(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var channel = _.channel(message.params[0]);
    var msg = _.get(message.params, 1);
    if (msg == null) return;
    var msgid = message.tags['msg-id'];

    var nullArr = [null];
    var noticeArr = [channel, msgid, msg];
    var msgidArr = [msgid];
    var channelTrueArr = [channel, true];
    var channelFalseArr = [channel, false];
    var noticeAndNull = [noticeArr, nullArr];
    var noticeAndMsgid = [noticeArr, msgidArr];
    var basicLog = '[${channel}] ${msg}';

    switch (msgid) {
      // This room is now in subscribers-only mode.
      case 'subs_on':
        if (client.debug)
          log.i('[${channel}] This room is now in subscribers-only mode.');
        client.emits(['subscriber', 'subscribers', '_promiseSubscribers'],
            [channelTrueArr, channelTrueArr, nullArr]);
        break;

      // This room is no longer in subscribers-only mode.
      case 'subs_off':
        if (client.debug)
          log.i(
              '[${channel}] This room is no longer in subscribers-only mode.');
        client.emits(['subscriber', 'subscribers', '_promiseSubscribersoff'],
            [channelFalseArr, channelFalseArr, nullArr]);
        break;

      // This room is now in emote-only mode.
      case 'emote_only_on':
        if (client.debug)
          log.i('[${channel}] This room is now in emote-only mode.');
        client.emits(
            ['emoteonly', '_promiseEmoteonly'], [channelTrueArr, nullArr]);
        break;

      // This room is no longer in emote-only mode.
      case 'emote_only_off':
        if (client.debug)
          log.i('[${channel}] This room is no longer in emote-only mode.');
        client.emits(
            ['emoteonly', '_promiseEmoteonlyoff'], [channelFalseArr, nullArr]);
        break;

      // Do not handle slow_on/off here, listen to the ROOMSTATE notice instead as it returns the delay.
      case 'slow_on':
      case 'slow_off':
        break;

      // Do not handle followers_on/off here, listen to the ROOMSTATE notice instead as it returns the delay.
      case 'followers_onzero': // Documentation uses this
      case 'followers_on_zero':
      case 'followers_on':
      case 'followers_off':
        break;

      // This room is now in r9k mode.
      case 'r9k_on':
        if (client.debug) log.i('[${channel}] This room is now in r9k mode.');
        client.emits(['r9kmode', 'r9kbeta', '_promiseR9kbeta'],
            [channelTrueArr, channelTrueArr, nullArr]);
        break;

      // This room is no longer in r9k mode.
      case 'r9k_off':
        if (client.debug)
          log.i('[${channel}] This room is no longer in r9k mode.');
        client.emits(['r9kmode', 'r9kbeta', '_promiseR9kbetaoff'],
            [channelFalseArr, channelFalseArr, nullArr]);
        break;

      // The moderators of this room are: [..., ...]
      case 'room_mods':
        var mods = msg.split(': ')[1].toLowerCase().split(', ')
          ..retainWhere((String n) => n.isNotEmpty);

        client.emit('_promiseMods', [null, mods]);
        client.emit('mods', [channel, mods]);
        break;

      // There are no moderators for this room.
      case 'no_mods':
        client.emit('_promiseMods', [null, []]);
        client.emit('mods', [channel, []]);
        break;

      // The VIPs of this channel are: [..., ...]
      case 'vips_success':
        if (msg.endsWith('.')) {
          msg = msg.substring(0, msg.length - 1);
        }
        var vips = msg
            .split(': ')[1]
            .toLowerCase()
            .split(', ')
            .where((String n) => n != null && n.isNotEmpty);

        client.emits([
          '_promiseVips',
          'vips'
        ], [
          [null, vips],
          [channel, vips]
        ]);
        break;

      // There are no VIPs for this room.
      case 'no_vips':
        client.emits([
          '_promiseVips',
          'vips'
        ], [
          [null, []],
          [channel, []]
        ]);
        break;

      // Ban command failed..
      case 'already_banned':
      case 'bad_ban_anon':
      case 'bad_ban_admin':
      case 'bad_ban_broadcaster':
      case 'bad_ban_global_mod':
      case 'bad_ban_self':
      case 'bad_ban_staff':
      case 'usage_ban':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseBan'], noticeAndMsgid);
        break;

      // Ban command success..
      case 'ban_success':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseBan'], noticeAndNull);
        break;

      // Clear command failed..
      case 'usage_clear':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseClear'], noticeAndMsgid);
        break;

      // Mods command failed..
      case 'usage_mods':
        if (client.debug) log.i(basicLog);
        client.emits([
          'notice',
          '_promiseMods'
        ], [
          noticeArr,
          [msgid, []]
        ]);
        break;

      // Mod command success..
      case 'mod_success':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseMod'], noticeAndNull);
        break;

      // VIPs command failed..
      case 'usage_vips':
        if (client.debug) log.i(basicLog);
        client.emits([
          'notice',
          '_promiseVips'
        ], [
          noticeArr,
          [msgid, []]
        ]);
        break;

      // VIP command failed..
      case 'usage_vip':
      case 'bad_vip_grantee_banned':
      case 'bad_vip_grantee_already_vip':
      case 'bad_vip_achievement_incomplete':
        if (client.debug) log.i(basicLog);
        client.emits([
          'notice',
          '_promiseVip'
        ], [
          noticeArr,
          [msgid, []]
        ]);
        break;

      // VIP command success..
      case 'vip_success':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseVip'], noticeAndNull);
        break;

      // Mod command failed..
      case 'usage_mod':
      case 'bad_mod_banned':
      case 'bad_mod_mod':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseMod'], noticeAndMsgid);
        break;

      // Unmod command success..
      case 'unmod_success':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseUnmod'], noticeAndNull);
        break;

      // Unvip command success...
      case 'unvip_success':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseUnvip'], noticeAndNull);
        break;

      // Unmod command failed..
      case 'usage_unmod':
      case 'bad_unmod_mod':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseUnmod'], noticeAndMsgid);
        break;

      // Unvip command failed..
      case 'usage_unvip':
      case 'bad_unvip_grantee_not_vip':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseUnvip'], noticeAndMsgid);
        break;

      // Color command success..
      case 'color_changed':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseColor'], noticeAndNull);
        break;

      // Color command failed..
      case 'usage_color':
      case 'turbo_only_color':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseColor'], noticeAndMsgid);
        break;

      // Commercial command success..
      case 'commercial_success':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseCommercial'], noticeAndNull);
        break;

      // Commercial command failed..
      case 'usage_commercial':
      case 'bad_commercial_error':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseCommercial'], noticeAndMsgid);
        break;

      // Host command success..
      case 'hosts_remaining':
        if (client.debug) log.i(basicLog);
        var remainingHost = int.tryParse(msg[0]) ?? 0;
        client.emits([
          'notice',
          '_promiseHost'
        ], [
          noticeArr,
          [null, remainingHost]
        ]);
        break;

      // Host command failed..
      case 'bad_host_hosting':
      case 'bad_host_rejected':
      case 'bad_host_self':
      case 'bad_host_rate_exceeded':
      case 'bad_host_error':
      case 'usage_host':
        if (client.debug) log.i(basicLog);
        client.emits([
          'notice',
          '_promiseHost'
        ], [
          noticeArr,
          [msgid, null]
        ]);
        break;

      // r9kbeta command failed..
      case 'already_r9k_on':
      case 'usage_r9k_on':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseR9kbeta'], noticeAndMsgid);
        break;

      // r9kbetaoff command failed..
      case 'already_r9k_off':
      case 'usage_r9k_off':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseR9kbetaoff'], noticeAndMsgid);
        break;

      // Timeout command success..
      case 'timeout_success':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseTimeout'], noticeAndNull);
        break;

      case 'delete_message_success':
        if (client.debug) log.i('[${channel} ${msg}]');
        client.emits(['notice', '_promiseDeletemessage'], noticeAndNull);
        break;

      // Followerson command failed...
      case 'usage_followers_on':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseFollowers'], noticeAndNull);
        break;

      // Followersoff command failed...
      case 'usage_followers_off':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseFollowersoff'], noticeAndNull);
        break;

      // Subscribersoff command failed..
      case 'already_subs_off':
      case 'usage_subs_off':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseSubscribersoff'], noticeAndMsgid);
        break;

      // Subscribers command failed..
      case 'already_subs_on':
      case 'usage_subs_on':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseSubscribers'], noticeAndMsgid);
        break;

      // Emoteonlyoff command failed..
      case 'already_emote_only_off':
      case 'usage_emote_only_off':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseEmoteonlyoff'], noticeAndMsgid);
        break;

      // Emoteonly command failed..
      case 'already_emote_only_on':
      case 'usage_emote_only_on':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseEmoteonly'], noticeAndMsgid);
        break;

      // Slow command failed..
      case 'bad_slow_duration':
      case 'usage_slow_on':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseSlow'], noticeAndMsgid);
        break;

      // Slowoff command failed..
      case 'usage_slow_off':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseSlowoff'], noticeAndMsgid);
        break;

      // Timeout command failed..
      case 'usage_timeout':
      case 'bad_timeout_anon':
      case 'bad_timeout_admin':
      case 'bad_timeout_broadcaster':
      case 'bad_timeout_duration':
      case 'bad_timeout_mod':
      case 'bad_timeout_global_mod':
      case 'bad_timeout_self':
      case 'bad_timeout_staff':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseTimeout'], noticeAndMsgid);
        break;

      // Unban command success..
      // Unban can also be used to cancel an active timeout.
      case 'untimeout_success':
      case 'unban_success':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseUnban'], noticeAndNull);
        break;

      // Unban command failed..
      case 'usage_unban':
      case 'bad_unban_no_ban':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseUnban'], noticeAndMsgid);
        break;

      // Delete command failed..
      case 'usage_delete':
      case 'bad_delete_message_error':
      case 'bad_delete_message_broadcaster':
      case 'bad_delete_message_mod':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseDeletemessage'], noticeAndMsgid);
        break;

      // Unhost command failed..
      case 'usage_unhost':
      case 'bad_unhost_error':
      case 'not_hosting':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseUnhost'], noticeAndMsgid);
        break;

      // Whisper command failed..
      case 'whisper_banned':
      case 'whisper_banned_recipient':
      case 'whisper_invalid_args':
      case 'whisper_invalid_login':
      case 'whisper_invalid_self':
      case 'whisper_limit_per_min':
      case 'whisper_limit_per_sec':
      case 'whisper_restricted':
      case 'whisper_restricted_recipient':
        if (client.debug) log.i(basicLog);
        client.emits(['notice', '_promiseWhisper'], noticeAndMsgid);
        break;

      // Permission error..
      case 'no_permission':
      case 'msg_banned':
      case 'msg_room_not_found':
      case 'msg_channel_suspended':
      case 'tos_ban':
      case 'invalid_user':
        if (client.debug) log.i(basicLog);
        client.emits([
          'notice',
          '_promiseBan',
          '_promiseClear',
          '_promiseUnban',
          '_promiseTimeout',
          '_promiseDeletemessage',
          '_promiseMods',
          '_promiseMod',
          '_promiseUnmod',
          '_promiseVips',
          '_promiseVip',
          '_promiseUnvip',
          '_promiseCommercial',
          '_promiseHost',
          '_promiseUnhost',
          '_promiseJoin',
          '_promisePart',
          '_promiseR9kbeta',
          '_promiseR9kbetaoff',
          '_promiseSlow',
          '_promiseSlowoff',
          '_promiseFollowers',
          '_promiseFollowersoff',
          '_promiseSubscribers',
          '_promiseSubscribersoff',
          '_promiseEmoteonly',
          '_promiseEmoteonlyoff'
        ], [
          noticeArr,
          [msgid, channel]
        ]);
        break;

      // Automod-related..
      case 'msg_rejected':
      case 'msg_rejected_mandatory':
        if (client.debug) log.i(basicLog);
        client.emit('automod', [channel, msgid, msg]);
        break;

      // Unrecognized command..
      case 'unrecognized_cmd':
        if (client.debug) log.i(basicLog);
        client.emit('notice', [channel, msgid, msg]);
        break;

      // Send the following msg-ids to the notice event listener..
      case 'cmds_available':
      case 'host_success':
      case 'host_success_viewers':
      case 'host_target_went_offline':
      case 'msg_censored_broadcaster':
      case 'msg_duplicate':
      case 'msg_emoteonly':
      case 'msg_verified_email':
      case 'msg_ratelimit':
      case 'msg_subsonly':
      case 'msg_timedout':
      case 'msg_bad_characters':
      case 'msg_channel_blocked':
      case 'msg_facebook':
      case 'msg_followersonly':
      case 'msg_followersonly_followed':
      case 'msg_followersonly_zero':
      case 'msg_slowmode':
      case 'msg_suspended':
      case 'msg_r9k':
      case 'no_help':
      case 'usage_disconnect':
      case 'usage_help':
      case 'usage_me':
      case 'unavailable_command':
      // Raid notices
      case 'raid_error_already_raiding':
      case 'raid_error_forbidden':
      case 'raid_error_self':
      case 'raid_error_too_many_viewers':
      case 'raid_error_unexpected':
      case 'raid_notice_mature':
      case 'raid_notice_restricted_chat':
      case 'usage_raid':
      // Timeout notices
      case 'timeout_no_timeout':
      // Unraid notices
      case 'unraid_error_no_active_raid':
      case 'unraid_error_unexpected':
      case 'unraid_success':
      case 'usage_unraid':
      // Unsuppoerted chatroom notice
      case 'unsupported_chatrooms_cmd':
      // Untimeout notices
      case 'untimeout_banned':
      case 'usage_untimeout':
      // Marker notices
      case 'bad_marker_client':
      case 'usage_marker':
        if (client.debug) log.i(basicLog);
        client.emit('notice', [channel, msgid, msg]);
        break;

      // Ignore this because we are already listening to HOSTTARGET..
      case 'host_on':
      case 'host_off':
        break;

      default:
        if (msg.contains('Login unsuccessful') ||
            msg.contains('Login authentication failed')) {
          client.wasCloseCalled = false;
          client.connection.reconnect = false;
          client.reason = msg;
          if (client.debug) log.e(client.reason);
          client.close();
        } else if (msg.contains('Error logging in') ||
            msg.contains('Improperly formatted auth')) {
          client.wasCloseCalled = false;
          client.connection.reconnect = false;
          client.reason = msg;
          if (client.debug) log.e(client.reason);
          client.close();
        } else if (msg.contains('Invalid NICK')) {
          client.wasCloseCalled = false;
          client.connection.reconnect = false;
          client.reason = 'Invalid NICK.';
          if (client.debug) log.e(client.reason);
          client.close();
        } else {
          if (client.debug)
            log.w('Could not parse NOTICE from tmi.twitch.tv:\n${message}');
          client.emit('notice', [channel, msgid, msg]);
        }
        break;
    }
  }
}
