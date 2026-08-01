// ============================================================
// ALL EXTERNAL URLS LIVE HERE.
// When the two devs (WordPress is already live; SanganaAfrica
// and necmedical-portal.net owner are pending) send API base
// URLs, update ONLY this file.
// ============================================================

class ApiConstants {
  // ---- LIVE NOW: WordPress REST API (no auth needed) ----
  // Endpoints (/posts, /pages, /media, /menu-items) are called as relative
  // paths off this base via ApiClient — see wordpress_api_service.dart.
  static const String wpBaseUrl = 'https://necmedical.org.zw/wp-json/wp/v2';

  // ---- LIVE NOW: custom "nec/v1" namespace (DA appointment form) ----
  static const String necApiBaseUrl = 'https://necmedical.org.zw/wp-json/nec/v1';

  // ---- LIVE NOW (TEST environment): Employer Portal API ----
  // Handed over by Ardent Tech via DEVELOPER_INTEGRATION_GUIDE.md (2026-07-22).
  // TODO: swap to the production base URL + API key once Ardent Tech issues them.
  static const String employerApiBaseUrl = 'https://test-api-dev.ardenttech.online/v1';
  static const String employerApiKey = 'nec_aba45af39554854a35602e5cc04481eb5f63b3f7c2147e40';

  // ---- PENDING: Self-Service / Case Management (SanganaAfrica) ----
  // TODO: replace with real API base once SanganaAfrica responds.
  static const String selfServiceWebUrl = 'https://selfservice.necmedical.org.zw/';
  static const String selfServiceApiBaseUrl = ''; // fill in when available
}
