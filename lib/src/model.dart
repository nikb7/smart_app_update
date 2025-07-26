class SmartAppUpdateDetails {
  final bool isUpdateAvailable;

  // Only for iOS
  final String? releaseNotes;

  const SmartAppUpdateDetails({
    required this.isUpdateAvailable,
    this.releaseNotes,
  });
}
