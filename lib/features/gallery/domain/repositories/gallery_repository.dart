import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/drawing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class GalleryRepository {
  Future<List<Drawing>> getDrawings();
  Future<void> saveDrawing(Drawing drawing);
  Future<void> deleteDrawing(String id);
  Future<Drawing?> getDrawingById(String id);
}

class LocalGalleryRepository implements GalleryRepository {
  static const String _drawingsKey = 'drawings';
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs!;
  }

  @override
  Future<List<Drawing>> getDrawings() async {
    try {
      final preferences = await prefs;
      final drawingsJson = preferences.getStringList(_drawingsKey) ?? [];
      return drawingsJson
          .map((json) {
            try {
              final Map<String, dynamic> map = jsonDecode(json);
              return Drawing.fromJson(map);
            } catch (e) {
              print('Drawing parse error: $e');
              return null;
            }
          })
          .where((drawing) => drawing != null)
          .cast<Drawing>()
          .toList();
    } catch (e) {
      print('getDrawings error: $e');
      return [];
    }
  }

  @override
  Future<void> saveDrawing(Drawing drawing) async {
    try {
      final preferences = await prefs;
      final drawings = await getDrawings();

      // Çizimi listeye ekle
      drawings.add(drawing);

      // JSON'a dönüştür ve kaydet
      final drawingsJson = drawings
          .map((d) {
            try {
              return jsonEncode(d.toJson());
            } catch (e) {
              print('Drawing encode error: $e');
              return null;
            }
          })
          .where((json) => json != null)
          .cast<String>()
          .toList();

      await preferences.setStringList(_drawingsKey, drawingsJson);
    } catch (e) {
      print('saveDrawing error: $e');
      throw Exception('Çizim kaydedilemedi: $e');
    }
  }

  @override
  Future<void> deleteDrawing(String id) async {
    try {
      final preferences = await prefs;
      final drawings = await getDrawings();

      // Çizimi bul
      final drawing = drawings.firstWhere(
        (d) => d.id == id,
        orElse: () => throw Exception('Çizim bulunamadı'),
      );

      // Dosyayı sil
      final file = File(drawing.path);
      if (await file.exists()) {
        await file.delete();
      }

      // Listeden kaldır
      drawings.removeWhere((d) => d.id == id);

      // Kaydet
      final drawingsJson = drawings.map((d) => jsonEncode(d.toJson())).toList();
      await preferences.setStringList(_drawingsKey, drawingsJson);
    } catch (e) {
      print('deleteDrawing error: $e');
      throw Exception('Çizim silinemedi: $e');
    }
  }

  @override
  Future<Drawing?> getDrawingById(String id) async {
    try {
      final drawings = await getDrawings();
      return drawings.firstWhere(
        (drawing) => drawing.id == id,
        orElse: () => throw Exception('Çizim bulunamadı'),
      );
    } catch (e) {
      print('getDrawingById error: $e');
      return null;
    }
  }

  Future<void> updateDrawing(Drawing drawing) async {
    final preferences = await prefs;
    final drawings = await getDrawings();
    final index = drawings.indexWhere((d) => d.id == drawing.id);
    if (index != -1) {
      drawings[index] = drawing;
      await preferences.setStringList(
          _drawingsKey, drawings.map((d) => jsonEncode(d.toJson())).toList());
    }
  }

  Future<List<String>> getCategories() async {
    final drawings = await getDrawings();
    return drawings.map((d) => d.category).toSet().toList();
  }
}

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  return LocalGalleryRepository();
});
