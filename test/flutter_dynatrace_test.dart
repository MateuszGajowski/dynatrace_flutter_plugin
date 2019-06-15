import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dynatrace/flutter_dynatrace.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_dynatrace');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterDynatrace.platformVersion, '42');
  });
}
