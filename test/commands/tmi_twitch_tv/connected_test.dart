import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi_dart/src/commands/tmi.twitch.tv/connected.dart';
import 'package:tmi_dart/src/message.dart';
import 'package:tmi_dart/tmi.dart';

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
    when(client.connection)
        .thenReturn(Connection(server: 'irc-ws.chat.twitch.tv', secure: true));
    when(client.channels).thenReturn([]);
  });

  test('connected event: connect to irc server', () {
    // GIVEN
    message = Message();
    var command = Connected(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emit('connected', [
      'irc-ws.chat.twitch.tv',
      443,
    ]));
  });
}
