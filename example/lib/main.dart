import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

import 'ffi/native_core.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // String _platformVersion = 'Unknown';
  int _sumResult = 0;
  String _locale = 'Unknown';
  Map<String, String> _localizedStrings = {};

  @override
  void initState() {
    super.initState();

    // _initPlatformState();

    // No need to call setState synchronously from initState();
    _sumResult = NativeCore().add(1, 2);

    _initLocaleState();

    _localizeStrings();
  }

  Future<void> _initLocaleState() async {
    await NativeCore().getLocale(whenDone: (locale) {
      if (!mounted) return;

      setState(() {
        _locale = locale;
      });
    });
  }

  Future<void> _localizeStrings() async {
    await NativeCore().localize(['Hello, world', 'I prefer C++'],
        whenDone: (results) {
      if (!mounted) return;

      setState(() {
        _localizedStrings = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          // child: Text('Running on: $_platformVersion\n1 + 2 == $_sumResult\n'
          child: Text('1 + 2 == $_sumResult\n'
              '$_locale\n${_localizedStrings["Hello, world"]}\n'
              '${_localizedStrings["I prefer C++"]}'),
        ),
      ),
    );
  }
}
