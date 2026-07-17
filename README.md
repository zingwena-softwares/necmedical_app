# NEC Medical App — Flow & Status Document

_Last updated: current build handed off from Claude chat → continuing in Claude Code_

---

## 1. Where you are right now

**Project:** `necmedical_app` (Flutter, iOS-only scaffold generated, no Android folder)
**State management:** none yet — plain `StatefulWidget` + `setState()` + `FutureBuilder`
**Backend status:**
| Module | Backend | Status |
|---|---|---|
| Notices / Blog / Gallery | WordPress REST API (`necmedical.org.zw/wp-json/wp/v2`) | ✅ Live, no auth, fully wired |
| Employer Portal | `necmedical-portal.net` (unknown dev, blocked scraping) | ⏳ Waiting on API access request |
| Self Service (disputes/cases) | `selfservice.necmedical.org.zw` (built by SanganaAfrica) | ⏳ Waiting on API access request |
| Meetings | Zoom / Teams (client uses existing accounts) | 📝 Planned as deep-link only, not built yet |

Both pending modules are currently **WebView wrappers** around the live sites, so the app is fully demoable today even without the APIs.

---

## 2. Full app flow

```
App Launch
  │
  ▼
Home Screen
  │
  ├── Information section
  │     ├── Notices        → list (WordPress page) → tap → detail (rendered HTML)
  │     ├── Blog           → list (WordPress posts) → tap → detail (rendered HTML)
  │     └── Gallery        → image grid (WordPress media)
  │
  └── Services section
        ├── Employer Portal → [CURRENT: WebView of necmedical-portal.net/login/]
        │     └── FUTURE (once API access confirmed):
        │           Login → Employer Dashboard
        │             ├── Statements (list → detail → PDF download)
        │             ├── Returns (list → submit new → view submitted)
        │             ├── Payments (history → detail/receipt)
        │             └── Employees (list → add → edit → remove)
        │
        └── Self Service → [CURRENT: WebView of selfservice.necmedical.org.zw]
              └── FUTURE (once API access confirmed):
                    Register/Login (employee OR employer)
                      → My Cases (list with status badges)
                          ├── Submit New Case
                          │     ├── Unfair Dismissal form
                          │     ├── Accident Report form
                          │     └── Sexual Harassment form
                          ├── Case Detail
                          │     ├── Status timeline (submitted → review → hearing → arbitration → resolved)
                          │     ├── Hearing details (date, time, venue/link, officer)
                          │     ├── Arbitration outcome/ruling
                          │     └── Upload supporting documents
                          └── Notifications
                                (status change / hearing scheduled / ruling issued)
```

### Meetings flow (not yet built)
```
Any screen showing a scheduled hearing/meeting
  → "Join Meeting" button
  → deep-link out to Zoom or Teams app via url_launcher
  → (no in-app meeting hosting — client uses their existing Zoom/Teams accounts)
```

---

## 3. Screen inventory (current codebase)

| File | Screen | Data source | Status |
|---|---|---|---|
| `lib/main.dart` | App entry point | — | ✅ done |
| `lib/screens/home_screen.dart` | Home / module launcher | — | ✅ done |
| `lib/screens/notices_screen.dart` | Notices list | WordPress `pages?slug=notices` | ✅ done — **verify slug is correct** |
| `lib/screens/blog_screen.dart` | Blog list | WordPress `posts` | ✅ done |
| `lib/screens/gallery_screen.dart` | Image grid | WordPress `media?media_type=image` | ✅ done |
| `lib/screens/content_detail_screen.dart` | Shared detail view | passed-in `WpContentItem` | ✅ done |
| `lib/screens/employer_portal_screen.dart` | Employer Portal | WebView → `necmedical-portal.net` | 🟡 stub, has TODO block |
| `lib/screens/self_service_screen.dart` | Self Service | WebView → `selfservice.necmedical.org.zw` | 🟡 stub, has TODO block |

**Not yet created — next screens to build once APIs land:**
- `employer_login_screen.dart`
- `employer_dashboard_screen.dart`
- `statements_screen.dart` / `statement_detail_screen.dart`
- `returns_screen.dart` / `submit_return_screen.dart`
- `payments_screen.dart`
- `employees_screen.dart` / `add_edit_employee_screen.dart`
- `case_auth_screen.dart` (register/login, employee or employer)
- `submit_case_screen.dart` (with sub-forms per case type)
- `my_cases_screen.dart`
- `case_detail_screen.dart` (status timeline, hearing, arbitration)
- `meeting_link_button.dart` (reusable widget, deep-links to Zoom/Teams)

---

## 4. Data layer status

| File | Purpose | Status |
|---|---|---|
| `lib/core/constants.dart` | All URLs, single source of truth | ✅ done — fill in `employerPortalApiBaseUrl` / `selfServiceApiBaseUrl` when known |
| `lib/models/wp_content_item.dart` | WordPress post/page model | ✅ done |
| `lib/services/wordpress_api_service.dart` | WordPress API calls | ✅ done |
| `lib/models/employer_model.dart` | Employer profile, statement, return, payment, employee models | ❌ not started |
| `lib/services/employer_api_service.dart` | Employer Portal API calls | ❌ not started — mirror `wordpress_api_service.dart` pattern once API confirmed |
| `lib/models/case_model.dart` | Case, hearing, arbitration models | ❌ not started |
| `lib/services/self_service_api_service.dart` | Self Service API calls | ❌ not started — mirror same pattern |

---

## 5. What to tell Claude Code to work on next

Good next prompts, in order:

1. **"Polish the visual design of home_screen.dart, notices_screen.dart, blog_screen.dart, and gallery_screen.dart — better spacing, NEC Medical brand colors, nicer empty/error states."** (pure UI polish, no backend dependency, can do today)

2. **"Add a splash screen and app icon"** (needs branding assets from the client first — logo file, brand hex colors)

3. **Once employer API access arrives:** "Build employer_model.dart and employer_api_service.dart based on this API response sample: [paste real JSON]. Then build employer_login_screen.dart and employer_dashboard_screen.dart to replace the WebView stub."

4. **Once self-service API access arrives:** same pattern for case_model.dart / self_service_api_service.dart / the case screens.

5. **When cross-screen state is needed** (login session shared across Employer Portal screens, or a submitted case appearing instantly in My Cases): introduce Riverpod at that point — not before.

---

## 6. Open questions still blocking full native builds

- Does `selfservice.necmedical.org.zw` (SanganaAfrica) expose a REST API? — awaiting their reply
- Does `necmedical-portal.net` expose a REST API? — awaiting their reply
- Is "Notices" really a WordPress **page** (current assumption) or a custom post type / category of posts? — needs verifying against the live site structure
- NEC Medical brand colors/logo — not yet supplied