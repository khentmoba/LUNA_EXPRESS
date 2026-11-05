# Local CI checks — SEO benchmark PR

Run on 2026-11-05 against `t3/benchmark-seo` (base `origin/main` @ `98bd13c`). This PR changes documentation only; no Dart, TypeScript, rules, or site code changed.

| Workflow job | Local command | Result | Log |
|---|---|---|---|
| flutter | `flutter pub get` | pass | `flutter-pub-get.txt` |
| flutter | `flutter analyze --no-fatal-infos --no-fatal-warnings` + `node tool/check_analyzer_baseline.mjs` | pass — 87 issues, baseline 87 | `flutter-analyze.txt` |
| flutter | `flutter test` | pass — 37 tests | `flutter-test.txt` |
| flutter | `flutter build web --release` | pass | `flutter-build-web.txt` |
| flutter | `flutter pub outdated` (informational) | completed | `flutter-pub-outdated.txt` |
| functions | `npm ci` | pass | `functions-npm-ci.txt` |
| functions | `npm run build` | pass | `functions-build.txt` |
| functions | `npm audit --audit-level=high` | pass — 16 moderate, 0 high/critical | `functions-audit.txt` |
| functions | `npm outdated` (informational, `|| true` in CI) | completed — outdated packages listed | `functions-npm-outdated.txt` |
| rules | `npm run test:rules` with Java 21 (`Android Studio/jbr`) | pass — 8 tests | `rules-test.txt` |
| proof | `node tool/check_pr_proof.mjs` | pass — UI false, backend false | `proof-check.txt` |

Notes:

- The format check has no Dart files to check.
- `flutter build web` and `npm ci` regenerated tracked files under `functions/lib/` and the platform plugin registrants. Those generated changes were reverted before commit; only `docs/evidence/seo-benchmark-2026-11/` is staged.
- `npm outdated` exits 1 when outdated packages exist; the workflow treats it as informational with `|| true`.
- Java 21 was taken from `C:\Program Files\Android\Android Studio\jbr` because the system Java is 1.8.
