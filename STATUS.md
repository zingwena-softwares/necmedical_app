# NEC Medical App — Flow & Status
_Last verified against codebase: 2026-07-16_

## 1. Snapshot
**Project:** `necmedical_app` (Flutter). **Both iOS and Android scaffolds exist** (Android folder is present — earlier "iOS-only" note was outdated).
**State management:** Riverpod (`flutter_riverpod ^2.6.1`). `main.dart` is wrapped in `ProviderScope`; `notices_screen.dart`, `blog_screen.dart`, `gallery_screen.dart` are `ConsumerWidget`s backed by `FutureProvider`s in `lib/providers/wordpress_providers.dart`. Pull-to-refresh calls `ref.refresh(...)`.

| Module | Backend | Status |
|---|---|---|
| Notices / Blog / Gallery | WordPress REST API (`necmedical.org.zw/wp-json/wp/v2`) | ✅ Live, no auth, fully wired |
| Employer Portal | `necmedical-portal.net` (unknown dev) | ⏳ WebView wrapper, awaiting API access |
| Self Service (disputes/cases) | `selfservice.necmedical.org.zw` (SanganaAfrica) | ⏳ WebView wrapper, awaiting API access |
| Meetings | Zoom/Teams via deep-link | 📝 Planned, not built |

App is fully demoable today — pending modules are live WebViews of the real sites.

## 2. Flow
```
Home
 ├── Information
 │     ├── Notices  → WP page "notices" → list → detail (HTML)
 │     ├── Blog     → WP posts → list → detail (HTML)
 │     └── Gallery  → WP media → image grid
 └── Services
       ├── Employer Portal → [WebView: necmedical-portal.net/login/]
       │     FUTURE: Login → Dashboard → Statements / Returns / Payments / Employees
       └── Self Service → [WebView: selfservice.necmedical.org.zw]
             FUTURE: Auth → My Cases → Submit Case (dismissal/accident/harassment)
                     → Case Detail (status timeline, hearing, arbitration, docs)

Meetings (not built): hearing/meeting screen → "Join" button → deep-link to
Zoom/Teams via url_launcher (no in-app hosting).
```

## 3. Code inventory (verified against `lib/`)
| File | Purpose | Status |
|---|---|---|
| `main.dart` | Entry point — `ProviderScope` + light/dark `ThemeData` (`ThemeMode.system`) | ✅ |
| `core/constants.dart` | All URLs, single source of truth | ✅ |
| `core/api_client.dart` | Shared Dio wrapper (timeouts, logging, `ApiException`) — used by every API service | ✅ |
| `models/wp_content_item.dart` | WP post/page model | ✅ |
| `services/wordpress_api_service.dart` | WP API calls via `ApiClient` (Dio) | ✅ |
| `widgets/content_card.dart` | Shared list-item card | ✅ |
| `screens/home_screen.dart` | Module launcher | ✅ |
| `screens/notices_screen.dart` | Notices list | ✅ — slug `notices` confirmed live (see §6) |
| `screens/blog_screen.dart` | Blog list | ✅ |
| `screens/gallery_screen.dart` | Image grid | ✅ |
| `screens/content_detail_screen.dart` | Shared detail view | ✅ |
| `screens/employer_portal_screen.dart` | WebView → portal | 🟡 stub w/ TODO for native replacement |
| `screens/self_service_screen.dart` | WebView → self-service | 🟡 stub w/ TODO for native replacement |

**Not yet created:** `employer_login_screen.dart`, `employer_dashboard_screen.dart`, `statements_*`, `returns_*`, `payments_screen.dart`, `employees_*`, `case_auth_screen.dart`, `submit_case_screen.dart`, `my_cases_screen.dart`, `case_detail_screen.dart`, `meeting_link_button.dart`.

**Not yet created (data layer):** `models/employer_model.dart`, `services/employer_api_service.dart`, `models/case_model.dart`, `services/self_service_api_service.dart` — build these once the respective APIs land, mirroring `wordpress_api_service.dart`.

