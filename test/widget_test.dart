// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoreader/main.dart' as app;

void main() {
  testWidgets('app boots without crashing', (WidgetTester tester) async {
    // Just verify we can call main() without throwing
    app.main();
    await tester.pump();
    
    // Advance time to let any pending timers complete
    await tester.pump(const Duration(seconds: 4));
    
    // If we get here, the app started successfully
    expect(tester.allWidgets.isNotEmpty, isTrue);
  });
}
