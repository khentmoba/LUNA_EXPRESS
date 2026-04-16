# System Memory & Context 🧠
<!--
AGENTS: Update this file after every major milestone, structural change, or resolved bug.
DO NOT delete historical context if it is still relevant. Compress older completed items.
-->

## 🏗️ Active Phase & Goal
**Current Task:** Phase 2 - Database schema creation & Property Listing CRUD
**Next Steps:**
1. Create Firestore security rules
2. Set up Firebase project with flutterfire configure
3. Implement property creation flow for owners
4. Implement property list view for students
5. Add image upload functionality

## 📂 Architectural Decisions
*(Log specific choices made during the build here so future agents respect them)*
- [2025-03-25] - Chose Flutter Web + Firebase stack to leverage existing LUNA EXPRESS experience and maximize code reuse
- [2025-03-25] - Using free-tier Firebase Spark plan to maintain $0/month budget
- [2025-03-25] - Flat Firestore structure with Properties collection and Rooms sub-collection for performant filtering

## 🐛 Known Issues & Quirks
*(Log current bugs or weird workarounds here)*
- Flutter Web can have slightly larger initial load times compared to pure HTML/JS, but offers superior "app-like" feel for mobile browsers

## 📜 Completed Phases
- [x] Documentation setup (AGENTS.md, MEMORY.md, agent_docs/)
- [ ] Initial scaffold
- [ ] Database schema creation
- [ ] Auth integration
- [ ] Property listing CRUD
- [ ] Search & filtering
- [ ] Real-time vacancy toggle
- [ ] Booking request flow
