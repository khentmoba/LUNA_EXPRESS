# Product Requirements — VacanSee MVP

## Overview
**Product Name:** VacanSee
**Problem Statement:** Finding available boarding house accommodations is inefficient due to manual "walk-around" searching and outdated social media information. This creates "information hunger" for students and leads to redundant inquiries for property owners.
**MVP Goal:** Establish a centralized web-based platform where boarding house owners can update room availability in real-time and students can filter verified listings by budget and location.
**Target Launch:** Academic Year 2025-2026

## Target Users
- **Primary:** University students (USTP) and local boarding house owners in Cagayan de Oro City
- **User Persona (Student):** Alex, 18-22 years old, budget-conscious, mobile-first, seeking affordable room near campus
- **User Persona (Owner):** Maria, boarding house owner, tired of constant inquiries for unavailable rooms

## Must-Have Features (MVP)
1. **Owner Property Listing (CRUD)**
   - Create, read, update, delete property listings
   - Upload room photos
   - Set amenities, price range, gender orientation

2. **Real-Time Vacancy Toggle**
   - One-click status change (Vacant ↔ Occupied)
   - Instant reflection in search results
   - Timestamp tracking for last update

3. **Student Search & Filtering**
   - Filter by budget (min/max price)
   - Filter by location (near campus)
   - Filter by gender orientation (Male/Female/Mixed)
   - View verified listings only

4. **Booking Request Flow**
   - Student sends booking request
   - Owner receives notification
   - Owner confirms/declines availability
   - Student receives response

5. **Authentication**
   - Student registration/login
   - Owner registration/login
   - Role-based access control

## Nice-to-Have Features (Post-MVP)
- In-app messaging between students and owners
- Google Maps integration for visual property search
- Reviews and ratings system
- Gemini AI for automated room descriptions
- Price negotiation feature

## NOT in MVP
- Payment processing
- Advanced analytics dashboard
- Multi-city expansion
- Mobile app (native iOS/Android)

## Success Metrics
1. **Adoption:** 100+ verified properties listed within 3 months
2. **Engagement:** 500+ student registrations in first semester
3. **Accuracy:** 90%+ vacancy status accuracy (owners actively updating)
4. **User Satisfaction:** 4.0+ average rating from user feedback

## UI/UX Requirements
- **Design Words:** Clean, trustworthy, student-friendly
- **Vibe:** Modern, simple, fast
- **Mobile-First:** Optimized for mobile browsers (primary use case)
- **Accessibility:** High contrast for outdoor visibility

## Timeline & Constraints
- **Development Cycle:** 12-16 weeks at ~12 hours/week
- **Budget:** Strictly $0/month (free tiers only)
- **Platform:** Web App (Flutter Web + Firebase)

## User Stories (Core)
1. As a student, I want to filter boarding houses by my budget so I only see affordable options.
2. As a student, I want to see real-time vacancy status so I don't waste time visiting full houses.
3. As an owner, I want to quickly toggle room status so students know what's available.
4. As an owner, I want to manage my property listing so students can find my boarding house.
5. As a student, I want to request a booking so the owner knows I'm interested.
