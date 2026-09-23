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

  // ---- LIVE NOW: Self-Service (case & report submission/tracking) ----
  // Purpose-built public API behind selfservice.necmedical.org.zw (see
  // "API (2).pdf", 2026-09-16) — NOT the same backend as employerApiBaseUrl
  // above or the internal necmedical.necmas.com staff API. Case/report
  // submission, tracking, and lookups need no token at all.
  static const String selfServiceApiBaseUrl = 'https://selfservice.necmedical.org.zw/api/selfservice';
}
