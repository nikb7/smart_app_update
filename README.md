# smart_app_update

A Flutter plugin that provides smart in-app update functionality for Android and iOS applications.

## Overview

The smart_app_update plugin enables you to implement in-app update flows in your Flutter application. It provides different update strategies for Android (using Google Play Core API) while handling iOS updates through App Store redirection.

## Features

- Check if app updates are available
- Immediate updates (Android)
- Flexible updates with background download (Android)
- Progress tracking for flexible updates (Android)
- iOS App Store redirection
- Exception handling for update operations
- Default update dialogs for iOS
- Completely customizable flows

## Default flow

The default flow works as follows:

1. **Initialize**: Create a `SmartAppUpdate` instance with required configuration
2. **Trigger update handled**: Use `updateIfAvailable()` to trigger update check & installation

## Platform-Specific Implementation

### Android

The Android implementation uses Google Play Core API and provides two update types:

#### Available Methods:
- `isUpdateAvailable()` - Checks if an update is available
- `startImmediateUpdate()` - Initiates an immediate update (user must update to continue using the app)
- `startFlexibleUpdate()` - Starts a flexible update (downloads in background)
- `completeFlexibleUpdate()` - Installs a downloaded flexible update
- `onProgressUpdated(callback)` - Sets up progress tracking for flexible updates including download progress and state changes

### iOS
The iOS implementation redirects users to the App Store for updates. It does not support in-app updates due to platform limitations.

#### Available Methods:
- `isUpdateAvailable()` - Checks if an update is available
- `openAppStore()` - Opens the App Store page for the app
- `showUpdateDialog()` - Displays a default update dialog with options to update or cancel
- `showUpdateDialogBuilder()` - Allows customization of the update dialog

## Configuration

### Android
Ensure your Android app is distributed through Google Play Store for in-app updates to work.

### iOS
Provide a valid App Store URL when initializing the plugin.


## Inspiration and Acknowledgments

This plugin was inspired by and built upon the concepts from several excellent Flutter packages:

- **[in_app_update](https://pub.dev/packages/in_app_update)** - A great Flutter plugin for Android in-app updates. Our plugin builds on similar concepts but provides enhanced status tracking and a more comprehensive API surface.

- **[new_version_plus](https://pub.dev/packages/new_version_plus)** - An excellent package for checking app versions across platforms. We drew inspiration from their cross-platform approach and version checking mechanisms.

We acknowledge the valuable work done by the maintainers of these packages and the Flutter community for providing foundational concepts that helped shape this plugin.

## Differences from Similar Packages

While inspired by existing solutions, `smart_app_update` offers:

- **Enhanced Status Tracking**: Detailed progress information with comprehensive status enums
- **Unified API**: Consistent interface across platforms with platform-specific optimizations
- **Better Error Handling**: Custom exception types with detailed error information
- **Modern Architecture**: Built with Pigeon for type-safe platform communication
- **Comprehensive Documentation**: Detailed examples and usage patterns

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

This project is licensed under the terms specified in the LICENSE file.

