import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/self_service/employer_account_model.dart';
import '../../services/self_service/self_service_employer_token_storage.dart';
import 'self_service_providers.dart';

enum SelfServiceEmployerStatus { checking, loggedOut, loggedIn }

class SelfServiceEmployerAuthState {
  final SelfServiceEmployerStatus status;
  final EmployerAccount? employer;
  const SelfServiceEmployerAuthState(this.status, {this.employer});
  const SelfServiceEmployerAuthState.checking() : this(SelfServiceEmployerStatus.checking);
  const SelfServiceEmployerAuthState.loggedOut() : this(SelfServiceEmployerStatus.loggedOut);
  const SelfServiceEmployerAuthState.loggedIn(EmployerAccount employer) : this(SelfServiceEmployerStatus.loggedIn, employer: employer);
}

/// Session for an employer's *own* login on the Self Service portal
/// (register/login → view levies & payments) — separate from the Employer
/// Portal's Ardent Tech session in `providers/employer/employer_providers.dart`.
final selfServiceEmployerAuthProvider =
    StateNotifierProvider<SelfServiceEmployerAuthController, SelfServiceEmployerAuthState>((ref) {
  return SelfServiceEmployerAuthController(ref);
});

class SelfServiceEmployerAuthController extends StateNotifier<SelfServiceEmployerAuthState> {
  SelfServiceEmployerAuthController(this._ref) : super(const SelfServiceEmployerAuthState.checking()) {
    _restoreSession();
  }

  final Ref _ref;
  final _tokenStorage = SelfServiceEmployerTokenStorage();

  Future<void> _restoreSession() async {
    final token = await _tokenStorage.readToken();
    if (token == null) {
      state = const SelfServiceEmployerAuthState.loggedOut();
      return;
    }
    _ref.read(selfServiceApiClientProvider).setAccessToken(token);
    try {
      final employer = await _ref.read(selfServiceApiServiceProvider).me();
      state = SelfServiceEmployerAuthState.loggedIn(employer);
    } catch (_) {
      await _tokenStorage.clear();
      _ref.read(selfServiceApiClientProvider).setAccessToken(null);
      state = const SelfServiceEmployerAuthState.loggedOut();
    }
  }

  Future<void> login({required String email, required String password}) async {
    final (token, employer) = await _ref.read(selfServiceApiServiceProvider).loginEmployer(email: email, password: password);
    await _tokenStorage.save(token);
    _ref.read(selfServiceApiClientProvider).setAccessToken(token);
    state = SelfServiceEmployerAuthState.loggedIn(employer);
  }

  Future<void> register({
    required String tradeName,
    required String ownerFullName,
    required String physicalAddress,
    required String necContactName,
    required String necContactEmail,
    required String necContactCell,
    required String email,
    required String password,
  }) async {
    final (token, employer) = await _ref.read(selfServiceApiServiceProvider).registerEmployer(
          tradeName: tradeName,
          ownerFullName: ownerFullName,
          physicalAddress: physicalAddress,
          necContactName: necContactName,
          necContactEmail: necContactEmail,
          necContactCell: necContactCell,
          email: email,
          password: password,
        );
    await _tokenStorage.save(token);
    _ref.read(selfServiceApiClientProvider).setAccessToken(token);
    state = SelfServiceEmployerAuthState.loggedIn(employer);
  }

  Future<void> logout() async {
    try {
      await _ref.read(selfServiceApiServiceProvider).logoutEmployer();
    } catch (_) {
      // Best-effort server-side revoke — always clear the local session.
    }
    await _tokenStorage.clear();
    _ref.read(selfServiceApiClientProvider).setAccessToken(null);
    state = const SelfServiceEmployerAuthState.loggedOut();
  }

  void handleUnauthorized() {
    _tokenStorage.clear();
    _ref.read(selfServiceApiClientProvider).setAccessToken(null);
    state = const SelfServiceEmployerAuthState.loggedOut();
  }
}
