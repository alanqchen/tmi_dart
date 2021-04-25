import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tmi_dart/tmi.dart';

import 'mocks.dart';

/// Used to generate mocks.dart
@GenerateMocks([Client, Logger])
void main() {
  // Create mock object.
  var client = MockClient();
  var logger = MockLogger();
}
