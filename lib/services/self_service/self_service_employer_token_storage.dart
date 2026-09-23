import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists an employer's own Self Service login (selfservice.necmedical.org.zw)
/// across app restarts. Separate from the Employer Portal's token storage —
/// these are two different backends with two different accounts.
class SelfServiceEmployerTokenStorage {
  SelfServiceEmployerTokenStorage({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'self_service_employer_access_token';

  Future<void> save(String accessToken) => _storage.write(key: _tokenKey, value: accessToken);

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> clear() => _storage.delete(key: _tokenKey);
}
