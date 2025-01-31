import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/comment.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final commentsStreamProvider =
    StreamProvider.family<List<Comment>, String>((ref, drawingId) {
  final firestore = FirebaseFirestore.instance;
  return firestore
      .collection('shared_drawings')
      .doc(drawingId)
      .collection('comments')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Comment.fromJson({...doc.data(), 'id': doc.id}))
          .toList());
});

class CommentsNotifier extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore;
  final String _userId;
  final String _userName;
  final String? _userPhotoURL;

  CommentsNotifier({
    required String userId,
    required String userName,
    String? userPhotoURL,
  })  : _userId = userId,
        _userName = userName,
        _userPhotoURL = userPhotoURL,
        _firestore = FirebaseFirestore.instance,
        super(const AsyncValue.data(null));

  Future<void> addComment({
    required String drawingId,
    required String text,
  }) async {
    try {
      state = const AsyncValue.loading();

      await _firestore
          .collection('shared_drawings')
          .doc(drawingId)
          .collection('comments')
          .add({
        'userId': _userId,
        'userName': _userName,
        'userPhotoURL': _userPhotoURL,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteComment({
    required String drawingId,
    required String commentId,
  }) async {
    try {
      state = const AsyncValue.loading();

      await _firestore
          .collection('shared_drawings')
          .doc(drawingId)
          .collection('comments')
          .doc(commentId)
          .delete();

      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final commentsProvider =
    StateNotifierProvider<CommentsNotifier, AsyncValue<void>>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.maybeWhen(
    authenticated: (user) => CommentsNotifier(
      userId: user.id,
      userName: user.displayName ?? 'İsimsiz Kullanıcı',
      userPhotoURL: user.photoURL,
    ),
    orElse: () => throw Exception('Yorum yapmak için giriş yapmalısınız'),
  );
});
