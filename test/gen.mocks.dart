import 'package:logger/logger.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:tmi/tmi.dart';

import 'mocks.dart';

@GenerateMocks([Client, Logger])
void main() {
  // Create mock object.
  var client = MockClient();
  var logger = MockLogger();
}
