import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/employer_api_client.dart';
import '../../models/employer/employer_auth_state.dart';
import '../../services/employer/employer_api_service.dart';
import '../../services/employer/employer_token_storage.dart';

final employerApiClientProvider = Provider<EmployerApiClient>((ref) {
  return EmployerApiClient(onUnauthorized: () => ref.read(employerAuthProvider.notifier).handleUnauthorized());
});

final employerApiServiceProvider = Provider<EmployerApiService>((ref) {
  return EmployerApiService(ref.watch(employerApiClientProvider));
});

final employerAuthProvider = StateNotifierProvider<EmployerAuthController, EmployerAuthState>((ref) {
  return EmployerAuthController(ref);
});

class EmployerAuthController extends StateNotifier<EmployerAuthState> {
  EmployerAuthController(this._ref) : super(const EmployerAuthState.checking()) {
    _restoreSession();
  }

  final Ref _ref;
  final _tokenStorage = EmployerTokenStorage();

  EmployerApiClient get _client => _ref.read(employerApiClientProvider);
  EmployerApiService get _service => _ref.read(employerApiServiceProvider);

  Future<void> _restoreSession() async {
    final token = await _tokenStorage.readToken();
    final expiresAt = await _tokenStorage.readExpiresAt();
    if (token == null || expiresAt == null || expiresAt.isBefore(DateTime.now())) {
      state = const EmployerAuthState.loggedOut();
      return;
    }
    _client.setAccessToken(token);
    try {
      final profile = await _service.profile();
      state = EmployerAuthState.loggedIn(profile.user, profile.institution);
    } catch (_) {
      await _tokenStorage.clear();
      _client.setAccessToken(null);
      state = const EmployerAuthState.loggedOut();
    }
  }

  Future<void> login({required String username, required String password}) async {
    final result = await _service.login(username: username, password: password);
    _client.setAccessToken(result.token.accessToken);
    await _tokenStorage.save(accessToken: result.token.accessToken, expiresAt: result.token.expiresAt);
    state = EmployerAuthState.loggedIn(result.user, result.institution);
  }

  Future<void> logout() async {
    try {
      await _service.logout();
    } catch (_) {
      // Best-effort server-side token revoke — always clear the local
      // session regardless of whether the server call succeeds.
    }
    await _tokenStorage.clear();
    _client.setAccessToken(null);
    state = const EmployerAuthState.loggedOut();
  }

  void handleUnauthorized() {
    _tokenStorage.clear();
    _client.setAccessToken(null);
    state = const EmployerAuthState.loggedOut();
  }
}
