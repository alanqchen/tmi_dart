import 'package:logger/logger.dart';
import '../../message.dart';
import '../../../tmi.dart';
import '../../utils.dart' as _;

import '../command.dart';

// Handle subanniversary / resub..
class UserNotice extends Command {
  UserNotice(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    var msgid = message.tags['msg-id'];
    var channel = _.channel(message.params[0]);
    var msg = _.get(message.params, 1);

    var username = message.tags['display-name'] ?? message.tags['login'];
    var plan = message.tags['msg-param-sub-plan'] ?? '';
    var planName = _.unescapeIRC(message.tags['msg-param-sub-plan-name']);
    var prime = plan.contains('Prime');
    var methods = {prime, plan, planName};
    var userstate = message.tags;
    var streakMonths =
        int.tryParse(message.tags['msg-param-streak-months'].toString()) ?? 1;
    var recipient = message.tags['msg-param-recipient-display-name'] ??
        message.tags['msg-param-recipient-user-name'];
    var giftSubCount =
        int.tryParse(message.tags['msg-param-mass-gift-count'].toString()) ?? 1;
    userstate['message-type'] = msgid;

    switch (msgid) {
      // Handle resub
      case 'resub':
        client.emit(
          'resub',
          [channel, username, streakMonths, msg, userstate, methods],
        );
        client.emit(
          'subanniversary',
          [channel, username, streakMonths, msg, userstate, methods],
        );
        break;
      // Handle sub
      case 'sub':
        client.emit(
          'subscription',
          [channel, username, methods, msg, userstate],
        );
        break;
      // Handle gift sub
      case 'subgift':
        client.emit(
          'subgift',
          [
            channel,
            username,
            streakMonths,
            recipient,
            methods,
            userstate,
          ],
        );
        break;
      // Handle anonymous gift sub
      // Need proof that this event occur
      case 'anonsubgift':
        client.emit(
          'anonsubgift',
          [channel, streakMonths, recipient, methods, userstate],
        );
        break;
      // Handle random gift subs
      case 'submysterygift':
        client.emit(
          'submysterygift',
          [channel, username, giftSubCount, methods, userstate],
        );
        break;
      // Handle anonymous random gift subs
      // Need proof that this event occur
      case 'anonsubmysterygift':
        client.emit(
          'anonsubmysterygift',
          [channel, giftSubCount, methods, userstate],
        );
        break;
      // Handle user upgrading from Prime to a normal tier sub
      case 'primepaidupgrade':
        client.emit(
          'primepaidupgrade',
          [channel, username, methods, userstate],
        );
        break;
      // Handle user upgrading from a gifted sub
      case 'giftpaidupgrade':
        var sender = message.tags['msg-param-sender-name'] ??
            message.tags['msg-param-sender-login'];
        client.emit('giftpaidupgrade', [channel, username, sender, userstate]);
        break;
      // Handle user upgrading from an anonymous gifted sub
      case 'anongiftpaidupgrade':
        client.emit('anongiftpaidupgrade', [channel, username, userstate]);
        break;
      // Handle raid
      case 'raid':
        var username = message.tags['msg-param-displayName'] ??
            message.tags['msg-param-login'];
        var viewers = int.tryParse(message.tags['msg-param-viewerCount']) ?? 0;
        client.emit('raided', [channel, username, viewers, userstate]);
        break;
      // Handle ritual
      case 'ritual':
        var ritualName = message.tags['msg-param-ritual-name'];
        switch (ritualName) {
          // Handle new chatter ritual
          case 'new_chatter':
            client.emit('newchatter', [channel, username, userstate, msg]);
            break;
          // All unknown rituals should be passed through
          default:
            client.emit(
                'ritual', [ritualName, channel, username, userstate, msg]);
            break;
        }
        break;
      // All other msgid events should be emitted under a usernotice event
      // until it comes up and need to be added...
      default:
        client.emit('usernotice', [msgid, channel, userstate, msg]);
        break;
    }
  }
}
