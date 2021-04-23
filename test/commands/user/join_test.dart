import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi/src/commands/user/join.dart';
import 'package:tmi/src/message.dart';
import 'package:tmi/tmi.dart';

import '../../mocks.dart';
import '../../../lib/src/utils.dart' as _;

void main() {
  var client;
  var logger;
  var message = Message.parse(":ronni!ronni@ronni.tmi.twitch.tv JOIN #dallas");

  setUp(() {
    client = MockClient();
    logger = MockLogger();
    // create stub for identity with random justinfan username
    when(client.identity).thenReturn(Identity(_.justinfan(), ''));
  });

  test("emits when a user join to the chat", () {
    // GIVEN
    var command = Join(client, logger);

    // WHEN
    assert(message != Null);
    command.call(message!);

    // THEN
    verify(client.emit("join", ["#dallas", "ronni", false]));
  });

  test("detects if the join message is from myself", () {
    // GIVEN
    var message = Message.parse(
        ":justinfan33!justinfan33@ronni.tmi.twitch.tv JOIN #dallas");
    // create stub for identity with justinfan33 as username
    when(client.identity).thenReturn(Identity('justinfan33', ''));
    var command = Join(client, logger);

    // WHEN
    assert(message != null);
    command.call(message!);

    // THEN
    verify(client.lastJoined = "#dallas");
    verify(client.emit("join", ["#dallas", "justinfan33", true]));
  });
}
