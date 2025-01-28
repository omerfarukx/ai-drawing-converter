import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';

final databaseProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});
