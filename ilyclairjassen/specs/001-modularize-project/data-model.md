# Data Model: Modular Architecture

## Entities

### Global State (Supabase)
| Field | Type | Description |
|-------|------|-------------|
| `memories` | Table | ID, URL, description, date, added_by |
| `diary` | Table | ID, title, content, date |

### Local State (Browser)
| Field | Type | Storage |
|-------|------|---------|
| `session` | Object | SessionStorage (Auth state) |
| `guestbook` | Array | LocalStorage (Notes) |
| `ui_preferences` | Object | LocalStorage (Theme/Weather toggle) |

### Feature Module (Vertical Slice)
Each feature directory MUST contain:
- `index.js`: Main logic export.
- `styles.css`: Scoped feature styles.
- `constants.js`: Strings, configuration.
- `api.js`: (Optional) Supabase interactions for the feature.
