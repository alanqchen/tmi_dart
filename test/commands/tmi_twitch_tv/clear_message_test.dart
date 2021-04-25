import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi_dart/src/commands/tmi.twitch.tv/clear_msg.dart';
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

  test('clearmsg event: chat cleared', () {
    // GIVEN
    message = Message.parse(
        '@login=nodin_bot;room-id=;target-msg-id=3011cefb-9845-451a-b8ec-26be7a2d57ee;tmi-sent-ts=1619351952538 :tmi.twitch.tv CLEARMSG #nodinawe :test message :)');
    var command = ClearMsg(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emit('messagedeleted', [
      '#nodinawe',
      'nodin_bot',
      'test message :)',
      {
        'login': 'nodin_bot',
        'room-id': '',
        'target-msg-id': '3011cefb-9845-451a-b8ec-26be7a2d57ee',
        'tmi-sent-ts': '1619351952538',
        'message-type': 'messagedeleted',
      },
    ]));
  });
}
