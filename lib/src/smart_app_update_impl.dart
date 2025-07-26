import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:smart_app_update/smart_app_update.dart';

class SmartAppUpdate {
  /// Only affects iOS App Store lookup: The two-letter country code for the store you want to search.
  /// Provide a value here if your app is only available outside the US.
  /// For example: US. The default is US.
  /// See http://en.wikipedia.org/wiki/ ISO_3166-1_alpha-2 for a list of ISO Country Codes.
  final String? iOSAppStoreCountry;

  /// An optional value that can override the default packageName when
  /// attempting to reach the Apple App Store. This is useful if your app has
  /// a different package name in the App Store.
  final String? iOSId;

  final String iOSAppLinkUrl;

  const SmartAppUpdate({
    this.iOSAppStoreCountry,
    this.iOSId,
    required this.iOSAppLinkUrl,
  });

  /// Checks if an app update is available.
  Future<SmartAppUpdateDetails> getUpdateInfo() async {
    if (Platform.isAndroid) {
      return SmartAppUpdateDetails(
        isUpdateAvailable: (await AndroidSmartAppUpdate.instance
            .isUpdateAvailable()),
      );
    } else if (Platform.isIOS) {
      return (await IOSSmartAppUpdate.instance.getUpdateInfo(
            iOSAppStoreCountry: iOSAppStoreCountry,
            iOSId: iOSId,
          )) ??
          const SmartAppUpdateDetails(isUpdateAvailable: false);
    }

    return const SmartAppUpdateDetails(
      isUpdateAvailable: false,
    ); // No-op for unsupported platforms
  }

  Future<bool> updateIfAvailable({
    bool isFlexibleUpdateAndroid = true,
    Widget Function()? iOSUpdateDialogBuilder,
    BuildContext? Function()? contextBuilder,
    bool Function()? onAndroidUpdatedDownloaded,
  }) async {
    final updateInfo = await getUpdateInfo();

    if (updateInfo.isUpdateAvailable) {
      if (Platform.isAndroid) {
        if (isFlexibleUpdateAndroid) {
          if (await AndroidSmartAppUpdate.instance.startImmediateUpdate()) {
            if (onAndroidUpdatedDownloaded != null) {
              final allowInstall = onAndroidUpdatedDownloaded();
              if (allowInstall) {
                return await AndroidSmartAppUpdate.instance
                    .completeFlexibleUpdate();
              } else {
                return false; // User chose not to install the update
              }
            }

            return await AndroidSmartAppUpdate.instance
                .completeFlexibleUpdate();
          }
        } else {
          return await AndroidSmartAppUpdate.instance.startImmediateUpdate();
        }
      } else if (Platform.isIOS) {
        if (iOSUpdateDialogBuilder != null) {
          return IOSSmartAppUpdate.instance.showUpdateDialogWithBuilder(
            contextBuilder: contextBuilder,
            iOSUpdateDialogBuilder: iOSUpdateDialogBuilder,
          );
        } else {
          return IOSSmartAppUpdate.instance.showUpdateDialog(
            contextBuilder: contextBuilder,
            appLinkUrl: iOSAppLinkUrl,
            releaseNotes: updateInfo.releaseNotes,
          );
        }
      }
    }

    return false;
  }

  /// Starts an immediate update flow.
  Future<bool> startImmediateUpdateIfAvailable() async {
    if (Platform.isAndroid) {
      if (await AndroidSmartAppUpdate.instance.isUpdateAvailable()) {
        return await AndroidSmartAppUpdate.instance.startImmediateUpdate();
      }
    }

    return false;
  }

  /// Starts a flexible update flow.
  Future<bool> startFlexibleUpdateIfAvailable() async {
    if (Platform.isAndroid) {
      if (await AndroidSmartAppUpdate.instance.isUpdateAvailable()) {
        return await AndroidSmartAppUpdate.instance.startFlexibleUpdate();
      }
    }

    return false;
  }

  /// Completes a flexible update by installing the downloaded update.
  Future<bool> completeFlexibleUpdate() async {
    if (Platform.isAndroid) {
      return await AndroidSmartAppUpdate.instance.completeFlexibleUpdate();
    }

    return true; // No-op for iOS
  }
}
