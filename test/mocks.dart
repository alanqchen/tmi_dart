// Mocks generated by Mockito 5.0.5 from annotations
// in tmi/test/old.mocks.dart.
// Do not manually edit this file.

import 'dart:async' as _i6;

import 'package:eventify/eventify.dart' as _i3;
import 'package:logger/src/logger.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:tmi/src/commands/command.dart' as _i5;
import 'package:tmi/tmi.dart' as _i4;

// ignore_for_file: comment_references
// ignore_for_file: unnecessary_parenthesis

class _FakeLogger extends _i1.Fake implements _i2.Logger {}

class _FakeEventEmitter extends _i1.Fake implements _i3.EventEmitter {}

class _FakeOptions extends _i1.Fake implements _i4.Options {}

class _FakeConnection extends _i1.Fake implements _i4.Connection {}

class _FakeIdentity extends _i1.Fake implements _i4.Identity {}

class _FakeDateTime extends _i1.Fake implements DateTime {}

class _FakeListener extends _i1.Fake implements _i3.Listener {}

/// A class which mocks [Client].
///
/// See the documentation for Mockito's code generation for more information.
class MockClient extends _i1.Mock implements _i4.Client {
  MockClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Logger get log =>
      (super.noSuchMethod(Invocation.getter(#log), returnValue: _FakeLogger())
          as _i2.Logger);
  @override
  set log(_i2.Logger? _log) => super.noSuchMethod(Invocation.setter(#log, _log),
      returnValueForMissingStub: null);
  @override
  List<String> get channels =>
      (super.noSuchMethod(Invocation.getter(#channels), returnValue: <String>[])
          as List<String>);
  @override
  _i3.EventEmitter get emitter =>
      (super.noSuchMethod(Invocation.getter(#emitter),
          returnValue: _FakeEventEmitter()) as _i3.EventEmitter);
  @override
  _i4.Options get options => (super.noSuchMethod(Invocation.getter(#options),
      returnValue: _FakeOptions()) as _i4.Options);
  @override
  set options(_i4.Options? _options) =>
      super.noSuchMethod(Invocation.setter(#options, _options),
          returnValueForMissingStub: null);
  @override
  _i4.Connection get connection =>
      (super.noSuchMethod(Invocation.getter(#connection),
          returnValue: _FakeConnection()) as _i4.Connection);
  @override
  set connection(_i4.Connection? _connection) =>
      super.noSuchMethod(Invocation.setter(#connection, _connection),
          returnValueForMissingStub: null);
  @override
  _i4.Identity get identity => (super.noSuchMethod(Invocation.getter(#identity),
      returnValue: _FakeIdentity()) as _i4.Identity);
  @override
  set identity(_i4.Identity? _identity) =>
      super.noSuchMethod(Invocation.setter(#identity, _identity),
          returnValueForMissingStub: null);
  @override
  int get currentLatency =>
      (super.noSuchMethod(Invocation.getter(#currentLatency), returnValue: 0)
          as int);
  @override
  set currentLatency(int? _currentLatency) =>
      super.noSuchMethod(Invocation.setter(#currentLatency, _currentLatency),
          returnValueForMissingStub: null);
  @override
  DateTime get latency => (super.noSuchMethod(Invocation.getter(#latency),
      returnValue: _FakeDateTime()) as DateTime);
  @override
  set latency(DateTime? _latency) =>
      super.noSuchMethod(Invocation.setter(#latency, _latency),
          returnValueForMissingStub: null);
  @override
  Map<String, dynamic> get globaluserstate =>
      (super.noSuchMethod(Invocation.getter(#globaluserstate),
          returnValue: <String, dynamic>{}) as Map<String, dynamic>);
  @override
  set globaluserstate(Map<String, dynamic>? _globaluserstate) =>
      super.noSuchMethod(Invocation.setter(#globaluserstate, _globaluserstate),
          returnValueForMissingStub: null);
  @override
  Map<String, dynamic> get userstate =>
      (super.noSuchMethod(Invocation.getter(#userstate),
          returnValue: <String, dynamic>{}) as Map<String, dynamic>);
  @override
  set userstate(Map<String, dynamic>? _userstate) =>
      super.noSuchMethod(Invocation.setter(#userstate, _userstate),
          returnValueForMissingStub: null);
  @override
  String get lastJoined =>
      (super.noSuchMethod(Invocation.getter(#lastJoined), returnValue: '')
          as String);
  @override
  set lastJoined(String? _lastJoined) =>
      super.noSuchMethod(Invocation.setter(#lastJoined, _lastJoined),
          returnValueForMissingStub: null);
  @override
  Map<String, List<String>> get moderators =>
      (super.noSuchMethod(Invocation.getter(#moderators),
          returnValue: <String, List<String>>{}) as Map<String, List<String>>);
  @override
  set moderators(Map<String, List<String>>? _moderators) =>
      super.noSuchMethod(Invocation.setter(#moderators, _moderators),
          returnValueForMissingStub: null);
  @override
  String get emotes =>
      (super.noSuchMethod(Invocation.getter(#emotes), returnValue: '')
          as String);
  @override
  set emotes(String? _emotes) =>
      super.noSuchMethod(Invocation.setter(#emotes, _emotes),
          returnValueForMissingStub: null);
  @override
  Map<String, String> get emotesets =>
      (super.noSuchMethod(Invocation.getter(#emotesets),
          returnValue: <String, String>{}) as Map<String, String>);
  @override
  set emotesets(Map<String, String>? _emotesets) =>
      super.noSuchMethod(Invocation.setter(#emotesets, _emotesets),
          returnValueForMissingStub: null);
  @override
  bool get wasCloseCalled => (super
          .noSuchMethod(Invocation.getter(#wasCloseCalled), returnValue: false)
      as bool);
  @override
  set wasCloseCalled(bool? _wasCloseCalled) =>
      super.noSuchMethod(Invocation.setter(#wasCloseCalled, _wasCloseCalled),
          returnValueForMissingStub: null);
  @override
  String get reason =>
      (super.noSuchMethod(Invocation.getter(#reason), returnValue: '')
          as String);
  @override
  set reason(String? _reason) =>
      super.noSuchMethod(Invocation.setter(#reason, _reason),
          returnValueForMissingStub: null);
  @override
  int get reconnections =>
      (super.noSuchMethod(Invocation.getter(#reconnections), returnValue: 0)
          as int);
  @override
  set reconnections(int? _reconnections) =>
      super.noSuchMethod(Invocation.setter(#reconnections, _reconnections),
          returnValueForMissingStub: null);
  @override
  bool get reconnecting =>
      (super.noSuchMethod(Invocation.getter(#reconnecting), returnValue: false)
          as bool);
  @override
  set reconnecting(bool? _reconnecting) =>
      super.noSuchMethod(Invocation.setter(#reconnecting, _reconnecting),
          returnValueForMissingStub: null);
  @override
  bool get alreadyConnected =>
      (super.noSuchMethod(Invocation.getter(#alreadyConnected),
          returnValue: false) as bool);
  @override
  set alreadyConnected(bool? _alreadyConnected) => super.noSuchMethod(
      Invocation.setter(#alreadyConnected, _alreadyConnected),
      returnValueForMissingStub: null);
  @override
  Map<String, _i5.Command> get twitchCommands =>
      (super.noSuchMethod(Invocation.getter(#twitchCommands),
          returnValue: <String, _i5.Command>{}) as Map<String, _i5.Command>);
  @override
  set twitchCommands(Map<String, _i5.Command>? _twitchCommands) =>
      super.noSuchMethod(Invocation.setter(#twitchCommands, _twitchCommands),
          returnValueForMissingStub: null);
  @override
  Map<String, _i5.Command> get noScopeCommands =>
      (super.noSuchMethod(Invocation.getter(#noScopeCommands),
          returnValue: <String, _i5.Command>{}) as Map<String, _i5.Command>);
  @override
  set noScopeCommands(Map<String, _i5.Command>? _noScopeCommands) =>
      super.noSuchMethod(Invocation.setter(#noScopeCommands, _noScopeCommands),
          returnValueForMissingStub: null);
  @override
  Map<String, _i5.Command> get userCommands =>
      (super.noSuchMethod(Invocation.getter(#userCommands),
          returnValue: <String, _i5.Command>{}) as Map<String, _i5.Command>);
  @override
  set userCommands(Map<String, _i5.Command>? _userCommands) =>
      super.noSuchMethod(Invocation.setter(#userCommands, _userCommands),
          returnValueForMissingStub: null);
  @override
  bool get isConnected =>
      (super.noSuchMethod(Invocation.getter(#isConnected), returnValue: false)
          as bool);
  @override
  void connect() => super.noSuchMethod(Invocation.method(#connect, []),
      returnValueForMissingStub: null);
  @override
  void close() => super.noSuchMethod(Invocation.method(#close, []),
      returnValueForMissingStub: null);
  @override
  void closeTimeout() =>
      super.noSuchMethod(Invocation.method(#closeTimeout, []),
          returnValueForMissingStub: null);
  @override
  void startMonitor() =>
      super.noSuchMethod(Invocation.method(#startMonitor, []),
          returnValueForMissingStub: null);
  @override
  void cancelMonitor() =>
      super.noSuchMethod(Invocation.method(#cancelMonitor, []),
          returnValueForMissingStub: null);
  @override
  void attemptReconnect() =>
      super.noSuchMethod(Invocation.method(#attemptReconnect, []),
          returnValueForMissingStub: null);
  @override
  _i3.Listener on(String? event, Function? f) =>
      (super.noSuchMethod(Invocation.method(#on, [event, f]),
          returnValue: _FakeListener()) as _i3.Listener);
  @override
  void send(String? command) =>
      super.noSuchMethod(Invocation.method(#send, [command]),
          returnValueForMissingStub: null);
  @override
  int getPromiseDelay() => (super
          .noSuchMethod(Invocation.method(#getPromiseDelay, []), returnValue: 0)
      as int);
  @override
  _i6.Future<bool> sendCommand(String? channel, String? command) =>
      (super.noSuchMethod(Invocation.method(#sendCommand, [channel, command]),
          returnValue: Future<bool>.value(false)) as _i6.Future<bool>);
  @override
  void emits(List<String>? types, List<dynamic>? values) =>
      super.noSuchMethod(Invocation.method(#emits, [types, values]),
          returnValueForMissingStub: null);
  @override
  void emit(String? type, [List<dynamic>? params]) =>
      super.noSuchMethod(Invocation.method(#emit, [type, params]),
          returnValueForMissingStub: null);
}

/// A class which mocks [Logger].
///
/// See the documentation for Mockito's code generation for more information.
class MockLogger extends _i1.Mock implements _i2.Logger {
  MockLogger() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#v, [message, error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#d, [message, error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#i, [message, error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#w, [message, error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#e, [message, error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) =>
      super.noSuchMethod(Invocation.method(#wtf, [message, error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void log(_i2.Level? level, dynamic message,
          [dynamic error, StackTrace? stackTrace]) =>
      super.noSuchMethod(
          Invocation.method(#log, [level, message, error, stackTrace]),
          returnValueForMissingStub: null);
  @override
  void close() => super.noSuchMethod(Invocation.method(#close, []),
      returnValueForMissingStub: null);
}
