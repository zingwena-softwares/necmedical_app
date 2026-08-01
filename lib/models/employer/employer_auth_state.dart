import 'auth_models.dart';

enum EmployerAuthStatus { checking, loggedOut, loggedIn }

class EmployerAuthState {
  final EmployerAuthStatus status;
  final EmployerUser? user;
  final Institution? institution;

  const EmployerAuthState({required this.status, this.user, this.institution});

  const EmployerAuthState.checking() : this(status: EmployerAuthStatus.checking);

  const EmployerAuthState.loggedOut() : this(status: EmployerAuthStatus.loggedOut);

  EmployerAuthState.loggedIn(EmployerUser user, Institution institution)
      : this(status: EmployerAuthStatus.loggedIn, user: user, institution: institution);
}
