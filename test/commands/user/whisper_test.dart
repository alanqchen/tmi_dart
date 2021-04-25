import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi_dart/src/commands/user/whisper.dart';
import 'package:tmi_dart/src/message.dart';

import '../../mocks.dart';

void main() {
  late MockClient client;
  late MockLogger logger;

  setUp(() {
    client = MockClient();
    logger = MockLogger();
  });

  test('emits whisper', () {
    // GIVEN
    var message = Message.parse(
        ':nodin_bot!nodin_bot@nodin_bot.tmi.twitch.tv WHISPER nodinawe :This is a test whisper!');
    var command = Whisper(client, logger);
    // Expected value
    var expected = {
      'from': '#nodin_bot',
      'tags': {
        'username': 'nodin_bot',
        'message-type': 'whisper',
      },
      'msg': 'This is a test whisper!',
      'self': false,
    };
    var expectedList = [];
    expected.values.forEach((e) {
      expectedList.add(e);
    });

    // WHEN
    expect(message, isNot(null));
    command.call(message!);

    // THEN
    verify(client.emit('whisper', expectedList));
    // It should also emit a message
    verify(client.emit('message', expectedList));
  });
}
