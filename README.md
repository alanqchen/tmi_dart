# tmi_dart

[![Dart CI](https://github.com/alanqchen/tmi.dart/actions/workflows/dart.yml/badge.svg?branch=master)](https://github.com/alanqchen/tmi.dart/actions/workflows/dart.yml)
[![codecov](https://codecov.io/gh/alanqchen/tmi.dart/branch/master/graph/badge.svg?token=C4SC92AIRI)](https://codecov.io/gh/alanqchen/tmi.dart)

Dart library for the Twitch Messaging Interface. (Twitch.tv)

🚨 Work In Progress - this package may have bugs unsuitable for production 🚨

### [Documentation](docs/README.md)

---
>Original repository by Ricardo Markiewicz // [@gazeria](https://twitter.com/gazeria).

This project is heavily inspired by the [TMI.js](https://tmijs.com/) project, a Node.js Package for Twitch Chat.

## Getting Started

Install the dependency, create a client and start listening for chat events:

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

Each event type can have different type por parameters. Check the current documentation to see how many events have the event.

In the future we may change this syntax to use a more type-safe event registration but for now this will work.

## Current Events

This is the current supported events. To know which parameters you will receive please check the source code or the [TMI.js Documentation](https://github.com/tmijs/docs/blob/gh-pages/_posts/v1.4.2/2019-03-03-Events.md) as a good reference.

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
* globaluserstate
* emotesets
