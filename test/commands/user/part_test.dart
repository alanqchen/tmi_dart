import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi/src/commands/user/join.dart';
import 'package:tmi/src/commands/user/part.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';

import '../../mocks.dart';

void main() {
  var client;
  var logger;
  var message = Message.parse(":ronni!ronni@ronni.tmi.twitch.tv PART #dallas");

  setUp(() {
    client = MockClient();
    logger = MockLogger();
    when(client.identity).thenReturn(Identity('justinfan33', ''));
  });

  test("emits when a user leave the chat", () {
    // GIVEN
    var command = Part(client, logger);

    // WHEN
    assert(message != null);
    command.call(message!);

    // THEN
    verify(client.emit("part", ["#dallas", "ronni", false]));
  });

  test("detects if I leave the chat", () {
    // GIVEN
    var message = Message.parse(
        ":justinfan33!justinfan33@ronni.tmi.twitch.tv PART #dallas");
    when(client.identity).thenReturn(Identity('justinfan33', ''));
    when(client.userstate).thenReturn({"dallas": []});
    when(client.channels).thenReturn(["dallas"]);
    var command = Part(client, logger);

    // WHEN
    assert(message != null);
    command.call(message!);

    // THEN
    verify(client.emit("part", ["#dallas", "justinfan33", true]));
  });
}
