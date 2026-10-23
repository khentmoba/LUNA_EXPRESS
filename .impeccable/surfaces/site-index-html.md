---
version: 1
slug: "site-index-html"
primary_target: "site/index.html"
related_targets: []
---

## Scope

The storefront at the site root (`/`), a hand-written static page. The ordering app stays at `/kiosk/` and is linked into, never duplicated. One route, one artifact, one first viewport.

## Audience, job, action

Hungry people inside delivery range of Purok 5, on phones, arriving from a Facebook link, a shared message, or someone's word. They decide in under a minute: what is this, what does it cost, will it come to me. Walk-ins are secondary and only need the landmark. Action: start the order in the app, or move the fare rail to see what their own distance costs.

## Proof and content

Real prices from `lib/data/menu_data.dart`, real photographs in `images/`, the real fare rule (₱39 a kilometre, priced from the nearer of the two kitchen bases), the real address, the 7/11 landmark, the real Facebook page. No opening hours, no phone number, no ratings, no testimonials — those holes stay open until the owner fills them.

## Constraints

- Mobile-first over slow data: no framework, no icon library, self-hosted fonts only.
- `/kiosk/` keeps its current behaviour exactly; the storefront only links into it.
- Keyboard-operable fare rail, `prefers-reduced-motion` respected, focus rings themed.
- Never invent a fact to fill a hole.

## Chosen direction

Harap ng Jeepney — the storefront painted like the front of a jeepney: destination, fares, and the price board on one enamel panel. Memorable moment: the fare rail is a real instrument — move along it and the needle travels while the fare and distance follow.

## Direction contract

THESIS: The storefront is a painted jeepney panel, not a product page — one enamel ground carrying a destination board, a live fare rail, and the printed price board. It refuses the category arrangement outright: no headline over subcopy, no photo-and-button split hero, no row of equal cards.

OWN-WORLD: Deep coffee enamel `#241A12` as ground, panels a shade darker `#1B130D` with tan hairlines `#E0C9A6`, cream lettering `#F7EEDD` carrying a hand-painted bevel, and one vermilion `#D8452A` held back for whatever is live. Condensed painted caps (Big Shoulders Display) against Karla for prose; prices in tabular figures. Dividers are chrome gradients, never plain borders. Every photograph is mounted with a painted outline and a hand-painted tag naming the dish and its price.

STORY: Understands in one look — food from Purok 5, delivered, ₱39 a kilometre, every price printed. Believes the prices and the fare are computed, not marketed. Does one of two things: taps the vermilion plate to order, or moves the fare rail to see what their own address costs before deciding.

FIRST VIEWPORT: The painted wordmark and delivery sentence lead into a large mounted shawarma photo tagged ₱60 each and the vermilion Order plate with the payment line. Desktop pairs the introduction and actions with the food photo; phones use introduction, food, then actions in DOM order, with a compact wordmark. The delivery fare rail sits behind a native Estimate delivery disclosure, initially closed, beneath the ordering actions. The rate remains visible before opening it. Persistent Prices, Photos and Find us shortcuts sit beside Order in the phone header. The price board follows without the expanded calculator delaying it.

FORM: Harap ng Jeepney, fifth of seven on my resonance-ordered list; seed:06d2122ba9ef1f29

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance

## Unresolved

Opening hours and a contact number are coming from the owner later; until then the page says nothing about either. Whether the fare rail should read distance or barangay is settled as distance, because the app itself prices by pinned coordinates rather than named zones.
