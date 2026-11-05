# Functions runtime: Node 22, and no delete before deploy

## Incident (2026-11-05)

Merging PR #22 ran `Deploy to Firebase on merge` on `main` (run `42006109604`).

1. The "Delete conflicting functions" step deleted `createCheckoutSession` and `paymongoWebhook`. It succeeded.
2. "Deploy Cloud Functions" failed: `Runtime Node.js 20 was decommissioned on 2026-10-30. To deploy you must first upgrade your runtime version.`
3. Read-only `functions:list` afterwards: `createCheckoutSession` and `paymongoWebhook` were missing. The other nine functions were still deployed on `nodejs20`.

The last successful deploy was on 2026-10-29 (`dd0b1bd`), before the Node 20 decommission. Every merge to `main` after 2026-10-30 would have failed the same way. The delete step made each failure destructive.

## Runtime facts

From the Firebase CLI's runtime table (`firebase-tools` 15, `lib/deploy/functions/runtimes/supported/types.js`):

| Runtime | Deprecation | Decommission |
| --- | --- | --- |
| nodejs20 | 2026-04-30 | 2026-10-30 (blocks deploy) |
| nodejs22 | 2027-04-30 | 2028-10-31 |
| nodejs24 | 2028-04-30 | 2028-10-31 |

## Change

- `functions/package.json` `engines.node` moves from `20` to `22`, which sets the deployed runtime.
- CI uses Node 22 in every workflow that installs or builds `functions/`.
- The pre-deploy delete step is removed. A deploy that fails after a delete leaves the functions missing. `deploy --force` removes only functions that are no longer in source.
- The service account file is written inside the deploy step, which no longer depends on the deleted step.

## Verification

- `functions`: `npm run build` and `npm test` pass on Node 24 (16 of 16 tests).
- All four workflow files parse as YAML. No workflow contains the delete step.
- Post-merge checks are recorded in the PR thread: the deploy result and `functions:list` showing both functions present on `nodejs22`.
