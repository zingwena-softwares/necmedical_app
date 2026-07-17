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

  // ---- PENDING: Employer Portal (necmedical-portal.net) ----
  // TODO: replace with real API base once SanganaAfrica/portal owner responds.
  // Until then this WebView URL is used directly in employer_portal_screen.dart.
  static const String employerPortalWebUrl = 'https://necmedical-portal.net/login/';
  static const String employerPortalApiBaseUrl = ''; // fill in when available

  // ---- PENDING: Self-Service / Case Management (SanganaAfrica) ----
  // TODO: replace with real API base once SanganaAfrica responds.
  static const String selfServiceWebUrl = 'https://selfservice.necmedical.org.zw/';
  static const String selfServiceApiBaseUrl = ''; // fill in when available
}
