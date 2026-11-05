# Local CI checks — SEO foundations

Run on 2026-11-05 against `fix/seo-foundations` (base `origin/main` @ `98bd13c`).

| Workflow job | Local command | Result | Log |
|---|---|---|---|
| flutter | `flutter analyze --no-fatal-infos --no-fatal-warnings` + `node tool/check_analyzer_baseline.mjs` | pass — 87 issues, baseline 87 | `flutter-analyze.txt`, `analyzer-baseline.txt` |
| flutter | `flutter test` | pass — 37 tests | `flutter-test.txt` |
| flutter | `flutter build web --release` | pass | `flutter-build-web.txt` |
| functions | `npm run build` | pass | `functions-build.txt` |
| functions | `npm audit --audit-level=high` | pass — 16 moderate, 0 high/critical | `functions-audit.txt` |
| rules | `npm run test:rules` with Java 21 (`Android Studio/jbr`) | pass — 8 tests | `rules-test.txt` |
| proof | `node tool/check_pr_proof.mjs` | pass — UI true, backend false | `proof-check.txt` |

Notes:

- The first rules run failed because a leftover local HTTP server held port 8080, which the Firestore emulator needs. After stopping the local servers, the rerun passed 8/8. This was an environment conflict, not a rules failure.
- `flutter build web` and `npm run build` regenerated tracked files under `functions/lib/` and the platform plugin registrants. Those generated changes were reverted before commit.
- Java 21 was taken from `C:\Program Files\Android\Android Studio\jbr` because the system Java is 1.8.
