import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/models/user_profile_model.dart';
import 'profile_page.dart';

final followingProvider = FutureProvider.family<List<UserProfile>, String>(
  (ref, userId) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    return firestoreService.getFollowing(userId);
  },
);

class FollowingPage extends ConsumerWidget {
  final String userId;

  const FollowingPage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingAsync = ref.watch(followingProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Takip Edilenler'),
      ),
      body: followingAsync.when(
        data: (following) {
          if (following.isEmpty) {
            return const Center(
              child: Text('Henüz kimseyi takip etmiyor'),
            );
          }

          return ListView.builder(
            itemCount: following.length,
            itemBuilder: (context, index) {
              final followedUser = following[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: followedUser.photoUrl != null
                      ? NetworkImage(followedUser.photoUrl!)
                      : null,
                  child: followedUser.photoUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(followedUser.displayName),
                subtitle: Text('@${followedUser.username}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProfilePage(userId: followedUser.id),
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
