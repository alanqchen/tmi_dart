# tmi_dart Documentation

## Creating a Client and Connecting

The Client constructor has four named parameters:

| Parameter  | Type           | Default Value  | Description                                                                                                                              |
|------------|----------------|----------------|------------------------------------------------------------------------------------------------------------------------------------------|
| channels   | `List<String>` | *required*     | The channel names to connect to. This cannot be modified. If you wish to connect or leave channels after connecting, send a IRC command. |
| options    | `Options`      | `Options()`    | A Options class to give a client ID and/or enable debug logging                                                                          |
| connection | `Connection`   | `Connection()` | A Connection class to enable or disable secure connection (SSL) and reconnecting                                                         |
| identity   | `Identity`     | See below   | A Identity class to give the username and access token                                                                                   |

### Options Class
The Options constructor has two named parameters:

| Parameter | Type     | Default Value | Description                        |
|-----------|----------|---------------|------------------------------------|
| clientID  | `String` | `''`          | The client ID given from Twitch    |
| debug     | `bool`   | `false`       | If debug logging should be printed |

### Connection Class
The Connection constructor has ten named parameters:

| Parameter | Type   | Default Value | Description                                                                                                                                                                                    |
|-----------|--------|---------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| secure    | `bool` | `true`        | If a secure connection (SSL) should be made                                                                                                                                                    |
| reconnect | `bool` | `false`       | If the client should automatically attempt to reconnect when the connection is lost, unless intentional. This is done with backing-off and jitter in the delay between each connection attempt |

### Identity Class
The Identity constructor has two *ordered* parameters:

| Parameter Number | Type     | Default Value              | Description                                                          |
|------------------|----------|----------------------------|----------------------------------------------------------------------|
| 1                | `String` | justinfan + random integer | The username of the client                                           |
| 2                | `String` | `''`                       | The access token of the client, usually an oauth token (oauth:token) |

### Example

```dart
import 'package:tmi_dart_dart/tmi.dart' as tmi;

var client = tmi.Client(
    channels: ['nodinawe', 'androidedelvalle'],
    options: tmi.Options(
        clientID: 'optional-client-id',
        debug: true,
    ),
    connection: tmi.Connection(secure: true, reconnect: true),
    identity: tmi.Identity('username', 'oauth:access_token'),
);
client.connect();

client.on('message', (channel, userstate, message, self) {
    if (self) return;

    print('${channel}| ${userstate['display-name']}: ${message}');
});
```


## Listening to Events

This is the current supported events. To know which parameters you will receive please check the source code or the [TMI.js Documentation](https://github.com/tmijs/docs/blob/gh-pages/_posts/v1.4.2/2019-03-03-Events.md) as a good reference. You can also create an issue if you have questions.

This is the events that this library currently support (more will be added in the future):

* connecting
* logon
* ping
* pong
* connected
* disconnected
* resub
* subanniversary
* subscription
* subgift
* anonsubgift
* submysterygift
* anonsubmysterygift
* primepaidupgrade
* giftpaidupgrade
* anongiftpaidupgrade
* raided
* unhost
* hosting
* messagedeleted
* roomstate
* slow/slowmode
* followersonly/followersmode
* names
* join
* part
* whisper
* message
* hosted
* cheer
* action
* chat
* raw_message
* timeout
* ban
* vip
* vips
* mod
* mods
* notice

### Examples

```dart

client.on('message', (channel, userstate, message, self) {
      // NOTE: display-name can be empty, in which case 'username' should be used instead
      // NOTE: you'll have to trim spaces yourself
      print(
          "${channel}| ${userstate['badges']} ${userstate['display-name']}: ${message} | emotes: ${userstate['emotes']} | flags: ${userstate['flags']} | color: ${userstate['color']}");

      if (userstate['color'] == '') {
        print('no color set');
      }
      cast<Map<String, dynamic>>(userstate).forEach((key, value) {
        print('${key}: ${value.toString()}');
      });
    });
    client.on('messagedeleted', (channel, username, deletedMessage, userstate) {
      print(
          'MSG DELETED ${channel}:${userstate['target-msg-id']}| ${username} - $deletedMessage');
    });
    client.on('connected', (server, port) {
      print('CONNECTED: $server:$port');
    });
    client.on('disconnected', (reason) {
      print('DISCONNECTED: $reason');
    });
    client.on('pong', (latency) {
      print('LATENCY: $latency ms');
    });
    client.on('mod', (channel, username) {
      print('MOD: $username in $channel');
    });
    client.on('mods', (channel, mods) {
      print('The moderators of this channel are: $channel');
      for (var mod in mods) {
        print('$mod');
      }
    });
    client.on('vips', (channel, vips) {
      print('The vips of this channel are: $channel');
      for (var vip in vips) {
        print('$vip');
      }
    });
    // NOTE: reason is always null (deprecated)
    client.on('timeout', (channel, msg, reason, duration, userstate) {
      print(
          'TIMEOUT: #$channel | ${duration}s | ${userstate['target-user-id']}');
    });
    client.on('notice', (channel, msgid, msg) {
      client.log.i('$channel | $msgid | $msg');
    });
    client.on(
        'ban',
        (channel, username, reason, userstate) => {
              client.log.i(
                  'BAN: #$channel | ${username} | ${userstate['target-user-id']}')
            });
```

## Sending Command/Message
### Joining a channel
```dart
client.sendCommand(null, 'JOIN #channel-name');
```
### Sending a message
```dart
client.sendCommand('channel-name', 'this is a message');
```

