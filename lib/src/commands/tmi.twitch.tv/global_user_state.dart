import 'dart:async';

import 'package:logger/src/logger.dart';
import '../command.dart';
import '../../message.dart';
import '../../../tmi.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import '../../utils.dart' as _;

class GlobalUserState extends Command {
  GlobalUserState(Client client, Logger log) : super(client, log);

  @override
  void call(Message message) {
    client.globaluserstate = message.tags;
    client.emotes = message.tags['emote-sets'];

    client.emit('globaluserstate', [message.tags]);

    // Received emote-sets..
    if (message.tags['emote-sets'] != null) {
      client.emotesets = (message.tags['emote-sets'] as String).split(',');
      client.emit('emotesets', [client.emotesets]);
    }
  }
}
