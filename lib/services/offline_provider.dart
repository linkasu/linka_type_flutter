import 'package:flutter/material.dart';
import 'offline_data_service.dart';

class OfflineProvider extends InheritedWidget {
  final OfflineDataService offlineService;

  const OfflineProvider({
    Key? key,
    required this.offlineService,
    required Widget child,
  }) : super(key: key, child: child);

  static OfflineProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<OfflineProvider>();
  }

  static OfflineDataService? offlineServiceOf(BuildContext context) {
    return of(context)?.offlineService;
  }

  @override
  bool updateShouldNotify(OfflineProvider oldWidget) {
    return offlineService != oldWidget.offlineService;
  }
}
