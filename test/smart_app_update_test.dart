import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:smart_app_update/smart_app_update.dart';
import 'package:smart_app_update/src/smart_app_update_method_channel.dart';
import 'package:smart_app_update/src/smart_app_update_platform_interface.dart';

class MockSmartAppUpdatePlatform
    with MockPlatformInterfaceMixin
    implements SmartAppUpdatePlatform {
  @override
  Future<bool> completeFlexibleUpdate() {
    // TODO: implement completeFlexibleUpdate
    throw UnimplementedError();
  }

  @override
  void setProgressCallback(Function(SmartAppUpdateProgressInfo p1) onProgress) {
    // TODO: implement setProgressCallback
  }

  @override
  Future<bool> startFlexibleUpdate() {
    // TODO: implement startFlexibleUpdate
    throw UnimplementedError();
  }

  @override
  Future<bool> startImmediateUpdate() {
    // TODO: implement startImmediateUpdate
    throw UnimplementedError();
  }

  @override
  Future<bool> isUpdateAvailable() async {
    return true;
  }
}

void main() {
  final SmartAppUpdatePlatform initialPlatform =
      SmartAppUpdatePlatform.instance;

  test('$MethodChannelSmartAppUpdate is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSmartAppUpdate>());
  });

  test('isUpdateAvailable', () async {
    SmartAppUpdate smartAppUpdatePlugin = SmartAppUpdate(iOSAppLinkUrl: '');
    MockSmartAppUpdatePlatform fakePlatform = MockSmartAppUpdatePlatform();
    SmartAppUpdatePlatform.instance = fakePlatform;

    expect(
      (await smartAppUpdatePlugin.getUpdateInfo()).isUpdateAvailable,
      true,
    );
  });
}
