Technical Design Document: VacanSee MVP1. Executive SummaryThis document outlines the technical implementation of VacanSee, a real-time boarding house vacancy tracker. Given your experience with Flutter and Firebase for "LUNA EXPRESS," we will leverage that same stack to build a responsive Web App. This approach minimizes your learning curve while meeting the PRD requirement for a mobile-first university tool.2. Recommended ApproachPrimary Path: Flutter Web + Firebase (Low-Code/AI Assisted)Why it's perfect for you: You are already a CpE student familiar with the Flutter/Firebase ecosystem. Using Cursor as your AI-first IDE will allow you to generate code quickly while maintaining control over the logic.What it costs: Strictly $0/month initially by staying within the Firebase Spark (Free) Plan.Time to MVP: 12–16 weeks, dedicating roughly 12 hours per week.Limitations: Flutter Web can have slightly larger initial load times compared to pure HTML/JS, but it offers a superior "app-like" feel for mobile browsers.3. Technical StackLayerTechnologyReasonFrontendFlutter WebHigh code reuse from your existing mobile knowledge.BackendFirebase AuthHandles secure student and owner logins.DatabaseCloud FirestoreReal-time vacancy updates and complex filtering.StorageFirebase StorageHosting property and room photos.HostingFirebase HostingFree SSL and fast global delivery for the web app.AI IntegrationGemini API (Free)Automated room description generation or moderation.4. Database Schema (Firestore)To support the Search & Filtering requirements, we will use a flat, performant structure:
// Properties Collection
{
  "propertyId": "string",
  "ownerId": "string",
  "name": "string",
  "location": "geopoint",
  "genderOrientation": "enum[Male, Female, Mixed]",
  "amenities": ["wifi", "laundry", "ac"],
  "priceRange": { "min": 3000, "max": 5000 },
  "isVerified": boolean,
  "lastUpdated": timestamp
}

// Rooms Sub-collection (Inside Property)
{
  "roomId": "string",
  "status": "enum[Vacant, Occupied]", // The Critical Toggle
  "images": ["url1", "url2"],
  "capacity": number
}
5. AI Assistance StrategyYou will use a Planner-Executor-Reviewer loop to build features:TaskAI ToolExample Prompt for CursorUI ComponentsCursor"Generate a Flutter 'RoomCard' widget showing price, gender tag, and a red 'Occupied' or green 'Vacant' badge."Backend LogicClaude"Write a Firebase Firestore query to filter properties by 'Male' orientation and price under 4000."AI FeaturesGemini"Create a function that uses the Gemini API to scan uploaded room photos for prohibited content."6. Cost Breakdown (Monthly)ServiceFree TierExpected CostFirebase50k reads/day, 5GB storage$0.00Cursor IDE2000 code completions/mo$0.00 (Free version)Gemini API15 RPM / 1M TPM$0.00Vercel/HostingUnlimited Personal use$0.00Total$0.007. Verification EchoLet me confirm I understand your technical requirements:Project: VacanSee MVP for the USTP community.Platform: Web App (Mobile-optimized).Tech Approach: Low-code with AI (Cursor + Flutter/Firebase).Budget: Strictly Free tiers (utilizing your card for verification if needed).Timeline: 12 weeks at 12 hours/week.Main Goal: AI writes the code, and you handle the testing and implementation.