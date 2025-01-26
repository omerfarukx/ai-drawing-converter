import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/models/user_profile_model.dart';
import 'profile_page.dart';

final followersProvider = FutureProvider.family<List<UserProfile>, String>(
  (ref, userId) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    return firestoreService.getFollowers(userId);
  },
);

class FollowersPage extends ConsumerWidget {
  final String userId;

  const FollowersPage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followersAsync = ref.watch(followersProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Takipçiler'),
      ),
      body: followersAsync.when(
        data: (followers) {
          if (followers.isEmpty) {
            return const Center(
              child: Text('Henüz takipçi yok'),
            );
          }

          return ListView.builder(
            itemCount: followers.length,
            itemBuilder: (context, index) {
              final follower = followers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: follower.photoUrl != null
                      ? NetworkImage(follower.photoUrl!)
                      : null,
                  child: follower.photoUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(follower.displayName),
                subtitle: Text('@${follower.username}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(userId: follower.id),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Hata: $error'),
        ),
      ),
    );
  }
}
