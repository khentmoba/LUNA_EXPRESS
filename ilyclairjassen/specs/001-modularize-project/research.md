# Research: Modularization Architecture

## Decisions

### 1. Build Tool: Vite 5.x
- **Decision**: Use Vite with the `vanilla` template.
- **Rationale**: Vite provides extremely fast development speeds, built-in support for ES modules, CSS splitting, and asset optimization. It is perfect for a "Vanilla spirit" project that needs professional developer experience.
- **Alternatives Considered**: 
    - **Vanilla ES Modules**: Too slow for many files; production optimization is manual.
    - **Webpack**: Overly complex for this project size.

### 2. Refactoring Standards (FR-006)
- **Decision**: All migrated code MUST follow modern ES6+ standards.
- **Standards**:
    - **Naming**: Use `camelCase` for variables and functions. Avoid short names (e.g., rename `s` to `supabaseClient`).
    - **Syntax**: Replace `var` with `let`/`const`, use arrow functions for callbacks, and template literals for string concatenation.
    - **Modularity**: Use `export` / `import` statements; avoid global variables.

### 3. Environment Variables (FR-007)
- **Decision**: Use `import.meta.env` for Supabase keys.
- **Standard**: Keys should be prefixed with `VITE_` (e.g., `VITE_SUPABASE_URL`) to be exposed to the client-side code.

### 4. Organization: Vertical Slicing

### 2. Organization: Vertical Slicing
- **Decision**: Group code by feature (e.g., `src/features/garden/`) containing both JS and CSS.
- **Rationale**: Directly solves the user's request for future-proofing. Each feature is self-contained and easier to "slice out" or extend.

### 3. Asset Extraction
- **Decision**: Extract base64 images from `index.html` into PNG/JPG files in `public/assets/`.
- **Rationale**: Reduces the main JS/HTML payload size significantly and allows better browser caching.

## Unknowns Resolved

- **Supabase Integration**: We will continue using the Supabase CDN/Library. For better modularity, we will create a `shared/api/supabase.js` client.
- **Deployment**: Vite outputs a `dist/` folder which is perfectly compatible with Netlify's "drag and drop" or automated Git-based deployment.
