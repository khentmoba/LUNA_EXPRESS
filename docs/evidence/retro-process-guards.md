# Process guards from the retro

Verified 2026-11-05 on `fix/retro-process-guards`.

Production was read only. The script read the live Firestore ruleset from the Firebase Rules API and listed Cloud Functions. No customer data was read, no rules were deployed, and no function was deleted.

## What changed

- `firestore.rules` now matches the ruleset production serves (`fe894e6c-a23d-4e50-a890-99275b632daf`, updated 2026-09-28). Two differences were removed from the repo copy: the `telegramSent` allowance that broke checkout, and the rules for the removed Pasugo feature are now carried in the repo, so the file matches production exactly.
- `functions/scripts/check-firestore-rules-drift.js` (`npm run check:rules-drift`) fails when `firestore.rules` differs from production. Read only. Runs on push to `main`, daily, and on demand (`.github/workflows/rules-drift.yml`).
- `functions/test/firestore-rules.test.js`: the stale snapshot test is replaced by `create rejects telegramSent`, which runs against the repo rules. The snapshot fixture is deleted.
- `tool/check_pr_proof.mjs` plus a `proof` job in `pr-checks.yml`. It fails a PR that changes UI paths without an inline image, or product paths without a `docs/evidence/` reference.
- `tool/check_analyzer_baseline.mjs` with `tool/analyzer_baseline.txt` (87). The `flutter` job fails when analyzer issues rise above the baseline.
- `firebase-hosting-merge.yml`: the function delete step lists deployed functions first and deletes only those. The `|| true` that hid every failure is gone.
- `AGENTS.md`: `$pr-first` becomes `$file-pr`, the merge rule names the `full send` exception, and the duplicated command list is replaced by a pointer to `pr-checks.yml`.

## Replays against past mistakes

| Guard | Input | Expected | Result |
| --- | --- | --- | --- |
| Rules drift | pre-fix `firestore.rules` (`da2bf4f`) | fail | exit 1, lists the `telegramSent` line and the Pasugo blocks |
| Rules drift | new `firestore.rules` | pass | exit 0, `matches production` |
| Rules tests (emulator, Java 21) | pre-fix rules | the telegramSent test fails | tests 8, pass 7, fail 1: `create rejects telegramSent` |
| Rules tests (emulator, Java 21) | new rules | all pass | tests 8, pass 8, fail 0 |
| Proof | PR #7 (backend, no evidence reference) | fail | exit 1 |
| Proof | PR #14 (UI, no image) | fail | exit 1 |
| Proof | PR #16 (UI, no image) | fail | exit 1 |
| Proof | PR #18 (UI, no image) | fail | exit 1 |
| Proof | PR #20 (has evidence) | pass | exit 0 |
| Proof | PR #21 (has image and evidence) | pass | exit 0 |
| Analyzer | 87 issues, baseline 87 | pass | exit 0 |
| Analyzer | simulated 88 issues | fail | exit 1 |

Other checks: `npm run build` in `functions/` passes. The three workflow files parse as YAML. `functions:list` returns `createCheckoutSession` as deployed and not `noSuchFunctionXYZ`, so the delete step would delete the first and skip the second.

## CI findings

- First CI run: the `flutter` job failed because the analyzer summary line was missing from the captured output. The check exited 2 with "Could not read the analyzer summary line". The analyzer output is now captured with `2>&1`. The CI count is 87, the same as the local count.

## Not verified here

- The drift workflow in GitHub. Its service account needs Firebase Rules read permission. The first run will show whether it has it.
- The analyzer count under CI's `flutter stable`. Local Flutter 3.47.7 reports 87. The PR run shows CI's count.
- The delete-then-deploy path in the hosting workflow. It is exercised on the next merge to `main`.
- Branch protection. It is applied after this PR merges and checked with the GitHub API.

## Found, not changed

- Production still serves Pasugo rules. `pasugo_errands` allows `list` for anyone. The feature was removed from the app in PR #8, but its rules were never removed. Removing them changes production, so it needs explicit approval and is out of scope here.
