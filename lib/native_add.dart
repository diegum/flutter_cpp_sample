import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/services.dart';

//==============================================================================
// This is Dart calling C/C++. Not Kotlin/Java nor Swift/Objective-C.
final DynamicLibrary nativeAddLib = Platform.isAndroid
    ? DynamicLibrary.open("libnative_add.so")
    : DynamicLibrary.process();

final int Function(int x, int y) nativeAdd = nativeAddLib
    .lookup<NativeFunction<Int32 Function(Int32, Int32)>>("native_add_two_ints")
    .asFunction();

//------------------------------------------------------------------------------
// This is dart calling Kotlin/Java or Swift/Objective-C. Not C/C++.
class NativeUtils {
  static const MethodChannel _channel = const MethodChannel('platform_info');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
//==============================================================================
