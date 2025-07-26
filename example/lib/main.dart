import 'package:flutter/material.dart';
import 'package:smart_app_update/smart_app_update.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _smartAppUpdatePlugin = SmartAppUpdate(
    iOSAppStoreCountry: 'IN',
    iOSId: 'com.example.app', // Replace with your iOS app ID
    iOSAppLinkUrl:
        'https://apps.apple.com/in/app/<app-name>/<app-id>', // Replace with your iOS app link
  );

  @override
  void initState() {
    super.initState();
    _smartAppUpdatePlugin.updateIfAvailable(contextBuilder: () => context);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Smart app update')),
        body: Center(child: Text('Auto handling of app updates')),
      ),
    );
  }
}
