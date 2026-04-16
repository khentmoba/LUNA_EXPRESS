# Artifact Review Checklist 🔍

> **AGENTS:** Do not mark a feature or task as "Complete" until you verify these checks manually or via automated test runs. Provide terminal logs or browser testing results as proof. 
> **HUMANS:** Use this checklist before merging Agent-generated code.

## Code Quality & Safety
- [ ] No `dynamic` types used (or strictly justified with proper type handling).
- [ ] Protected files/directories (like Firebase security rules or migrations) were NOT modified without permission.
- [ ] No existing, unrelated tests were deleted or skipped.
- [ ] Component/Function is modular and doesn't violently break established architecture boundaries.

## Execution & Testing
- [ ] Application compiles without fatal errors (`flutter analyze` passes).
- [ ] Widget tests pass (`flutter test`).
- [ ] UI is decently responsive across Desktop and Mobile viewports.
- [ ] Real-time features work correctly (vacancy status updates).

## Artifact Handoff
- [ ] The `MEMORY.md` file was updated with any new architectural decisions made during this task.
- [ ] Any obsolete spec files in the workspace have been marked as resolved or archived.
