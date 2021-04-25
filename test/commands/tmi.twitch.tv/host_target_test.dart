import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi_dart/src/commands/tmi.twitch.tv/host_target.dart';
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

  test('hosttarget event: hosting', () {
    // GIVEN
    message =
        Message.parse(':tmi.twitch.tv HOSTTARGET #nodinawe :nodin_bot 123');
    var command = HostTarget(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emit(
      'hosting',
      ['#nodinawe', 'nodin_bot', 123],
    ));
  });

  test('hosttarget event: exited host mode', () {
    // GIVEN
    message = Message.parse(':tmi.twitch.tv HOSTTARGET #nodinawe :- 0');
    var command = HostTarget(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emit(
      'unhost',
      ['#nodinawe', 0],
    ));
  });
}
