import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    kotlinOut:
        'android/src/main/kotlin/com/nikb/smart_app_update/Messages.g.kt',
  ),
)
// Data Models
class ProgressInfo {
  const ProgressInfo({
    this.bytesDownloaded,
    this.totalBytes,
    required this.status,
  });

  final int? bytesDownloaded;
  final int? totalBytes;
  final UpdateStatus status;
}

enum UpdateStatus {
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
  void onUpdateProgress(ProgressInfo progress);
}
