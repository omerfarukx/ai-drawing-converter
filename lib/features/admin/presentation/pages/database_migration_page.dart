import 'package:flutter/material.dart';
import '../../../../core/utils/database_migration.dart';

class DatabaseMigrationPage extends StatefulWidget {
  const DatabaseMigrationPage({super.key});

  @override
  State<DatabaseMigrationPage> createState() => _DatabaseMigrationPageState();
}

class _DatabaseMigrationPageState extends State<DatabaseMigrationPage> {
  bool _isMigrating = false;
  String _status = '';
  final _migration = DatabaseMigration();

  Future<void> _startMigration() async {
    setState(() {
      _isMigrating = true;
      _status = 'Migrasyon başlıyor...';
    });

    try {
      await _migration.migrate();
      setState(() {
        _status = 'Migrasyon başarıyla tamamlandı!';
      });
    } catch (e) {
      setState(() {
        _status = 'Hata: $e';
      });
    } finally {
      setState(() {
        _isMigrating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veritabanı Migrasyonu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'DİKKAT!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu işlem mevcut veritabanı yapısını tamamen değiştirecek.\n'
              'İşlem geri alınamaz!\n'
              'Devam etmeden önce verilerin yedeğini aldığınızdan emin olun.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (_isMigrating)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _startMigration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.all(16),
                ),
                child: const Text(
                  'Migrasyonu Başlat',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            const SizedBox(height: 32),
            if (_status.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _status,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
