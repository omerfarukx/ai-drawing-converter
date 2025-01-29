import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/models/user.dart';

final userProfileProvider = Provider.autoDispose<User?>((ref) {
  final authState = ref.watch(authControllerProvider);

  return authState.maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
});
