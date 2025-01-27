import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/models/shared_drawing.dart';
import '../pages/shared_drawing_detail_page.dart';

class SharedDrawingCard extends StatelessWidget {
  final SharedDrawing drawing;

  const SharedDrawingCard({
    super.key,
    required this.drawing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SharedDrawingDetailPage(drawing: drawing),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF16213E), Color(0xFF1A1A2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'drawing_${drawing.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: CachedNetworkImage(
                  imageUrl: drawing.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 300),
                  fadeOutDuration: const Duration(milliseconds: 300),
                  memCacheWidth: 640,
                  memCacheHeight: 360,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: const Color(0xFF1A1A2E),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF533483),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: const Color(0xFF1A1A2E),
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Hero(
                        tag: 'profile_${drawing.userId}',
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF1A1A2E),
                          backgroundImage: drawing.userProfileImage.isNotEmpty
                              ? CachedNetworkImageProvider(
                                  drawing.userProfileImage,
                                  maxWidth: 64,
                                  maxHeight: 64,
                                )
                              : null,
                          child: drawing.userProfileImage.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          drawing.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    drawing.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.red.withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${drawing.likes}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.chat_bubble,
                        color: Colors.white.withOpacity(0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${drawing.comments}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
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
    );
  }
}
