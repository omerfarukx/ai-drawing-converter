import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yapayzeka_cizim/features/gallery/domain/models/shared_drawing.dart';
import 'package:yapayzeka_cizim/features/gallery/presentation/widgets/comment_widget.dart';
import 'package:yapayzeka_cizim/features/gallery/presentation/providers/comments_provider.dart';
import 'package:yapayzeka_cizim/features/auth/presentation/providers/user_profile_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

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
  bool _isAddingComment = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return timeago.format(date, locale: 'tr');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Üst Kısım - Resim ve Bilgiler
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.6,
                pinned: true,
                backgroundColor: const Color(0xFF0F0F1E),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Resim
                      Hero(
                        tag: 'drawing_${widget.drawing.id}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: CachedNetworkImage(
                            imageUrl: widget.drawing.imageUrl,
                            fit: BoxFit.cover,
                            fadeInDuration: const Duration(milliseconds: 300),
                            placeholder: (context, url) => Container(
                              color: const Color(0xFF1A1A2E),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF533483)),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFF1A1A2E),
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: Color(0xFF533483),
                                  size: 48,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xFF0F0F1E).withOpacity(0.8),
                              const Color(0xFF0F0F1E),
                            ],
                            stops: const [0.4, 0.8, 1.0],
                          ),
                        ),
                      ),
                      // Kullanıcı Bilgileri
                      Positioned(
                        left: 16,
                        bottom: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Kullanıcı Profili
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF533483)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: const Color(0xFF533483)
                                        .withOpacity(0.2),
                                    backgroundImage:
                                        widget.drawing.userPhotoURL != null
                                            ? NetworkImage(
                                                widget.drawing.userPhotoURL!)
                                            : null,
                                    child: widget.drawing.userPhotoURL == null
                                        ? const Icon(Icons.person,
                                            color: Colors.white70)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
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
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
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
              // İçerik Kısmı
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Başlık
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
                                  height: 1.5,
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            // İstatistikler
                            Row(
                              children: [
                                _buildStatItem(
                                  icon: Icons.favorite,
                                  count: widget.drawing.likesCount,
                                  label: 'Beğeni',
                                ),
                                const SizedBox(width: 24),
                                Consumer(
                                  builder: (context, ref, _) {
                                    final commentsAsync = ref.watch(
                                      commentsStreamProvider(widget.drawing.id),
                                    );
                                    return commentsAsync.when(
                                      data: (comments) => _buildStatItem(
                                        icon: Icons.chat_bubble,
                                        count: comments.length,
                                        label: 'Yorum',
                                      ),
                                      loading: () => _buildStatItem(
                                        icon: Icons.chat_bubble,
                                        count: 0,
                                        label: 'Yorum',
                                      ),
                                      error: (_, __) => _buildStatItem(
                                        icon: Icons.chat_bubble,
                                        count: 0,
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
                      // Yorumlar
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Yorumlar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final commentsAsync = ref.watch(
                            commentsStreamProvider(widget.drawing.id),
                          );
                          return commentsAsync.when(
                            data: (comments) {
                              if (comments.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
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
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: comments.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child:
                                        CommentWidget(comment: comments[index]),
                                  );
                                },
                              );
                            },
                            loading: () => const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            error: (error, _) => Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
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
                      const SizedBox(
                          height: 100), // Yorum yazma alanı için boşluk
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Yorum Yazma Alanı
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        final userProfile = ref.watch(userProfileProvider);
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor:
                                const Color(0xFF533483).withOpacity(0.2),
                            backgroundImage: userProfile?.photoURL != null
                                ? NetworkImage(userProfile!.photoURL!)
                                : null,
                            child: userProfile?.photoURL == null
                                ? const Icon(Icons.person,
                                    color: Colors.white70)
                                : null,
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 100),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213E),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: TextField(
                          controller: _commentController,
                          maxLines: null,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Yorumunuzu yazın...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isAddingComment
                            ? null
                            : () async {
                                final text = _commentController.text.trim();
                                if (text.isEmpty) return;

                                setState(() => _isAddingComment = true);

                                try {
                                  await ref
                                      .read(commentsProvider.notifier)
                                      .addComment(
                                        drawingId: widget.drawing.id,
                                        text: text,
                                      );
                                  _commentController.clear();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Hata: $e'),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isAddingComment = false);
                                  }
                                }
                              },
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: _isAddingComment
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF533483),
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.send_rounded,
                                  color: _commentController.text.trim().isEmpty
                                      ? Colors.white.withOpacity(0.3)
                                      : const Color(0xFF533483),
                                  size: 24,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int count,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF533483),
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          count.toString(),
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
