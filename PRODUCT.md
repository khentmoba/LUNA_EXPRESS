# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Stack

Two surfaces in one Firebase Hosting deploy:

- `/` — a hand-written static HTML/CSS/JS storefront (`site/`), no framework.
- `/kiosk/` — the existing Flutter web ordering app, built with `--base-href /kiosk/`.

`tool/assemble_site.dart` moves the Flutter build into `build/web/kiosk/` and copies `site/` to the root of `build/web/`.

## Users

People around Magallanes, Agusan del Norte who want Luna food brought to them. Delivery is the dominant use; walk-in decisions are secondary. They arrive from a Facebook post, a shared link, or word of mouth, usually on a phone, usually hungry and deciding fast. They want to know what the food is, what it costs, and whether it can come to their house.

## Product Purpose

Order Luna Bites & Delights for delivery or pick-up without talking to anyone. The storefront says what the kiosk is, what it serves and what it costs; the kiosk app takes the order. Success is a delivery order placed from a phone.

## Positioning

A neighbourhood kiosk with the prices printed where you can see them: real per-item pricing, buy-1-take-1 burgers and hotdogs, and a separate delivery fee whose amount is confirmed by the rider. The ordering system is the business's own app, not a marketplace listing.

## Operating Context

- Physical kiosk at Purok 5, Poblacion Magallanes, Agusan Del Norte; the landmark people actually use is "unahan lang gamay sa 7/11".
- A second kitchen base exists northeast of the kiosk; distance is recorded from the nearer base. The delivery rider confirms the delivery fee.
- Payment is cash or GCash at the kiosk/on delivery.
- Staff run the same app on a tablet in the store: dashboard, kitchen display, analytics.
- Facebook is the business's main channel for announcements: https://www.facebook.com/profile.php?id=100090686762896

## Capabilities and Constraints

- Menu sections: Shawarma Favorites, French Fries, Combo Meals, Extras, Refreshments (coolers), Burger & Hotdog Sandwich (buy 1 take 1).
- Prices live in `lib/data/menu_data.dart`; the storefront must not drift from them.
- Delivery fee: rider-confirmed and charged separately. The storefront, checkout and receipt show a delivery-fee notice without quoting an amount. Checkout totals and online payments cover food only.
- Checkout supports cash and GCash; staff verify orders in the dashboard.
- Routes in the kiosk app: `/menu`, `/cart`, `/checkout_process`, `/kds`, `/analytics`, `/pasugo/*`.
- Undecided: opening hours and a contact phone number. The owner will supply them later. Do not invent either.

## Brand Commitments

- Name: Luna Bites & Delights. The owner also uses "Luna Express" for the ordering system.
- Tagline in the owner's own words: "Good food, sweet drinks, moonlit vibes."
- Intro copy from the Facebook page: "Tambayan ng good food, sweet drinks, at moonlit vibes 🌕✨ Feel the comfort, taste the delight — only at Luna Bites & Delights 💛 Located @ Purok 5, Magallanes, Agusan Del Norte."
- Existing palette comes from `KioskTheme`: brown `#4A3728`, dark brown `#2D2014`, tan `#DEC995`, cream `#F9F1E7`, warm white `#FFFAF5`.
- Logo: `images/luna_logo.png`, a gold crescent on a tan ground.

## Evidence on Hand

- Real product photography in `images/` (shawarma wrap, fries, burger, halo-halo, three large coolers, couple snack combo, and more) — the kiosk's own menu assets.
- Real prices and item descriptions in `lib/data/menu_data.dart`.
- Public Facebook figures as of capture: 866 followers, 270 talking about this.
- No testimonials, reviews, awards, or press exist. Do not fabricate any.

## Product Principles

1. Price before poetry. Every claim on the storefront is a fact from the menu or the delivery code.
2. Delivery is the default path; walk-in is the fallback. The primary action always starts an order.
3. Talk like the kiosk talks — warm, local, a little Bisaya, no corporate voice.
4. The app is proof. Real screens and real prices outperform stock marketing copy.
5. Leave holes where the facts are missing rather than filling them with filler.

## Accessibility & Inclusion

Baseline for a public page on low-end Android phones over mobile data: readable contrast on every text/background pair, visible keyboard focus, and motion that respects `prefers-reduced-motion`. No specific standard was mandated.
