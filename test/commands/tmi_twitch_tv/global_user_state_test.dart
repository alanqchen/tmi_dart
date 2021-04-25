import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi_dart/src/commands/tmi.twitch.tv/global_user_state.dart';
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
    when(client.emotesets).thenReturn([]);
  });

  test('globaluserstate event: set the global user state', () {
    // GIVEN
    message = Message.parse(
        '@badge-info=;badges=;color=;display-name=nodin_bot;emote-sets=0,16;user-id=664585465;user-type= :tmi.twitch.tv GLOBALUSERSTATE');
    var command = GlobalUserState(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emit('globaluserstate', [
      {
        'badge-info': '',
        'badges': '',
        'color': '',
        'display-name': 'nodin_bot',
        'emote-sets': '0,16',
        'user-id': '664585465',
        'user-type': '',
      },
    ]));
    verify(client.emotesets = ['0', '16']);
  });
}
