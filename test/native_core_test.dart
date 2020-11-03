import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_core/native_core.dart';

void main() {
  const MethodChannel channel = MethodChannel('platform_info');

  TestWidgetsFlutterBinding.ensureInitialized();

  test('getPlatformVersion', () async {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });

    expect(await NativeUtils.platformVersion, '42');

    channel.setMockMethodCallHandler(null);
  });

  test('add two ints in C/C++', () {
    expect(NativeCore().add(1, 2), 17);
  });

  test('get locale async', () async {
    // If we don't await, we'll get a false positive as the test will finish
    // without checking the expectation.
    await NativeCore().getLocale(whenDone: (locale) {
      expect(locale, '<Unknown>');
    });
  });
}
