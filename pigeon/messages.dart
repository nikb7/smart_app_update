import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut:
        'android/src/main/kotlin/com/nikb/smart_app_update/Messages.g.kt',
  ),
)
// Data Models
class SmartAppUpdateProgressInfo {
  const SmartAppUpdateProgressInfo({
    this.bytesDownloaded,
    this.totalBytes,
    required this.status,
  });

  final int? bytesDownloaded;
  final int? totalBytes;
  final SmartAppUpdateStatus status;
}

enum SmartAppUpdateStatus {
  checking,
  downloading,
  downloaded,
  installing,
  installed,
  failed,
  canceled,
}

// Host API (Flutter calls native)
@HostApi()
abstract class UpdateHostApi {
  @async
  bool isUpdateAvailable();

  @async
  bool startImmediateUpdate();

  @async
  bool startFlexibleUpdate();

  @async
  bool completeFlexibleUpdate();
}

// Flutter API (native calls Flutter)
@FlutterApi()
abstract class UpdateFlutterApi {
  void onUpdateProgress(SmartAppUpdateProgressInfo progress);
}
