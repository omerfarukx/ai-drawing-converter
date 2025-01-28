import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

final storageServiceProvider = Provider((ref) => StorageService());

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Çizim yükle
  Future<String> uploadDrawing(String userId, File file) async {
    try {
      print('Debug: Storage - Dosya kontrolü yapılıyor...');
      if (!await file.exists()) {
        throw 'Dosya bulunamadı: ${file.path}';
      }
      print('Debug: Storage - Dosya mevcut: ${file.path}');

      // Dosya boyutunu kontrol et
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw 'Dosya boş';
      }
      print('Debug: Storage - Dosya boyutu: ${fileSize} bytes');

      // Dosya adını düzelt
      final extension = path.extension(file.path).isEmpty
          ? '.png'
          : path.extension(file.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';
      print('Debug: Storage - Dosya adı: $fileName');

      // Storage referansını oluştur
      final ref = _storage.ref().child('drawings/$userId/$fileName');
      print('Debug: Storage - Referans oluşturuldu: ${ref.fullPath}');

      print('Debug: Storage - Yükleme başlıyor...');
      // Metadata ekle
      final metadata = SettableMetadata(
        contentType: 'image/png',
        customMetadata: {
          'userId': userId,
          'uploadDate': DateTime.now().toIso8601String(),
          'type': 'drawing'
        },
      );

      // Yüklemeyi başlat ve bekle
      final uploadTask = await ref.putFile(file, metadata);
      print('Debug: Storage - Yükleme durumu: ${uploadTask.state}');

      if (uploadTask.state == TaskState.success) {
        // URL'i al ve kontrol et
        final downloadUrl = await ref.getDownloadURL();
        print('Debug: Storage - Download URL alındı: $downloadUrl');

        // URL'in geçerli olduğunu kontrol et
        if (downloadUrl.isEmpty) {
          throw 'Download URL boş';
        }

        // URL'i test et
        try {
          final response = await http.head(Uri.parse(downloadUrl));
          if (response.statusCode != 200) {
            throw 'URL erişilebilir değil: ${response.statusCode}';
          }
        } catch (e) {
          print('Debug: Storage - URL test hatası: $e');
          throw 'URL test edilemedi: $e';
        }

        return downloadUrl;
      } else {
        throw 'Yükleme başarısız oldu: ${uploadTask.state}';
      }
    } catch (e) {
      print('Debug: Storage - Hata oluştu: $e');
      throw 'Çizim yüklenirken hata oluştu: $e';
    }
  }

  // Profil resmi yükle
  Future<String> uploadProfileImage(String userId, File file) async {
    try {
      // Dosya boyutunu kontrol et
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        // 5MB
        throw 'Dosya boyutu çok büyük (maksimum 5MB)';
      }

      // Dosya uzantısını kontrol et
      final extension = path.extension(file.path).toLowerCase();
      if (!['.jpg', '.jpeg', '.png'].contains(extension)) {
        throw 'Sadece JPG ve PNG formatları desteklenir';
      }

      // Eski profil resmini sil
      try {
        final oldRef = _storage.ref().child('profile_images/$userId');
        final oldFiles = await oldRef.listAll();
        for (var item in oldFiles.items) {
          await item.delete();
        }
      } catch (e) {
        print('Eski profil resmi silinirken hata: $e');
      }

      // Yeni profil resmini yükle
      final fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}$extension';
      final ref = _storage.ref().child('profile_images/$userId/$fileName');

      // Metadata ekle
      final metadata = SettableMetadata(
        contentType: 'image/$extension',
        customMetadata: {
          'userId': userId,
          'uploadDate': DateTime.now().toIso8601String(),
          'type': 'profile_image'
        },
      );

      // Dosyayı yükle
      final uploadTask = ref.putFile(file, metadata);

      // Upload progress'i dinle
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print(
            'Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
      });

      final snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        return await snapshot.ref.getDownloadURL();
      } else {
        throw 'Yükleme başarısız oldu';
      }
    } catch (e) {
      print('Storage hatası: $e');
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
