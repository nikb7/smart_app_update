import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:smart_app_update/src/messages.g.dart';
import 'package:smart_app_update/src/smart_app_update_method_channel.dart';

abstract class SmartAppUpdatePlatform extends PlatformInterface {
  SmartAppUpdatePlatform() : super(token: _token);

  static final Object _token = Object();
  static SmartAppUpdatePlatform _instance = MethodChannelSmartAppUpdate();

  static SmartAppUpdatePlatform get instance => _instance;

  static set instance(SmartAppUpdatePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // Add Pigeon methods
  Future<bool> isUpdateAvailable() {
    throw UnimplementedError('isUpdateAvailable() has not been implemented.');
  }

  Future<bool> startImmediateUpdate() {
    throw UnimplementedError(
      'startImmediateUpdate() has not been implemented.',
    );
  }

  Future<bool> startFlexibleUpdate() {
    throw UnimplementedError('startFlexibleUpdate() has not been implemented.');
  }

  Future<bool> completeFlexibleUpdate() {
    throw UnimplementedError(
      'completeFlexibleUpdate() has not been implemented.',
    );
  }

  // Callback setters
  void setProgressCallback(Function(ProgressInfo) onProgress) {
    throw UnimplementedError('setProgressCallback() has not been implemented.');
  }
}
