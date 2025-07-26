/// Custom exception class for SmartAppUpdate errors
class SmartAppUpdateException implements Exception {
  final String message;
  SmartAppUpdateException(this.message);

  @override
  String toString() => 'SmartAppUpdateException: $message';
}
