import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:squadra_csi/features/auth/data/auth_repository_provider.dart';
import 'package:squadra_csi/features/auth/domain/app_user.dart';

final authStateChangesProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
