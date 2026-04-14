import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:silent_guard/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SilentGuardApp());
    
    // Check if the app is present
    expect(find.byType(SilentGuardApp), findsOneWidget);
  });
}
