# Agent Guidelines — Luna Express

## Branching & Deployment Rules

1. **Never push directly to `main`.**
   - Direct pushes to `main` trigger the automated production deploy workflow (`.github/workflows/firebase-hosting-merge.yml`).
   - Do NOT run manual production deployments (`firebase deploy`) without explicit user instruction.

2. **Always create a Pull Request (PR).**
   - Create a feature or fix branch (e.g., `fix/descriptive-name` or `feature/descriptive-name`).
   - Push to that branch and open a PR against `main` using `gh pr create`.
   - Let the user review and merge the PR when ready.

3. **Verify locally before opening a PR:**
   - Flutter analysis: `flutter analyze --no-fatal-infos --no-fatal-warnings`
   - Flutter tests: `flutter test`
   - Functions build & audit: `cd functions && npm run build && npm audit --audit-level=high`
   - Rules emulator tests (if touching rules): `cd functions && npm run test:rules`
