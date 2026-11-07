import 'dart:math';

const inviteCodeLength = 6;

const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

String generateInviteCode([Random? random]) {
  final generator = random ?? Random.secure();
  return List.generate(
    inviteCodeLength,
    (_) => _alphabet[generator.nextInt(_alphabet.length)],
  ).join();
}

String normalizeInviteCode(String code) => code.trim().toUpperCase();

bool isValidInviteCodeFormat(String code) {
  final normalized = normalizeInviteCode(code);
  return normalized.length == inviteCodeLength &&
      normalized.split('').every(_alphabet.contains);
}
