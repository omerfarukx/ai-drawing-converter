import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile_model.dart';
import '../../domain/services/social_service.dart';

final userSearchQueryProvider = StateProvider<String>((ref) => '');

final userSearchResultsProvider =
    FutureProvider<List<UserProfile>>((ref) async {
  final query = ref.watch(userSearchQueryProvider);
  if (query.isEmpty) return [];

  final socialService = ref.read(socialServiceProvider);
  return await socialService.searchUsers(query);
});
