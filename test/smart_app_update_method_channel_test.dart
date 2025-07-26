import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_app_update/src/smart_app_update_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelSmartAppUpdate platform = MethodChannelSmartAppUpdate();
  const MethodChannel channel = MethodChannel('smart_app_update');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('isUpdateAvailable', () async {
    expect(await platform.isUpdateAvailable(), true);
  });
}
