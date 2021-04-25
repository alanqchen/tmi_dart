import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:tmi_dart/src/commands/pong.dart';
import 'package:tmi_dart/src/message.dart';

import '../mocks.dart';

void main() {
  var client;
  var logger;
  var message = Message();

  setUp(() {
    client = MockClient();
    logger = MockLogger();
    // add stub for (DateTime) latency and (int) currentLatency
    when(client.latency).thenReturn(DateTime.now());
    when(client.currentLatency)
        .thenReturn(DateTime.now().millisecondsSinceEpoch);
  });

  test("emits a pong event", () {
    // GIVEN
    var command = Pong(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.emit("pong", any));
  });

  test("should set curreny latency on the client", () {
    // GIVEN
    var command = Pong(client, logger);

    // WHEN
    command.call(message);

    // THEN
    verify(client.currentLatency).called(1);
  });
}
