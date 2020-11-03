import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';

//==============================================================================
class CStringArray extends Struct {
  Pointer<Pointer<Utf8>> entries;

  @Uint32()
  int size;

  static Pointer<CStringArray> allocateFromList(List<String> strings) {
    final entries = allocate<Pointer<Utf8>>(count: strings.length);

    int size = 0;
    for (var string in strings) {
      entries[size++] = Utf8.toUtf8(string);
    }

    Pointer<CStringArray> retValue = allocate<CStringArray>();
    retValue.ref
      ..entries = entries
      ..size = size;

    return retValue;
  }
}

// This is Dart calling C/C++. Not Kotlin/Java nor Swift/Objective-C.
class NativeCore {
  static final NativeCore _singleton = NativeCore._internal();

  // This function is synchronous. You call it, you get the answer right away.
  int Function(int x, int y) add;

  // This function is asynchronous. You must await when calling it.
  Future<void> getLocale({@required void Function(String) whenDone}) async {
    String locale = "<Unknown>";
    Pointer<Utf8> cLocale = await _getLocale();
    if (cLocale != nullptr) {
      locale = Utf8.fromUtf8(cLocale);
      free(cLocale);
    }

    whenDone(locale);
  }

  Future<Pointer<Utf8>> Function() _getLocale;

  Future<void> localize(List<String> strings,
      {@required void Function(Map<String, String>) whenDone}) async {
    final Map<String, String> localizedMap = {};
    final Pointer<CStringArray> cStringKeys =
        CStringArray.allocateFromList(strings);
    final Pointer<CStringArray> cStringLocalized = await _localize(cStringKeys);
    if (cStringLocalized != nullptr &&
        cStringLocalized.ref.entries != nullptr) {
      for (var index = 0; index < cStringLocalized.ref.size; ++index) {
        String string = strings[index];
        String localizedString =
            Utf8.fromUtf8(cStringLocalized.ref.entries[index]);
        localizedMap[string] = localizedString;

        free(cStringKeys.ref.entries[index]);
        // We don't free localized C-string because its reserved memory.
      }
      free(cStringLocalized.ref.entries);
      free(cStringLocalized);
    }
    free(cStringKeys.ref.entries);
    free(cStringKeys);

    whenDone(localizedMap);
  }

  Future<Pointer<CStringArray>> Function(Pointer<CStringArray>) _localize;

  factory NativeCore() {
    return _singleton;
  }

  NativeCore._internal() {
    // TODO(diego): maybe conditional compilation a la Dart so we don't have to
    //              ask which platform because we are always on the one we expect.
    final DynamicLibrary nativeCoreLib = Platform.isAndroid
        ? DynamicLibrary.open("libnative_core.so")
        : DynamicLibrary.process();

    try {
      add = nativeCoreLib
          .lookup<NativeFunction<Int32 Function(Int32, Int32)>>("add_two_ints")
          .asFunction();
    } catch (ArgumentError) {
      add = (a, b) => 17; // stub
    }

    Pointer<Utf8> Function() getLocaleNative;
    try {
      getLocaleNative = nativeCoreLib
          .lookup<NativeFunction<Pointer<Utf8> Function()>>("get_locale")
          .asFunction();
    } catch (ArgumentError) {
      getLocaleNative = () => nullptr; // stub
    }
    _getLocale = () {
      Future<Pointer<Utf8>> result = new Future<Pointer<Utf8>>(() {
        return getLocaleNative();
      });
      return result;
    };

    Pointer<CStringArray> Function(Pointer<CStringArray>) localizeNative;
    try {
      localizeNative = nativeCoreLib
          .lookup<
              NativeFunction<
                  Pointer<CStringArray> Function(
                      Pointer<CStringArray>)>>('localize')
          .asFunction();
    } catch (ArgumentError) {
      localizeNative = (someList) => nullptr;
    }
    _localize = (someList) {
      Future<Pointer<CStringArray>> result =
          new Future<Pointer<CStringArray>>(() {
        return localizeNative(someList);
      });

      return result;
    };
  }
}

//------------------------------------------------------------------------------
// This is dart calling Kotlin/Java or Swift/Objective-C. Not C/C++.
// class NativeUtils {
//   static const MethodChannel _channel = const MethodChannel('platform_info');

//   static Future<String> get platformVersion async {
//     final String version = await _channel.invokeMethod('getPlatformVersion');
//     return version;
//   }
// }
//==============================================================================
