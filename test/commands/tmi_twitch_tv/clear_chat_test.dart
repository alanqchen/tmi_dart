import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi_dart/src/commands/tmi.twitch.tv/clear_chat.dart';
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

  test('clearchat event: chat cleared', () {
    // GIVEN
    message = Message.parse(':tmi.twitch.tv CLEARCHAT #nodinawe');
    var command = ClearChat(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emit('clearchat', ['#nodinawe']));
  });

  test('clearchat (ban) event: user banned', () {
    // GIVEN
    var message = Message.parse(
        '@room-id=39589486;target-user-id=664585465 :tmi.twitch.tv CLEARCHAT #nodinawe :nodin_bot');
    // create stub for identity with justinfan33 as username
    var command = ClearChat(client, logger);

    // WHEN
    expect(message, isNot(null));
    command.call(message!);

    // THEN
    verify(client.emit('ban', [
      '#nodinawe',
      'nodin_bot',
      null,
      {'room-id': '39589486', 'target-user-id': '664585465'}
    ]));
  });

  test('clearchat (timeout) event: user timeout', () {
    // GIVEN
    var message = Message.parse(
        '@ban-duration=10;room-id=39589486;target-user-id=664585465 :tmi.twitch.tv CLEARCHAT #nodinawe :nodin_bot');
    // create stub for identity with justinfan33 as username
    var command = ClearChat(client, logger);

    // WHEN
    expect(message, isNot(null));
    command.call(message!);

    // THEN
    verify(client.emit('timeout', [
      '#nodinawe',
      'nodin_bot',
      null,
      10,
      {
        'ban-duration': '10',
        'room-id': '39589486',
        'target-user-id': '664585465',
      }
    ]));
  });
}
