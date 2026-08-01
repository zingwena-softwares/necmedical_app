import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the Employer Portal session (access token + expiry) across app
/// restarts using the platform keystore/keychain (Keystore on Android,
/// Keychain on iOS) rather than plain SharedPreferences, since this is a
/// live bearer token for a real financial account.
class EmployerTokenStorage {
  EmployerTokenStorage({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'employer_access_token';
  static const _expiresAtKey = 'employer_token_expires_at';

  Future<void> save({required String accessToken, required DateTime expiresAt}) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _expiresAtKey, value: expiresAt.toIso8601String());
  }

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<DateTime?> readExpiresAt() async {
    final raw = await _storage.read(key: _expiresAtKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiresAtKey);
  }
}
