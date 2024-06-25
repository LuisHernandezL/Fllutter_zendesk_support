import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:zendesk_flutter_support/zendesk_flutter_support.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _zendeskPlugin = ZendeskFlutterSupport();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initZendesk();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _zendeskPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> initZendesk() async {
    if (!mounted) {
      return;
    }
    await ZendeskFlutterSupport.initialize('accountKey', 'appId','clientId','zendeskUrl');
    await ZendeskFlutterSupport.setVisitorInfo(
          name: 'Text Client',
          email: 'testclient@example.com',
          phoneNumber: '0000000000',
          department: 'Support');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Running on: $_platformVersion\nInitialize  example with proper\nkeys in main.dart',
                  textAlign: TextAlign.center,
                ),
              ),
              MaterialButton(
                onPressed: openChat,
                color: Colors.blueGrey,
                textColor: Colors.white,
                child: const Text('Open Chat'),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> openChat() async {
    try {
      await ZendeskFlutterSupport.startChat(isAgentAvailabilityEnabled: true,isChatTranscriptPromptEnabled: true,isOfflineFormEnabled: true,isPreChatFormEnabled: true);
    } on dynamic catch (ex) {
      print('An error occured $ex');
    }
  }
}
