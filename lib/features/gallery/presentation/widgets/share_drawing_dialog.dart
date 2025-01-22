import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../domain/models/drawing.dart';
import '../providers/share_drawing_provider.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/user_service.dart';

class ShareDrawingDialog extends ConsumerStatefulWidget {
  final Drawing drawing;

  const ShareDrawingDialog({
    super.key,
    required this.drawing,
  });

  @override
  ConsumerState<ShareDrawingDialog> createState() => _ShareDrawingDialogState();
}

class _ShareDrawingDialogState extends ConsumerState<ShareDrawingDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isPublic = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.drawing.title;
    _descriptionController.text = widget.drawing.description;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _shareDrawing() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir başlık girin')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final storageService = ref.read(storageServiceProvider);
      final userService = UserService();
      final user = await userService.getCurrentUser();

      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen önce giriş yapın')),
          );
        }
        return;
      }

      // Resmi Firebase Storage'a yükle
      final imageUrl = await storageService.uploadDrawing(
        user.uid,
        File(widget.drawing.path),
      );

      // Çizimi paylaş
      await ref.read(shareDrawingProvider.notifier).shareDrawing(
            userId: user.uid,
            userName: user.displayName ?? 'Anonim',
            userProfileImage: user.photoURL ?? '',
            imageUrl: imageUrl,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            isPublic: _isPublic,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Çizim başarıyla paylaşıldı')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF16213E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Çizimi Paylaş',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Başlık',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF533483),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Açıklama',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF533483),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text(
                'Herkese Açık',
                style: TextStyle(color: Colors.white),
              ),
              value: _isPublic,
              onChanged: (value) => setState(() => _isPublic = value),
              activeColor: const Color(0xFF533483),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'İptal',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _shareDrawing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF533483),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Paylaş',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
