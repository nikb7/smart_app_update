import 'package:smart_app_update/src/messages.g.dart';
import 'package:smart_app_update/src/smart_app_update_exception.dart';
import 'package:smart_app_update/src/smart_app_update_platform_interface.dart';

/// A Flutter plugin for handling in-app updates using Google Play Core API.
///
/// This plugin provides methods to check for app updates, start immediate
/// or flexible updates, and track update progress.
class AndroidSmartAppUpdate {
  static AndroidSmartAppUpdate? _instance;

  AndroidSmartAppUpdate._();

  /// Gets the singleton instance of SmartAppUpdate
  static AndroidSmartAppUpdate get instance {
    _instance ??= AndroidSmartAppUpdate._();
    return _instance!;
  }

  /// Checks if an app update is available.
  Future<bool> isUpdateAvailable() async {
    try {
      return await SmartAppUpdatePlatform.instance.isUpdateAvailable();
    } catch (e) {
      throw SmartAppUpdateException('Failed to check for update: $e');
    }
  }

  /// Starts an immediate update flow.
  Future<bool> startImmediateUpdate() async {
    try {
      return await SmartAppUpdatePlatform.instance.startImmediateUpdate();
    } catch (e) {
      throw SmartAppUpdateException('Failed to start immediate update: $e');
    }
  }

  /// Starts a flexible update flow.
  Future<bool> startFlexibleUpdate() async {
    try {
      return await SmartAppUpdatePlatform.instance.startFlexibleUpdate();
    } catch (e) {
      throw SmartAppUpdateException('Failed to start flexible update: $e');
    }
  }

  /// Completes a flexible update by installing the downloaded update.
  Future<bool> completeFlexibleUpdate() async {
    try {
      return await SmartAppUpdatePlatform.instance.completeFlexibleUpdate();
    } catch (e) {
      throw SmartAppUpdateException('Failed to complete flexible update: $e');
    }
  }

  /// Sets a callback to receive update progress notifications.
  void onProgressUpdated(Function(ProgressInfo) callback) {
    SmartAppUpdatePlatform.instance.setProgressCallback(callback);
  }
}
