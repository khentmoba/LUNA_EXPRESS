# Testing Strategy

## Frameworks
- **Unit Tests:** Flutter test framework (`flutter test`)
- **Widget Tests:** Flutter widget testing
- **Integration Tests:** `integration_test` package for E2E flows

## Rules & Requirements
- **Coverage:** Aim for 70%+ code coverage on critical paths (auth, vacancy toggle, search)
- **Before Commit:** Always run `flutter test` before verifying a task is complete
- **Failures:** NEVER skip tests or mock out assertions to make a pipeline pass without Human approval. If an Agent breaks a test, the Agent must fix it.

## Execution
- **Run all tests:** `flutter test`
- **Run specific test file:** `flutter test test/path/to/test_file_test.dart`
- **Run with coverage:** `flutter test --coverage`

## Test Categories

### Unit Tests (Critical)
- Property model serialization/deserialization
- Price filtering logic
- Vacancy status transitions
- Repository error handling

### Widget Tests (Required)
- Login/Register screens
- Property listing cards
- Search filter components
- Vacancy status badges

### Integration Tests (Core Flows)
1. **Student Registration → Search → Booking Request**
2. **Owner Login → Create Property → Toggle Vacancy**
3. **Full booking request/response cycle**

## Manual Verification Checklist
- [ ] Real-time vacancy updates reflect immediately in search
- [ ] Image uploads work correctly
- [ ] Filters return expected results
- [ ] Mobile viewport renders correctly
- [ ] Authentication persists across sessions
