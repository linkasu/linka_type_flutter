import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linka_type_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app loads (shows loading indicator initially)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for auth check to complete with timeout
    await tester.pump(const Duration(seconds: 1));

    // Should show either login screen or home screen
    expect(
      find.byType(Scaffold),
      findsOneWidget,
    );
  });
}
