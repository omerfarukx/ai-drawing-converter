import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/drawing.dart';

class GalleryRepository {
  static const String _drawingsKey = 'drawings';
  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<Drawing>> getDrawings() async {
    final preferences = await prefs;
    final drawingsJson = preferences.getStringList(_drawingsKey) ?? [];
    return drawingsJson
        .map((json) =>
            Drawing.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveDrawing(Drawing drawing) async {
    final preferences = await prefs;
    final drawings = await getDrawings();
    drawings.add(drawing);
    await preferences.setStringList(
        _drawingsKey, drawings.map((d) => jsonEncode(d.toJson())).toList());
  }

  Future<void> deleteDrawing(String id) async {
    final preferences = await prefs;
    final drawings = await getDrawings();
    final drawing = drawings.firstWhere((d) => d.id == id);

    // Dosyayı sil
    final file = File(drawing.path);
    if (await file.exists()) {
      await file.delete();
    }

    // Veritabanından kaldır
    drawings.removeWhere((d) => d.id == id);
    await preferences.setStringList(
        _drawingsKey, drawings.map((d) => jsonEncode(d.toJson())).toList());
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
