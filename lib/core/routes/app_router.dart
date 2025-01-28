import 'package:flutter/material.dart';
import '../../features/admin/presentation/pages/database_migration_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/database_migration':
        return MaterialPageRoute(
          builder: (context) => const DatabaseMigrationPage(),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Error: Route not found')),
      ),
    );
  }
}
