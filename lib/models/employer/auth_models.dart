class AuthToken {
  final String accessToken;
  final String tokenType;
  final DateTime expiresAt;

  AuthToken({required this.accessToken, required this.tokenType, required this.expiresAt});

  factory AuthToken.fromJson(Map<String, dynamic> json) {
    return AuthToken(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      // API returns "2026-08-31 05:03:45" (space-separated, no timezone) — treat as local.
      expiresAt: DateTime.tryParse((json['expires_at'] ?? '').toString().replaceFirst(' ', 'T')) ??
          DateTime.now().add(const Duration(hours: 1)),
    );
  }
}

class EmployerUser {
  final int userId;
  final String username;
  final String fullName;

  EmployerUser({required this.userId, required this.username, required this.fullName});

  factory EmployerUser.fromJson(Map<String, dynamic> json) {
    return EmployerUser(
      userId: json['user_id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
    );
  }
}

class Institution {
  final int id;
  final String accountNumber;
  final String tradeName;
  final String? businessNature;
  final String? address;
  final String email;
  final String phone;
  final String cell;
  final String? dateRegistered;

  Institution({
    required this.id,
    required this.accountNumber,
    required this.tradeName,
    this.businessNature,
    this.address,
    required this.email,
    required this.phone,
    required this.cell,
    this.dateRegistered,
  });

  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      id: json['id'] ?? 0,
      accountNumber: json['account_number'] ?? '',
      tradeName: json['trade_name'] ?? '',
      businessNature: json['business_nature'],
      address: json['address'],
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      cell: json['cell'] ?? '',
      dateRegistered: json['date_registered'],
    );
  }
}

class LoginResult {
  final AuthToken token;
  final EmployerUser user;
  final Institution institution;

  LoginResult({required this.token, required this.user, required this.institution});

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      token: AuthToken.fromJson(json['token'] as Map<String, dynamic>),
      user: EmployerUser.fromJson(json['user'] as Map<String, dynamic>),
      institution: Institution.fromJson(json['institution'] as Map<String, dynamic>),
    );
  }
}

class ProfileResult {
  final EmployerUser user;
  final Institution institution;

  ProfileResult({required this.user, required this.institution});

  factory ProfileResult.fromJson(Map<String, dynamic> json) {
    return ProfileResult(
      user: EmployerUser.fromJson(json['user'] as Map<String, dynamic>),
      institution: Institution.fromJson(json['institution'] as Map<String, dynamic>),
    );
  }
}
