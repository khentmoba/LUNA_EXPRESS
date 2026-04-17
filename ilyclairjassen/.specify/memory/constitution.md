# Eternal Sanctuary Constitution

## Core Principles

### I. Exclusive Access (The Gatekeeper)
Use birthday-based authentication restricted to Khent (2006-10-26) and Clair Jassen (2006-02-21). Permissions are session-based; no persistent auth tokens outside of the current browser tab to ensure maximum privacy.

### II. Modular Architecture (Scalable Build)
The application MUST follow a modular, feature-based architecture (Vertical Slicing) to ensure scalability and maintainability. A bundler (Vite) is used to manage dependencies, assets, and build processes, moving away from the single-file constraint to support future complexity.

### III. Hybrid Persistence Layer
Global shared data (Memories, Secret Diary) must be synced via Supabase. Local UI state, session authentication, and the Guestbook must use LocalStorage or SessionStorage to maintain privacy and local responsiveness.

### IV. High-Aesthetic Immersive Garden
Prioritize visual excellence and "life-like" interactivity. This includes parallax layering, real-time seasonal themes, weather systems (rain/fog), and physics-based fireflies/butterflies.

### V. Real-Time Reliability
Implement Supabase Realtime SDK for live synchronization between users. A robust 30-second polling fallback must be maintained for environments with restricted WebSocket access.

## Technology Stack & Schema

**Stack**: HTML5, Vanilla JavaScript, Vanilla CSS.
**Remote Services**: Supabase (`qozvdxgkvxfelixuuogb.supabase.co`).
**Database Tables**:
- `memories`: `id, url, description, date, added_by`
- `diary`: `id, title, content, date`
- Storage: `garden-images` bucket.

## Governance & User Rules

**Shared Management**: Both authenticated users (Khent and Clair) have full access to shared resources. Both can add, view, and delete entries in the memories and diary tables.

**Deployment Policy**: Any changes must maintain the ~1MB file size target for optimal performance and portability. Deployment is handled by dropping the `index.html` into the Netlify sanctuary.

## Governance

Amendments to these principles require agreement from both users. This Constitution supersedes any feature request that might compromise the project's core pillars of privacy or portability.

**Version**: 1.0.0 | **Ratified**: 2026-04-17 | **Last Amended**: 2026-04-17