## 4. Fixes applied this pass (deepfix)
- **Android `INTERNET` permission was missing** from `android/app/src/main/AndroidManifest.xml`. Debug builds mask this (Flutter tooling grants it automatically in debug), but a release/profile Android build would have silently failed all `http` and WebView network calls. Added `<uses-permission android:name="android.permission.INTERNET"/>`. ✅ fixed
- **`assets/images/` didn't exist** even though `pubspec.yaml` declares it under `flutter: assets:`. Created the directory (with `.gitkeep`) so asset bundling doesn't break once you add real images. ✅ fixed
- **`url_launcher` had no Android 11+ package-visibility declaration.** Added `<queries>` entries for `https`/`http` VIEW intents so Zoom/Teams meeting deep-links (and any external browser links) actually work instead of `canLaunchUrl` silently returning false.
- **Riverpod added.** `flutter_riverpod` wired into `main.dart` (`ProviderScope`) and the three WordPress screens converted from `StatefulWidget`/`setState`/`FutureBuilder` to `ConsumerWidget`/`FutureProvider` (`lib/providers/wordpress_providers.dart`). Ran `flutter pub get` + `flutter analyze` — no issues.
- **Switched `http` → `dio`.** New `lib/core/api_client.dart` is the one base class every backend's service should build on (`ApiClient(baseUrl)` + `getJson`/`postJson`, shared timeouts/logging/error normalization). `wordpress_api_service.dart` refactored to use it; dead full-URL constants (`wpPosts`/`wpPages`/`wpMedia`/`wpMenuItems`) removed from `constants.dart` since Dio joins relative paths off `wpBaseUrl`. Verified live against the real WordPress API.
- **Dark + light theme wired up.** `main.dart` now defines both `theme` and `darkTheme` via `ColorScheme.fromSeed(brightness: ...)` off the same brand seed color, with `themeMode: ThemeMode.system`. Found and fixed hardcoded `Colors.black54`/`Colors.grey.shadeXXX` in `home_screen.dart`, `content_card.dart`, and `gallery_screen.dart` that would've looked wrong (invisible/low-contrast text, wrong-toned placeholders) in dark mode — replaced with `Theme.of(context).colorScheme.onSurfaceVariant` / `surfaceContainerHighest`. WebView screens also now sync their background color to the current theme to avoid a white flash while loading.

## 5. Open questions — resolved this pass
- ~~Is "Notices" a WordPress page or custom post type?~~ **Confirmed via live API call**: `GET /wp-json/wp/v2/pages?slug=notices` returns the page (id 2019, live, last modified 2025-11-12). The current `fetchPageBySlug('notices')` implementation in `notices_screen.dart` is correct — no change needed.

## 6. Still open
- Does `necmedical-portal.net` expose a REST API? — awaiting reply
- Does `selfservice.necmedical.org.zw` (SanganaAfrica) expose a REST API? — awaiting reply
- NEC Medical brand colors/logo — not yet supplied (blocks splash screen / app icon work)

## 7. Next prompts, in order
1. UI polish pass on `home_screen.dart`, `notices_screen.dart`, `blog_screen.dart`, `gallery_screen.dart` — spacing, brand colors, empty/error states. No backend dependency, can do today.
2. Splash screen + app icon — needs logo/brand hex colors from client first.
3. Once employer API lands: build `employer_model.dart` + `employer_api_service.dart` from a real JSON sample, then `employer_login_screen.dart` / `employer_dashboard_screen.dart` to replace the WebView.
4. Once self-service API lands: same pattern for `case_model.dart` / `self_service_api_service.dart` / case screens.
5. ~~Introduce Riverpod only when cross-screen state is actually needed~~ — done this pass. Employer/Self-Service session state and future forms should use `StateNotifierProvider`/`AsyncNotifierProvider` once those APIs land, following the same pattern as `wordpress_providers.dart`.
