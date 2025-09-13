import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linka_type_flutter/main.dart';
import 'package:linka_type_flutter/services/data_manager.dart';
import 'package:linka_type_flutter/services/analytics_manager.dart';
import 'package:linka_type_flutter/api/services/data_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Create mock services for testing
    final mockDataService = DataService();
    final mockDataManager = await DataManager.create(mockDataService);
    final mockAnalyticsManager = AnalyticsManager();
    await mockAnalyticsManager.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      dataManager: mockDataManager,
      analyticsManager: mockAnalyticsManager,
    ));

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
