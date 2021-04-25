/// Tests for the websocket wrapper class

import 'package:tmi_dart/src/websock/io.dart';
import 'package:test/test.dart';

/// The received string.
String received = '';

/// Callback to execute when the function is over.
void onData(dynamic message) => received = message;

void main() {
  test('Performs a test websocket connection', () async {
    final sok = IOWebsock(
        host: 'echo.websocket.org', query: {'encoding': 'text'}, tls: true)
      ..connect()
      ..listen(onData: onData);
    // Assets the connection.
    expect(sok.isActive, true);
    // Assets the URL.
    expect(sok.url(), 'wss://echo.websocket.org:443/?encoding=text&');
    // Send a message.
    final message = 'Hello, world!';
    sok.send(message);
    // Check the message.
    await Future.delayed(
        Duration(seconds: 10), () => expect(received, message));
    // Close the connection after 10 seconds.
    sok.close();
    // Assets the connection.
    expect(sok.isActive, false);
  });
}
