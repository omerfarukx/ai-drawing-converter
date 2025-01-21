import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;

final storageServiceProvider = Provider((ref) => StorageService());

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Çizim yükle
  Future<String> uploadDrawing(String userId, File file) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final ref = _storage.ref().child('drawings/$userId/$fileName');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw 'Çizim yüklenirken hata oluştu: $e';
    }
  }

  // Profil resmi yükle
  Future<String> uploadProfileImage(String userId, File file) async {
    try {
      final fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';
      final ref = _storage.ref().child('profile_images/$userId/$fileName');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw 'Profil resmi yüklenirken hata oluştu: $e';
    }
  }

  // Dosya sil
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      throw 'Dosya silinirken hata oluştu: $e';
    }
  }

  // Kullanıcının tüm çizimlerini sil
  Future<void> deleteUserDrawings(String userId) async {
    try {
      final ref = _storage.ref().child('drawings/$userId');
      final result = await ref.listAll();

      for (var item in result.items) {
        await item.delete();
      }
    } catch (e) {
      throw 'Çizimler silinirken hata oluştu: $e';
    }
  }
}
