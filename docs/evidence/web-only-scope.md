# Web-only scope

Branch: `t3/web-only-scope` (stacked on `t3/rename-project-luna-bites-delights`)

## Problem

`PRODUCT.md` has declared `## Platform: web` for a while, but the repository still
carried five native targets — `android/`, `ios/`, `macos/`, `linux/`, `windows/` —
115 tracked files of scaffolding for builds nobody ships. They were dead weight
that also failed to compile: `lib/services/location.dart` imports `dart:js`, so
`flutter build apk` and `flutter build windows` both stopped at the Dart compile
step. Nothing in CI or the deploy scripts ever built them.

The delivery model for phones is the PWA: install the ordering app from
`/kiosk/` to the home screen. Chrome and Edge show an install prompt; Safari uses
Share → Add to Home Screen.

## What changed

| Removed | Detail |
|---|---|
| `android/` | 19 files — Gradle, manifests, `MainActivity`, launcher icons |
| `ios/` | 40 files — Xcode project, `Info.plist`, asset catalogs |
| `macos/` | 28 files — Xcode project, `AppInfo.xcconfig`, entitlements |
| `linux/` | 10 files — CMake, GTK runner |
| `windows/` | 18 files — CMake, Win32 runner, `.rc` resources (262 MB on disk with build output) |

Dead configuration that only existed to serve those targets:

- `lib/main.dart` — App Check dropped `androidProvider`/`appleProvider` and the
  `kDebugMode` branch that activated the Android and Apple debug providers. It
  now activates `providerWeb` only, and still skips entirely when
  `RECAPTCHA_SITE_KEY` is unset.
- `pubspec.yaml` — removed `geolocator_android`, and the Android/iOS/Windows
  versioning comment block.
- `analysis_options.yaml` — removed the `android/**`, `ios/**`, `windows/**`,
  `macos/**`, `linux/**` analyzer excludes.
- `.metadata` — trimmed the platform list to `root` and `web`, and dropped the
  `ios/Runner.xcodeproj/project.pbxproj` unmanaged-file entry.
- `.gitignore` — removed the iOS build-id and Android `app/{debug,profile,release}`
  entries.
- `README.md` — added a Platform section stating web-only and how the PWA install
  works, plus the local build commands.

## Proof

The assembled site still runs with no native platforms present. Served from
`build/web` and loaded at `/kiosk/#/menu`:

![Kiosk menu rendering from the web-only build](web-only-scope-kiosk.png)

`flutter build web --release --base-href /kiosk/` and `dart run
tool/assemble_site.dart` both succeed, and the assembled tree keeps the storefront
at `/` and the app at `/kiosk/`.

Local CI parity:

| Job | Result | Log |
|---|---|---|
| `flutter analyze` + baseline | **82** issues (was 87), baseline lowered to 82 | `web-only-scope/flutter-analyze.txt` |
| `flutter test` | 38 passed | `web-only-scope/flutter-test.txt` |
| `flutter build web --release` | built | `web-only-scope/flutter-build-web.txt` |

The analyzer count dropped because the deprecated `androidProvider`/`appleProvider`
calls and the now-unnecessary `flutter/foundation.dart` import went with the dead
branches.

### PWA install readiness

Checked against the assembled build, not the source:

| Requirement | State |
|---|---|
| `/kiosk/manifest.json` served | 200 |
| `display` | `standalone` — opens without browser chrome |
| `start_url` | `/kiosk/` |
| `name` / `short_name` | `Luna Bites & Delights` / `Luna Bites` |
| Icons | 192 and 512, both `any` and `maskable` — all four resolve |
| `theme_color` / `background_color` | `#EC1C72` / `#FEB7C9` |
| iOS `apple-mobile-web-app-capable` | present |
| iOS `apple-mobile-web-app-title` | `Luna Bites` |
| iOS `apple-touch-icon` | present |
| Service worker | `flutter_service_worker.js` emitted |

## Not verified

- **No install was performed on a real Android or iOS device.** The manifest and
  meta tags are correct in the served output, but install prompts and the
  standalone launch were not exercised on hardware.
- **The storefront at `/` has no manifest link.** It is installable only via
  `/kiosk/`, which every storefront call-to-action links to. Making `/` itself
  installable would need a manifest link plus Apple meta tags on the static page —
  left out of this change as a separate decision.
- **No native build was run to confirm its absence**, since the point is that the
  targets no longer exist. Both now refuse to start, which is the intended
  outcome (`web-only-scope/native-builds-gone.txt`):
  - `flutter build apk` → `Flutter failed to read file at …\android\app\build.gradle`
  - `flutter build windows` → `No Windows desktop project configured.`
