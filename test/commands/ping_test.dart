import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi_dart/src/commands/ping.dart';
import 'package:tmi_dart/src/message.dart';

import '../mocks.dart';

void main() {
  late MockClient client;
  late MockLogger logger;

  setUp(() {
    client = MockClient();
    logger = MockLogger();
  });

  test("ensure emit ping event with isConnected true", () {
    // GIVEN
    // set stub for isConnected = true
    when(client.isConnected).thenReturn(true);
    var message = Message();
    var command = Ping(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.emit("ping"));
  });

  test("should send PONG response with isConnected true", () {
    // GIVEN
    // set stub for isConnected = true
    when(client.isConnected).thenReturn(true);
    var message = Message();
    var command = Ping(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.send("PONG"));
  });

  test("ensure emit ping event with isConnected false", () {
    // GIVEN
    // set stub for isConnected = false
    when(client.isConnected).thenReturn(false);
    var message = Message();
    var command = Ping(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.emit("ping"));
  });

  test("should send PONG response with isConnected true", () {
    // GIVEN
    // set stub for isConnected = false
    when(client.isConnected).thenReturn(false);
    var message = Message();
    var command = Ping(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verifyNever(client.send("PONG"));
  });
}
