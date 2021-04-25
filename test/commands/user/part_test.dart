import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi_dart/src/commands/user/part.dart';
import 'package:tmi_dart/src/message.dart';
import 'package:tmi_dart/tmi.dart';

import '../../mocks.dart';

void main() {
  late MockClient client;
  late MockLogger logger;
  var message = Message.parse(
      ":nodin_bot!nodin_bot@nodin_bot.tmi.twitch.tv PART #nodinawe");

  setUp(() {
    client = MockClient();
    logger = MockLogger();
    when(client.identity).thenReturn(Identity('justinfan33', ''));
  });

  test("part event: non-client user leaves channel", () {
    // GIVEN
    var command = Part(client, logger);
    when(client.channels).thenReturn(['#nodinawe']);

    // WHEN
    expect(message, isNot(null));
    command.call(message!);

    // THEN
    verify(client.emit("part", ["#nodinawe", "nodin_bot", false]));
    // also check connected channels list didn't change
    expect(client.channels, ['#nodinawe']);
  });

  test("part event: client leaves channel", () {
    // GIVEN
    var message = Message.parse(
        ":justinfan33!justinfan33@ronni.tmi.twitch.tv PART #nodinawe");
    when(client.identity).thenReturn(Identity('justinfan33', ''));
    when(client.userstate).thenReturn({'#nodinawe': []});
    when(client.channels).thenReturn(['#nodinawe']);
    var command = Part(client, logger);

    // WHEN
    expect(message, isNot(null));
    command.call(message!);

    // THEN
    verify(client.emit("part", ["#nodinawe", "justinfan33", true]));
    // check that the userstate and channels are empty
    expect(client.userstate, {});
    expect(client.channels, []);
  });
}
