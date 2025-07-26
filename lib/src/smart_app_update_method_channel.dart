import 'package:smart_app_update/src/messages.g.dart';
import 'package:smart_app_update/src/smart_app_update_platform_interface.dart';

class MethodChannelSmartAppUpdate extends SmartAppUpdatePlatform
    implements UpdateFlutterApi {
  late final UpdateHostApi _hostApi;
  Function(ProgressInfo)? _onProgress;

  MethodChannelSmartAppUpdate() {
    _hostApi = UpdateHostApi();
    UpdateFlutterApi.setUp(this);
  }

  @override
  Future<bool> isUpdateAvailable() {
    return _hostApi.isUpdateAvailable();
  }

  @override
  Future<bool> startImmediateUpdate() {
    return _hostApi.startImmediateUpdate();
  }

  @override
  Future<bool> startFlexibleUpdate() {
    return _hostApi.startFlexibleUpdate();
  }

  @override
  Future<bool> completeFlexibleUpdate() {
    return _hostApi.completeFlexibleUpdate();
  }

  @override
  void setProgressCallback(Function(ProgressInfo) onProgress) {
    _onProgress = onProgress;
  }

  // UpdateFlutterApi implementation (callbacks from native)
  @override
  void onUpdateProgress(ProgressInfo progress) {
    _onProgress?.call(progress);
  }
}
