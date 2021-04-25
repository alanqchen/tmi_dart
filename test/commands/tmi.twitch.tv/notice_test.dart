import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi_dart/src/commands/tmi.twitch.tv/notice.dart';
import 'package:tmi_dart/src/message.dart';

import '../../mocks.dart';

void main() {
  late MockClient client;
  late MockLogger logger;
  Message? message;
  setUp(() {
    client = MockClient();
    logger = MockLogger();
    when(client.debug).thenReturn(true);
    when(client.log).thenReturn(logger);
  });

  test('notice event: automod hold message', () {
    // GIVEN
    message = Message.parse(
        '@msg-id=msg_rejected :tmi.twitch.tv NOTICE #nodinawe :Hey! Your message is being checked by mods and has not been sent.');
    var command = Notice(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emit('automod', [
      '#nodinawe',
      'msg_rejected',
      'Hey! Your message is being checked by mods and has not been sent.'
    ]));
  });

  test('notice event: automod reject message', () {
    // GIVEN
    message = Message.parse(
        '@msg-id=msg_rejected_mandatory :tmi.twitch.tv NOTICE #nodinawe :Your message wasn\'t posted due to conflicts with the channel\'s moderation settings.');
    var command = Notice(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emit('automod', [
      '#nodinawe',
      'msg_rejected_mandatory',
      'Your message wasn\'t posted due to conflicts with the channel\'s moderation settings.'
    ]));
  });

  test('notice event: mod list empty', () {
    // GIVEN
    message = Message.parse(
        '@msg-id=no_mods :tmi.twitch.tv NOTICE #nodinawe :There are no moderators of this channel.');
    var command = Notice(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emit('mods', ['#nodinawe', []]));
  });
  test('notice event: mod list populated', () {
    // GIVEN
    message = Message.parse(
        '@msg-id=room_mods :tmi.twitch.tv NOTICE #nodinawe :The moderators of this room are: user1, user2, user3');
    var command = Notice(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emit('mods', [
      '#nodinawe',
      ['user1', 'user2', 'user3']
    ]));
  });

  test('notice event: room in r9k mode', () {
    // GIVEN
    message = Message.parse(
        '@msg-id=r9k_on :tmi.twitch.tv NOTICE #nodinawe :This room is now in r9k mode.');
    var command = Notice(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emits([
      'r9kmode',
      'r9kbeta',
      '_promiseR9kbeta'
    ], [
      ['#nodinawe', true],
      ['#nodinawe', true],
      [null]
    ]));
  });

  test('notice event: room no longer in r9k mode', () {
    // GIVEN
    message = Message.parse(
        '@msg-id=r9k_off :tmi.twitch.tv NOTICE #nodinawe :This room is no longer in r9k mode.');
    var command = Notice(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emits([
      'r9kmode',
      'r9kbeta',
      '_promiseR9kbetaoff'
    ], [
      ['#nodinawe', false],
      ['#nodinawe', false],
      [null]
    ]));
  });

  test('notice event: mod list populated', () {
    // GIVEN
    message = Message.parse(
        '@msg-id=room_mods :tmi.twitch.tv NOTICE #nodinawe :The moderators of this room are: user1, user2, user3');
    var command = Notice(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emit('mods', [
      '#nodinawe',
      ['user1', 'user2', 'user3']
    ]));
  });

  test('notice event: room in subscriber only mode', () {
    // GIVEN
    message = Message.parse(
        '@msg-id=subs_on :tmi.twitch.tv NOTICE #nodinawe :This room is now in subscribers-only mode.');
    var command = Notice(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emits([
      'subscriber',
      'subscribers',
      '_promiseSubscribers'
    ], [
      ['#nodinawe', true],
      ['#nodinawe', true],
      [null]
    ]));
  });

  test('notice event: room no longer in subscriber only mode', () {
    // GIVEN
    message = Message.parse(
        '@msg-id=subs_off :tmi.twitch.tv NOTICE #nodinawe :This room is no longer in subscribers-only mode.');
    var command = Notice(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emits([
      'subscriber',
      'subscribers',
      '_promiseSubscribersoff'
    ], [
      ['#nodinawe', false],
      ['#nodinawe', false],
      [null]
    ]));
  });
}
