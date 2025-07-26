import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class IOSAppUpdateDialog extends StatelessWidget {
  final String appLinkUrl;
  final String? releaseNotes;

  const IOSAppUpdateDialog({
    super.key,
    required this.appLinkUrl,
    this.releaseNotes,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: const Text('An update is available'),
      content: Text(
        releaseNotes ??
            'We recommend updating the app to the latest version to get the best experience.',
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text('Later'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          child: const Text('Update'),
          onPressed: () async {
            final uri = Uri.parse(appLinkUrl);
            if (await canLaunchUrl(uri)) {
              launchUrl(uri);
            }
            if (context.mounted) {
              Navigator.pop(context, true);
            }
          },
        ),
      ],
    );
  }
}
