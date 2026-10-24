# Agent Guidelines — Luna Express

## Business Reference

- **Business:** Luna Bites & Delights — food & drink kiosk (good food, sweet drinks, moonlit vibes).
- **Facebook Page:** https://www.facebook.com/profile.php?id=100090686762896
  (canonical: https://www.facebook.com/p/Luna-Bites-Delights-100090686762896/)
  Use this page as the source of truth for brand copy, the intro/blurb, contact details, and
  promotional posts. Copy and photos posted there are what the landing page should showcase.
- **Location:** Purok 5, Poblacion Magallanes, Agusan Del Norte (near 7/11), Philippines.

## Subagents & Delegation

- **Do not use subagents or delegate work unless the user explicitly asks you to.** Complete implementation, research, testing, reviews, and documentation yourself by default.
- Invoking a skill, including `$impeccable`, does **not** authorize subagents. If a skill calls for delegated work, perform that step yourself unless the user explicitly authorizes delegation.

## UI Work

- **Always use the `$impeccable` skill for UI work**, including design, implementation, review, and changes to layout, styling, copy, motion, accessibility, or responsive behavior in the storefront or Flutter app. Read its `SKILL.md` from the available skill catalog before starting.
- Follow the applicable Impeccable workflow and the existing `PRODUCT.md`, `DESIGN.md`, and surface brief. Verify UI changes in the rendered app at the screen sizes they support before handing them off.

## Branching & Deployment Rules

1. **Never push directly to `main`.**
   - Direct pushes to `main` trigger the automated production deploy workflow (`.github/workflows/firebase-hosting-merge.yml`).
   - Do NOT run manual production deployments (`firebase deploy`) without explicit user instruction.

2. **Always create a Pull Request (PR).**
   - Always use the `$pr-first` skill when making PRs.
   - Create a feature or fix branch (e.g., `fix/descriptive-name` or `feature/descriptive-name`).
   - Push to that branch and open a PR against `main` using `gh pr create`.
   - Let the user review and merge the PR when ready.

3. **Verify locally before opening a PR:**
   - Flutter analysis: `flutter analyze --no-fatal-infos --no-fatal-warnings`
   - Flutter tests: `flutter test`
   - Functions build & audit: `cd functions && npm run build && npm audit --audit-level=high`
   - Rules emulator tests (if touching rules): `cd functions && npm run test:rules`
