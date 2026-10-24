---
version: 1
slug: "site-index-html"
primary_target: "site/index.html"
related_targets: []
---

## Scope

The storefront at the site root (`/`), a hand-written static page. The ordering app stays at `/kiosk/` and is linked into, never duplicated. One route, one artifact, one first viewport.

## Audience, job, action

Hungry people inside delivery range of Purok 5, on phones, arriving from a Facebook link, a shared message, or someone's word. They decide in under a minute: what is this, what does it cost, will it come to me. Walk-ins are secondary and only need the landmark. Action: start the order in the app, with a clear notice that the rider confirms the separate delivery fee.

## Proof and content

Real prices from `lib/data/menu_data.dart`, real photographs in `images/`, the rider-confirmed delivery-fee policy, the real address, the 7/11 landmark, the real Facebook page. Opening hours are 9am to 8pm. No phone number, no ratings, no testimonials — those holes stay open until the owner fills them.

## Constraints

- Mobile-first over slow data: no framework, no icon library, self-hosted fonts only.
- `/kiosk/` keeps its current behaviour exactly; the storefront only links into it.
- Delivery-fee notice visible without interaction; `prefers-reduced-motion` respected and focus rings themed.
- Never invent a fact to fill a hole.

## Chosen direction

Harap ng Jeepney — the storefront painted like the front of a jeepney: destination, fares, and the price board on one enamel panel. The former fare calculator is replaced by a static delivery-fee notice, per the owner’s policy.

## Direction contract

THESIS: The storefront is a painted jeepney panel, not a product page — one enamel ground carrying a destination board, a clear delivery notice, and the printed price board. It refuses the category arrangement outright: no headline over subcopy, no photo-and-button split hero, no row of equal cards.

OWN-WORLD: Deep coffee enamel `#241A12` as ground, panels a shade darker `#1B130D` with tan hairlines `#E0C9A6`, cream lettering `#F7EEDD` carrying a hand-painted bevel, and one vermilion `#D8452A` held back for whatever is live. Condensed painted caps (Big Shoulders Display) against Karla for prose; prices in tabular figures. Dividers are chrome gradients, never plain borders. Every photograph is mounted with a painted outline and a hand-painted tag naming the dish and its price.

STORY: Understands in one look — food from Purok 5, delivered, food prices printed, delivery quoted by the rider. Taps the vermilion plate to order.

FIRST VIEWPORT: The painted wordmark and delivery sentence lead into a large mounted shawarma photo tagged ₱60 each and the vermilion Order plate with the payment line. Desktop pairs the introduction and actions with the food photo; phones use introduction, food, then actions in DOM order, with a compact wordmark. A static delivery-fee notice sits beneath the ordering actions. It says that the rider confirms the amount separately from food. Persistent Prices, Photos and Find us shortcuts sit beside Order in the phone header. The price board follows the compact delivery notice.

FORM: Harap ng Jeepney, fifth of seven on my resonance-ordered list; seed:06d2122ba9ef1f29

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance

## Price board redesign

The price board is a scoped Persuade section redesign within the established storefront world. The user's request is a stronger price board; the surrounding storefront and ordering app keep their existing composition and behavior.

THESIS: A printed kiosk menu with confident price hierarchy replaces the low-contrast, uniformly small list.

OWN-WORLD: Existing cream, coffee enamel and vermilion plate; square edges, Big Shoulders signage and Karla speech. One continuous cream menu panel meets a full-width vermilion meal strip.

STORY: Scan categories, compare food prices, see the two ₱99 meals, then open the ordering app. All 17 item rows and both meal offers retain their names, amounts and qualifications.

FIRST VIEWPORT: Within this section, a large Price board heading and full-menu link lead into three cream columns at desktop widths. At 940px and below, the categories form one continuous vertical menu. Item names use readable Karla; larger condensed figures align right. The meal strip keeps each offer name and ₱99 together above its description on compact screens. No new animation or assets.

FORM: A local printed-menu composition inherited from the established world; no new direction roll applies.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance

## Unresolved

Opening hours are 9am to 8pm. A contact number is still coming from the owner; until then the page says nothing about it. The rider confirms delivery charges; the site does not publish a numeric rate.
