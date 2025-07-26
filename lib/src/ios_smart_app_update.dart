import 'dart:convert' show json;

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smart_app_update/src/model.dart';
import 'package:smart_app_update/src/widgets/ios_app_update_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class IOSSmartAppUpdate {
  static IOSSmartAppUpdate? _instance;

  IOSSmartAppUpdate._();

  /// Gets the singleton instance of SmartAppUpdate
  static IOSSmartAppUpdate get instance {
    _instance ??= IOSSmartAppUpdate._();
    return _instance!;
  }

  /// iOS info is fetched by using the iTunes lookup API, which returns a
  /// JSON document.
  Future<SmartAppUpdateDetails?> getUpdateInfo({
    String? iOSAppStoreCountry,
    String? iOSId,
  }) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final id = iOSId ?? packageInfo.packageName;
    // final parameters = {"bundleId": id};

    Map<String, dynamic> parameters = {};

    /// programmermager:fix/issue-35-ios-failed-host-lookup
    if (id.contains('.')) {
      parameters['bundleId'] = id;
    } else {
      parameters['id'] = id;
    }

    parameters['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();

    if (iOSAppStoreCountry != null) {
      parameters.addAll({"country": iOSAppStoreCountry});
    }
    var uri = Uri.https("itunes.apple.com", "/lookup", parameters);
    // final response = await http.get(uri);
    http.Response response;
    try {
      response = await http.get(uri);
    } catch (e) {
      debugPrint('Failed to query iOS App Store\n$e');
      return null;
    }

    if (response.statusCode != 200) {
      debugPrint('Failed to query iOS App Store');
      return null;
    }
    final jsonObj = json.decode(response.body);
    final List results = jsonObj['results'];
    if (results.isEmpty) {
      debugPrint('Can\'t find an app in the App Store with the id: $id');
      return null;
    }
    final isUpdateAvailable = _isUpdateAvailable(
      localVersion: packageInfo.version,
      storeVersion: jsonObj['results'][0]['version'],
    );
    if (isUpdateAvailable) {
      return SmartAppUpdateDetails(
        isUpdateAvailable: true,
        releaseNotes: jsonObj['results'][0]['releaseNotes'],
      );
    }
    return SmartAppUpdateDetails(isUpdateAvailable: false);
  }

  bool _isUpdateAvailable({
    required String localVersion,
    required String storeVersion,
  }) {
    final local = _getCleanVersion(
      localVersion,
    ).split('.').map(int.parse).toList();
    final store = _getCleanVersion(
      storeVersion,
    ).split('.').map(int.parse).toList();

    // Each consecutive field in the version notation is less significant than the previous one,
    // therefore only one comparison needs to yield `true` for it to be determined that the store
    // version is greater than the local version.
    for (var i = 0; i < store.length; i++) {
      // The store version field is newer than the local version.
      if (store[i] > local[i]) {
        return true;
      }

      // The local version field is newer than the store version.
      if (local[i] > store[i]) {
        return false;
      }
    }

    // The local and store versions are the same.
    return false;
  }

  /// This function attempts to clean local version strings so they match the MAJOR.MINOR.PATCH
  /// versioning pattern, so they can be properly compared with the store version.
  String _getCleanVersion(String version) =>
      RegExp(r'\d+(\.\d+)?(\.\d+)?').stringMatch(version) ?? '0.0.0';

  Future<bool> showUpdateDialogWithBuilder({
    required BuildContext? Function()? contextBuilder,
    required Widget Function() iOSUpdateDialogBuilder,
  }) async {
    final context = contextBuilder?.call();
    if (context == null || !context.mounted) {
      return false;
    }

    final updateTriggered = await showCupertinoDialog(
      context: context,
      builder: (_) => iOSUpdateDialogBuilder(),
    );
    return updateTriggered == true;
  }

  Future<bool> showUpdateDialog({
    required BuildContext? Function()? contextBuilder,
    required String appLinkUrl,
    required String? releaseNotes,
  }) async {
    final context = contextBuilder?.call();
    if (context == null || !context.mounted) {
      return false;
    }

    final updateTriggered = await showCupertinoDialog(
      context: context,
      builder: (_) => IOSAppUpdateDialog(
        appLinkUrl: appLinkUrl,
        releaseNotes: releaseNotes,
      ),
    );
    return updateTriggered == true;
  }

  Future<bool> openAppStore({required String appLinkUrl}) async {
    final uri = Uri.parse(appLinkUrl);
    if (await canLaunchUrl(uri)) {
      return launchUrl(uri);
    }
    return false;
  }
}
