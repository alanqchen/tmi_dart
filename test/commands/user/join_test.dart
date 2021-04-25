import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi_dart/src/commands/user/join.dart';
import 'package:tmi_dart/src/message.dart';
import 'package:tmi_dart/tmi.dart';

import '../../mocks.dart';
import '../../../lib/src/utils.dart' as _;

void main() {
  late MockClient client;
  late MockLogger logger;
  Message? message;

  setUp(() {
    client = MockClient();
    logger = MockLogger();
    // create stub for identity with random justinfan username
    when(client.identity).thenReturn(Identity(_.justinfan(), ''));
  });

  test('join event: non-client user joins a channel', () {
    // GIVEN
    message = Message.parse(
        ':nodin_bot!nodin_bot@nodin_bot.tmi.twitch.tv JOIN #nodinawe');
    var command = Join(client, logger);
    when(client.userstate).thenReturn(Map<String, dynamic>.from({}));
    when(client.channels).thenReturn(List<String>.from([]));

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emit('join', ['#nodinawe', 'nodin_bot', false]));
    expect(client.userstate, {});
    expect(client.channels, []);
  });

  test("join event: justinfan/anonymous client joins a channel", () {
    // GIVEN
    var message = Message.parse(
        ':justinfan33!justinfan33@justinfan33.tmi.twitch.tv JOIN #nodinawe');
    // create stub for identity with justinfan33 as username
    when(client.identity).thenReturn(Identity('justinfan33', ''));
    when(client.userstate).thenReturn(Map<String, dynamic>.from({}));
    when(client.channels).thenReturn(List<String>.from([]));
    var command = Join(client, logger);

    // WHEN
    expect(message, isNot(null));
    command.call(message!);

    // THEN
    verify(client.emit('join', ['#nodinawe', 'justinfan33', true]));
    verify(client.lastJoined = '#nodinawe');
    // userstate should not be changed since it's a justinfan client
    expect(client.userstate, {});
    expect(client.channels, ['#nodinawe']);
  });
}
