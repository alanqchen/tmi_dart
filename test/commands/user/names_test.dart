import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi_dart/src/commands/user/names.dart';
import 'package:tmi_dart/src/message.dart';

import '../../mocks.dart';

void main() {
  late MockClient client;
  late MockLogger logger;
  var message = Message.parse(
      ":justinfan64481.tmi.twitch.tv 353 justinfan64481 = #dallas :justinfan64481");

  setUp(() {
    client = MockClient();
    logger = MockLogger();
  });

  test("emits names of users in the chat", () {
    // GIVEN
    var command = Names(client, logger);

    // WHEN
    expect(message, isNot(null));
    command.call(message!);

    // THEN
    verify(client.emit("names", [
      "#dallas",
      ["justinfan64481"]
    ]));
  });
}
