# Project Brief

- **Product vision:** Real-time boarding house vacancy tracker for university students in Cagayan de Oro City
- **Target Audience:** USTP students (18-22 years old, mobile-first) and boarding house owners in CDO

## Core Value Proposition
Students waste hours visiting "full" houses; owners are interrupted by constant inquiries. VacanSee provides **real-time accuracy** so users gain immediate certainty about vacancy status without traveling or making phone calls.

## Conventions
- **Naming:** snake_case for files, PascalCase for classes/widgets, camelCase for variables
- **File Structure:** Feature-based organization (models, providers, services, screens, widgets)
- **State Management:** Provider or Riverpod for global state
- **Code Style:** Follow Effective Dart guidelines

## Key Principles
- Ship the simplest possible solution that solves the user story
- Real-time vacancy status is THE core feature—everything else supports this
- Mobile-first design (students are mobile-first users)
- Free-tier budget constraint ($0/month)
- If a simpler Firebase integration exists, use it

## User Roles
1. **Student Tenant:** Browse, filter, request booking
2. **Property Owner:** Manage listings, toggle vacancy status, respond to booking requests

## Must-Have Features (MVP)
1. Owner property listing (CRUD)
2. Real-time vacancy toggle
3. Student search with filters (budget, location, gender)
4. Booking request flow
5. Basic authentication (Student/Owner roles)

## Nice-to-Have (Post-MVP)
- In-app messaging
- Google Maps integration
- Reviews and ratings
- Gemini AI room description generation

## NOT in MVP
- Payment processing
- Advanced analytics dashboard
- Multi-city expansion
