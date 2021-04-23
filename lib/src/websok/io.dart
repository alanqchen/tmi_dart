/// Copyright (c) 2019 - Èrik Campobadal Forés
library websok.io;

import './websok.dart';
import 'package:web_socket_channel/io.dart';

/// For the use of @required.
import 'package:meta/meta.dart';

class IOWebsok extends Websok<IOWebSocketChannel> {
  /// HTTP request headers when [connect()] is called.
  final Map<String, String> headers;

  /// Determines the ping interval for the websocket.
  /// Null means no ping will be sent to the server.
  final Duration? pingInterval;

  /// Creates a new IO Websocket.
  IOWebsok({
    required String host,
    int port = -1,
    String path = '',
    Map<String, String> query = const <String, String>{},
    Iterable<String> protocols = const <String>[],
    this.headers = const <String, String>{},
    this.pingInterval,
    bool tls = false,
  }) : super(
          host: host,
          port: port,
          path: path,
          query: query,
          protocols: protocols,
          tls: tls,
        );

  /// Connects to the websocket given the following options.
  @override
  IOWebSocketChannel connectWith(String url, Iterable<String> protocols) =>
      IOWebSocketChannel.connect(
        url,
        protocols: protocols,
        headers: headers,
        pingInterval: pingInterval,
      );
}
