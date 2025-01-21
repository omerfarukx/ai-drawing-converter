import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseTestPage extends ConsumerWidget {
  const FirebaseTestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                try {
                  final auth = ref.read(authServiceProvider);
                  await auth.signInWithEmailAndPassword(
                    'test@test.com',
                    'password123',
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Auth başarılı!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Auth hatası: $e')),
                  );
                }
              },
              child: const Text('Auth Test'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final firestore = ref.read(firestoreServiceProvider);
                  await firestore.getUserProfile('test_user');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Firestore başarılı!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Firestore hatası: $e')),
                  );
                }
              },
              child: const Text('Firestore Test'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Doğrudan Firebase Storage'ı test edelim
                  final storage = FirebaseStorage.instance;
                  final testRef = storage.ref().child('test/test.txt');

                  // Test için küçük bir metin dosyası oluşturalım
                  await testRef.putString('Test başarılı!');

                  // Dosyayı okuyalım
                  final downloadUrl = await testRef.getDownloadURL();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Storage başarılı!\nURL: $downloadUrl'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Storage hatası: $e')),
                  );
                }
              },
              child: const Text('Storage Test'),
            ),
          ],
        ),
      ),
    );
  }
}
