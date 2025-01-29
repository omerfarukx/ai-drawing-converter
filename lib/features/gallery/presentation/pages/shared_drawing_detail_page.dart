import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yapayzeka_cizim/features/gallery/domain/models/shared_drawing.dart';
import 'package:yapayzeka_cizim/features/gallery/presentation/widgets/comment_widget.dart';
import 'package:yapayzeka_cizim/features/gallery/presentation/providers/comments_provider.dart';
import 'package:yapayzeka_cizim/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SharedDrawingDetailPage extends ConsumerStatefulWidget {
  final SharedDrawing drawing;

  const SharedDrawingDetailPage({
    Key? key,
    required this.drawing,
  }) : super(key: key);

  @override
  ConsumerState<SharedDrawingDetailPage> createState() =>
      _SharedDrawingDetailPageState();
}

class _SharedDrawingDetailPageState
    extends ConsumerState<SharedDrawingDetailPage> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final userProfile = ref.read(userProfileProvider);
    print(
        'Debug: UserProfile durumu: ${userProfile?.toJson()}'); // Debug için eklendi

    if (userProfile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yorum yapmak için giriş yapmalısınız'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      setState(() => _isAddingComment = true);

      await ref.read(commentsProvider).addComment(
            drawingId: widget.drawing.id,
            text: _commentController.text.trim(),
            userId: userProfile.id,
            userName: userProfile.displayName ?? 'İsimsiz Kullanıcı',
            userPhotoURL: userProfile.photoURL,
          );

      if (mounted) {
        _commentController.clear();
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      print('Debug: Yorum ekleme hatası: $e'); // Debug için eklendi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yorum eklenirken bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingComment = false);
      }
    }
  }

  bool _isAddingComment = false;

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.height * 0.6,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: 'drawing_${widget.drawing.id}',
                            child: Material(
                              type: MaterialType.transparency,
                              child: CachedNetworkImage(
                                imageUrl: widget.drawing.imageUrl,
                                fit: BoxFit.cover,
                                fadeInDuration:
                                    const Duration(milliseconds: 300),
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[900],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundImage:
                                          widget.drawing.userPhotoURL != null
                                              ? NetworkImage(
                                                  widget.drawing.userPhotoURL!)
                                              : null,
                                      child: widget.drawing.userPhotoURL == null
                                          ? const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.drawing.userName,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Paylaşıldı: ${_formatDate(widget.drawing.createdAt)}',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  widget.drawing.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (widget.drawing.description.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.drawing.description,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    _StatItem(
                                      icon: Icons.favorite,
                                      value: widget.drawing.likesCount,
                                      label: 'Beğeni',
                                    ),
                                    const SizedBox(width: 24),
                                    Consumer(
                                      builder: (context, ref, _) {
                                        final commentsAsyncValue = ref.watch(
                                            commentsStreamProvider(
                                                widget.drawing.id));
                                        return commentsAsyncValue.when(
                                          data: (comments) => _StatItem(
                                            icon: Icons.chat_bubble,
                                            value: comments.length,
                                            label: 'Yorum',
                                          ),
                                          loading: () => _StatItem(
                                            icon: Icons.chat_bubble,
                                            value: 0,
                                            label: 'Yorum',
                                          ),
                                          error: (_, __) => _StatItem(
                                            icon: Icons.chat_bubble,
                                            value: 0,
                                            label: 'Yorum',
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            child: Row(
                              children: [
                                Text(
                                  'Yorumlar',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Consumer(
                                  builder: (context, ref, _) {
                                    final commentsAsyncValue = ref.watch(
                                        commentsStreamProvider(
                                            widget.drawing.id));
                                    return commentsAsyncValue.when(
                                      data: (comments) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[400]
                                              ?.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${comments.length}',
                                          style: TextStyle(
                                            color: Colors.blue[400],
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      loading: () => const SizedBox.shrink(),
                                      error: (_, __) => const SizedBox.shrink(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              final commentsAsyncValue = ref.watch(
                                  commentsStreamProvider(widget.drawing.id));

                              return commentsAsyncValue.when(
                                data: (comments) {
                                  if (comments.isEmpty) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(32.0),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.chat_bubble_outline,
                                              size: 48,
                                              color: Colors.grey[700],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Henüz yorum yapılmamış\nİlk yorumu sen yap!',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.grey[500],
                                                fontSize: 14,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: comments
                                        .map((comment) =>
                                            CommentWidget(comment: comment))
                                        .toList(),
                                  );
                                },
                                loading: () => const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                error: (error, stack) => Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 48,
                                          color: Colors.red[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Bir hata oluştu\nLütfen tekrar deneyin',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 14,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        final userProfile = ref.watch(userProfileProvider);
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFF2A2A2A),
                            backgroundImage: userProfile?.photoURL != null
                                ? NetworkImage(userProfile!.photoURL!)
                                : null,
                            child: userProfile?.photoURL == null
                                ? Text(
                                    (userProfile?.displayName ?? 'A')[0]
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                maxLines: null,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _addComment(),
                                decoration: InputDecoration(
                                  hintText: 'Yorumunuzu yazın...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _commentController,
                              builder: (context, value, child) {
                                final isEmpty = value.text.trim().isEmpty;
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: (isEmpty || _isAddingComment)
                                        ? null
                                        : _addComment,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      child: _isAddingComment
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Colors.blue[400]!,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.send_rounded,
                                              color: isEmpty
                                                  ? const Color(0xFF404040)
                                                  : Colors.blue[400],
                                              size: 22,
                                            ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 4),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
