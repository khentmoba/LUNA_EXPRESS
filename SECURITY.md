# Security Checklist (1–20) — Luna Express

How each item is enforced, and the manual steps that can't live in code.

## In code (done)

| # | Item | Where |
|---|------|-------|
| 1 | Hide API keys | `functions/src/index.ts` — `TELEGRAM_*` + `PAYMONGO_SECRET_KEY` are Secret Manager secrets, never client-visible. Deploy: `firebase functions:secrets:set <NAME>` for each. |
| 3 | Public DB key | Firebase web `apiKey` in `lib/firebase_options.dart` is public by design; access is enforced by rules + App Check, not by hiding it. Restrict it anyway (below). |
| 4,7 | Row-level security / record access | `firestore.rules` — default deny, per-collection rules, participant-only chat reads. |
| 5 | Encrypt sensitive data | At rest: Google-managed encryption (Firestore/Auth/Storage). In transit: TLS everywhere. PII stripped from logs; `login_attempts` keys are hashed. |
| 6,9 | Server-side auth / sessions | Staff login returns a Firebase custom token w/ `role` claim (`verify_staff.ts`); KDS/analytics/report callables `requireStaff()`. No more forgeable `{success:true}` sessions. |
| 8 | Block field tampering | Rules use `hasOnly()` allowlists + a status state-machine; `create_checkout.ts` re-prices every line from a server menu and rejects amount mismatches; webhook re-verifies PAID via PayMongo API. |
| 10 | Hash passwords | Staff: scrypt + per-user salt (`security.ts`); legacy sha256 auto-upgrades on next login. Riders: Firebase Auth (bcrypt/scrypt managed). First-run seed uses random passwords logged once — rotate after first login. |
| 11 | Rate limit login | `checkRateLimit()` — 5 failures → 15-min lockout (Firestore-backed). |
| 12 | Bot protection | App Check wired in `lib/main.dart` (`--dart-define=RECAPTCHA_V3_KEY=…`); enable enforcement in console (below). |
| 13 | Parameterize queries | Firestore SDK (no string-built queries); doc IDs allowlisted `^[A-Za-z0-9_-]+$`; webhook/coordinate inputs type-checked. |
| 14 | Validate all input | Server: `cleanStr/optStr/cleanInt/validDocId` on every callable. Client: `lib/utils/validate.dart` on auth forms. |
| 15 | Escape user content | Flutter `Text` auto-escapes; Telegram uses `escapeMd()`; GCash WebView has a host allowlist; map HTML interpolates numbers only. |
| 16 | Restrict uploads | `storage.rules` — owner-only `riders/{uid}/*`, images, <5MB, no delete. |
| 17 | Trim API responses | KDS returns a fixed projection (no `...data`); error messages generic; provider errors not leaked. |
| 18,19 | Headers / HTTPS | `firebase.json` — HSTS, nosniff, DENY framing, Referrer/Permissions-Policy. Hosting is HTTPS-only by default. |
| 20 | Scan dependencies | CI (`.github/workflows/pr-checks.yml`): `npm audit --audit-level=high`, `flutter pub outdated` + full test/build gate. Run locally: `cd functions && npm audit`, `flutter pub outdated`. |

## Manual steps (Firebase Console — do once)

1. **Secrets**: `firebase functions:secrets:set TELEGRAM_TOKEN|TELEGRAM_CHAT_ID|PAYMONGO_SECRET_KEY`, then deploy functions.
2. **Restrict the web API key** (#3): Google Cloud Console → APIs & Services → Credentials → Browser key → HTTP referrers: `lunaexpress.web.app/*`, `lunaexpress.firebaseapp.com/*`.
3. **App Check** (#12): Firebase Console → App Check → register web app (reCAPTCHA v3) → build with `--dart-define=RECAPTCHA_V3_KEY=<site-key>` → switch Firestore/Functions enforcement ON.
4. **Rotate**: seeded staff passwords (see function logs), plus any PayMongo/Telegram secret that ever appeared in chat or shell history.

## #2 Purge git secrets

No private secrets were found in history (only the public Firebase web key, which is safe to keep).
If a real secret ever lands in git:

```bash
# 1. Revoke/rotate the secret FIRST (history rewrites don't un-leak it).
# 2. Purge it:
git filter-repo --replace-text <(echo 'SECRET_VALUE==>***REMOVED***') --force
# 3. Force-push + tell collaborators to re-clone.
```

Prevention: `.env`/`functions/.env` are gitignored; secrets live in Secret Manager, never in code.
