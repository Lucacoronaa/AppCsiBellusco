import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:squadra_csi/features/team/data/firestore_team_repository.dart';
import 'package:squadra_csi/features/team/domain/team_repository.dart';

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return FirestoreTeamRepository(FirebaseFirestore.instance);
});
