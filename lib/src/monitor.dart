// Ping/Pong monitor
import 'dart:async';

import '../tmi.dart';
import 'websock/io.dart';

class Monitor {
  final Client client;

  Timer? pingLoop;
  Timer? pingTimeout;
  bool pingSent = false;
  bool monitoring = false;

  Monitor(this.client) {
    client.on('pong', (_) {
      pingSent = false;
    });
  }

  void loop(IOWebsock sok) async {
    monitoring = true;

    if (monitoring) {
      // Start the periodic ping loop
      pingLoop = Timer.periodic(Duration(milliseconds: 60000), (Timer timer) {
        if (client.isConnected) {
          client.send('PING');
        }
        client.latency = DateTime.now();
        pingSent = true;
        // Start the ping timeout Timer
        pingTimeout = Timer(client.connection.timeout, () {
          // If pingSent is still true, no pong was received in time
          if (pingSent == true) {
            if (client.debug) client.log.w('PONG TIMEOUT');
            pingLoop?.cancel();
            pingTimeout?.cancel();
            client.closeTimeout();
          }
        });
      });
    }
  }
}
