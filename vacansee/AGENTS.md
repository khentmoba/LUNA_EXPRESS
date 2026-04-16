# AGENTS.md — Master Plan for VacanSee

## Project Overview & Stack
**App:** VacanSee
**Overview:** A real-time boarding house vacancy tracker for university students in Cagayan de Oro City. Students can filter verified listings by budget, location, and gender orientation while property owners update room availability in real-time.
**Stack:** Flutter Web + Firebase (Auth, Firestore, Storage, Hosting)
**Critical Constraints:** 
- Mobile-first design required (university students are mobile-first users)
- Real-time vacancy status is the core value proposition
- Strictly free-tier budget ($0/month)
- Target launch: Academic Year 2025-2026

## Setup & Commands
Execute these commands for standard development workflows. Do not invent new package manager commands.
- **Setup:** `flutter pub get`
- **Development:** `flutter run -d chrome` (web) or `flutter run` (mobile)
- **Testing:** `flutter test`
- **Linting & Formatting:** `dart analyze` or `flutter analyze`
- **Build:** `flutter build web`

## Protected Areas
Do NOT modify these areas without explicit human approval:
- **Infrastructure:** Firebase project configuration, security rules
- **Database Schema:** Existing Firestore collections and sub-collections
- **Third-Party Integrations:** Firebase Auth configurations, Gemini API keys

## Coding Conventions
- **Formatting:** Follow Dart/Flutter style guide. Use `dart format` before commits.
- **Architecture rules:** Use feature-based folder organization. Keep widgets dumb, logic in providers/services.
- **Testing Expectations:** All new utilities must have unit tests. Core user flows require widget tests.
- **Type Safety:** Use strict Dart typing. Avoid `dynamic`; define precise models.

## Agent Behaviors
These rules apply across all AI coding assistants (Cursor, Copilot, Claude, Gemini, Windsurf):
1. **Plan Before Execution:** ALWAYS propose a brief step-by-step plan before changing more than one file.
2. **Refactor Over Rewrite:** Prefer refactoring existing functions incrementally rather than completely rewriting large blocks of code.
3. **Context Compaction:** Write states to `MEMORY.md` or a `spec.md` instead of filling context history during long sessions.
4. **Iterative Verification:** Run tests or linters after each logical change. Fix errors before proceeding (See `REVIEW-CHECKLIST.md`).
5. **Team Coordination:** If working in Agent Teams, require the Team Lead to approve teammate PRs or plans.

## How I Should Think
1. **Understand Intent First:** Before answering, identify what the user actually needs
2. **Ask If Unsure:** If critical information is missing, ask before proceeding
3. **Plan Before Coding:** Propose a plan, ask for approval, then implement
4. **Verify After Changes:** Run tests/linters or manual checks after each change
5. **Explain Trade-offs:** When recommending something, mention alternatives

## What NOT To Do
- Do NOT delete files without explicit confirmation
- Do NOT modify database schemas without backup plan
- Do NOT add features not in the current phase
- Do NOT skip tests for "simple" changes
- Do NOT bypass failing tests or pre-commit hooks
- Do NOT use deprecated libraries or patterns

## Engineering Constraints

### Type Safety (No Compromises)
- The `dynamic` type is FORBIDDEN—use proper models with type safety
- All function parameters and returns must be typed
- Use freezed/json_serializable for model serialization

### Architectural Sovereignty
- Widgets handle UI ONLY
- All business logic goes in `providers/` or `services/`
- No direct Firestore calls from widgets—use repositories

### The "No Apologies" Rule
- Do NOT apologize for errors—fix them immediately
- Do NOT generate filler text before providing solutions
- If context is missing, ask ONE specific clarifying question

### Workflow Discipline
- Run `flutter analyze` before marking tasks complete
- If verification fails, fix issues before continuing
