---
name: Luna Bites & Delights — Storefront
description: A jeepney-fare-board storefront for a Magallanes food kiosk, painted in enamel and chrome.
colors:
  enamel: "#241a12"
  enamel-deep: "#170f07"
  panel: "#2c2016"
  board: "#1b130d"
  line: "#4a3728"
  line-soft: "rgba(203, 191, 168, 0.22)"
  tan: "#e0c9a6"
  tan-dim: "#b39c7c"
  cream: "#f7eedd"
  vermilion: "#d8452a"
  vermilion-plate: "#a3301a"
  vermilion-deep: "#8a2a18"
  ink: "#0f0906"
typography:
  display:
    fontFamily: "Big Shoulders Display, Haettenschweiler, Arial Narrow, sans-serif"
    fontSize: "clamp(3.7rem, 10.2vw, 6rem)"
    fontWeight: 900
    lineHeight: 0.78
    letterSpacing: "0.002em"
  display-md:
    fontFamily: "Big Shoulders Display, Haettenschweiler, Arial Narrow, sans-serif"
    fontSize: "clamp(1.7rem, 3.2vw, 2.3rem)"
    fontWeight: 800
    lineHeight: 1.02
    letterSpacing: "0.01em"
  label:
    fontFamily: "Karla, ui-sans-serif, system-ui, sans-serif"
    fontSize: "clamp(0.74rem, 1vw, 0.86rem)"
    fontWeight: 700
    lineHeight: 1.2
    letterSpacing: "0.16em"
  body:
    fontFamily: "Karla, ui-sans-serif, system-ui, sans-serif"
    fontSize: "clamp(16px, 1.05vw, 17px)"
    fontWeight: 400
    lineHeight: 1.55
    letterSpacing: "normal"
  price-board-title:
    fontFamily: "Big Shoulders Display, Haettenschweiler, Arial Narrow, sans-serif"
    fontSize: "clamp(3.6rem, 7vw, 6rem)"
    fontWeight: 900
    lineHeight: 0.9
  price-board-category:
    fontFamily: "Big Shoulders Display, Haettenschweiler, Arial Narrow, sans-serif"
    fontSize: "clamp(1.8rem, 2.7vw, 2.5rem)"
    fontWeight: 800
    lineHeight: 1
  price-board-name:
    fontFamily: "Karla, ui-sans-serif, system-ui, sans-serif"
    fontSize: "1rem"
    fontWeight: 600
    lineHeight: 1.35
  price-board-price:
    fontFamily: "Big Shoulders Display, Haettenschweiler, Arial Narrow, sans-serif"
    fontSize: "2rem"
    fontWeight: 800
    lineHeight: 1
  price-board-offer-name:
    fontFamily: "Big Shoulders Display, Haettenschweiler, Arial Narrow, sans-serif"
    fontSize: "clamp(1.65rem, 2.4vw, 2rem)"
    fontWeight: 800
    lineHeight: 1
  price-board-offer-price:
    fontFamily: "Big Shoulders Display, Haettenschweiler, Arial Narrow, sans-serif"
    fontSize: "clamp(3.2rem, 5vw, 4rem)"
    fontWeight: 900
    lineHeight: 0.95
  price-board-offer-body:
    fontFamily: "Karla, ui-sans-serif, system-ui, sans-serif"
    fontSize: "0.95rem"
    fontWeight: 400
    lineHeight: 1.5
  menu-heading:
    fontFamily: "BigShoulders"
    fontSize: "36px"
    fontWeight: 800
    lineHeight: 1.08
  menu-item-heading:
    fontFamily: "BigShoulders"
    fontSize: "32px"
    fontWeight: 800
    lineHeight: 1.08
  menu-body:
    fontFamily: "Karla"
    fontSize: "16px"
    lineHeight: 1.4
  menu-product-name:
    fontFamily: "Karla"
    fontSize: "16px"
    fontWeight: 700
    lineHeight: 1.2
  menu-price-control:
    fontFamily: "Karla"
    fontSize: "16px"
    fontWeight: 700
    lineHeight: 1.4
  menu-label:
    fontFamily: "Karla"
    fontSize: "14px"
    lineHeight: 1.4
rounded:
  none: "0px"
spacing:
  gutter: "clamp(18px, 4.6vw, 60px)"
  section: "clamp(38px, 5vw, 64px)"
  stack: "1.15rem"
  menu-gap: "16px"
  menu-gutter-compact: "16px"
  menu-gutter-wide: "28px"
  menu-card-inset: "12px"
  menu-sheet-inset: "20px"
components:
  plate-primary:
    backgroundColor: "{colors.vermilion-plate}"
    textColor: "{colors.cream}"
    rounded: "{rounded.none}"
    padding: "1.1em 1.7em"
  plate-ghost:
    backgroundColor: "transparent"
    textColor: "{colors.tan}"
    rounded: "{rounded.none}"
    padding: "1.1em 1.7em"
  plate-cream:
    backgroundColor: "{colors.cream}"
    textColor: "{colors.ink}"
    rounded: "{rounded.none}"
    padding: "1.25em 2.3em"
  tag:
    backgroundColor: "{colors.vermilion-plate}"
    textColor: "{colors.cream}"
    rounded: "{rounded.none}"
    padding: "0.34em 0.55em"
  offer:
    backgroundColor: "{colors.vermilion-plate}"
    textColor: "{colors.cream}"
    rounded: "{rounded.none}"
    padding: "22px 0"
  price-board-panel:
    backgroundColor: "{colors.cream}"
    textColor: "{colors.ink}"
    rounded: "{rounded.none}"
    padding: "clamp(22px, 3vw, 36px) 0"
  price-board-row:
    textColor: "{colors.enamel}"
    typography: "{typography.price-board-name}"
    padding: "13px 0"
  price-board-offer-strip:
    backgroundColor: "{colors.vermilion-plate}"
    textColor: "{colors.cream}"
    rounded: "{rounded.none}"
    padding: "8px clamp(20px, 3vw, 36px)"
  menu-primary:
    backgroundColor: "{colors.vermilion-plate}"
    textColor: "{colors.cream}"
    typography: "{typography.menu-price-control}"
    rounded: "{rounded.none}"
  menu-primary-disabled:
    backgroundColor: "{colors.line}"
    textColor: "{colors.tan-dim}"
    typography: "{typography.menu-price-control}"
    rounded: "{rounded.none}"
  menu-product-card:
    backgroundColor: "{colors.panel}"
    textColor: "{colors.cream}"
    rounded: "{rounded.none}"
    padding: "{spacing.menu-card-inset}"
  menu-option:
    backgroundColor: "{colors.board}"
    textColor: "{colors.cream}"
    rounded: "{rounded.none}"
    padding: "12px 4px"
  menu-option-selected:
    backgroundColor: "{colors.panel}"
    textColor: "{colors.cream}"
    rounded: "{rounded.none}"
    padding: "12px 4px"
---

# Design System: Luna Bites & Delights — Storefront

## Overview

The storefront is painted like the front of a jeepney: dark enamel ground, chrome rules along every edge, and
fares lettered the way they are lettered on the real thing. It is one page at `/` that hands you to a Flutter
kiosk at `/kiosk/`; the ordering flow is never re-drawn here.

Three commitments hold the world together. **Enamel, not glass.** Every surface is a painted panel or a plate
with a physical lip, lit from above, standing on a ground that darkens toward the page end. **One vermilion
means one thing.** Bright `#d8452a` is reserved for what is live and reacting (the fare needle, the rail's
current position); anything that carries type is painted on the deeper `#a3301a` so cream clears 4.5:1.
**Type as signage.** Big Shoulders does the shouting — prices, headings, plates — and Karla does the talking,
lettered wide like a sticker run along a windscreen.

The build is static HTML, one stylesheet, and one small script. No framework, no icon font, two self-hosted
variable fonts, photos the business already published. Nothing on the page is a fact the business did not
give us: no hours, no phone number, no ratings.

### Approved storefront price-board exception

Within the existing dark enamel storefront, the price board uses one continuous cream printed-menu
panel and a continuous vermilion-plate offer strip. This local exception supersedes earlier dark-list,
dotted-leader and Karla-price descriptions for this section only; it does not change the Flutter menu.
Finish review verdict: **ship**, with no material findings in the scoped redesign. Rendered evidence:
`docs/evidence/price-board-desktop.png`, `docs/evidence/price-board-mobile.png` and
`docs/evidence/price-board-offers-mobile.png`. This documentation pass checks the supplied captures
against the HTML/CSS; it does not repeat browser verification or run tests. No new rasters ship in
`site/`; existing assets are unchanged.

### Approved Flutter menu extension

The existing storefront specification remains authoritative for `/`. The scoped additions below
record the approved menu and item chooser at `/kiosk/#/menu`, implemented with local `MenuTheme`.
They preserve the established world and do not extend to cart, checkout, staff screens or staff dialogs.
This documents the implemented category navigation, product grid and details sheet. The surface brief's
FORM and Quality bar establish refinement provenance; no seed run or new concept tournament is claimed.
Existing rendered evidence and completed review are indexed in `docs/evidence/menu-continuity.md`
and `docs/evidence/menu-*.png`; this documentation pass does not repeat their visual verification.

## Colors

### Primary

- **Vermilion Plate** (`#a3301a`): the painted surface for every plate, tag and offer price that carries
  cream type — 6.55:1. This is the default red you paint with.
- **Vermilion** (`#d8452a`): live-state only — the fare needle, the swash under the wordmark, the rules and
  inline links that mark the current position. Never behind body type.
- **Vermilion Deep** (`#8a2a18`): the lip under a plate (its offset shadow) and the closing note chip.

### Neutral

- **Enamel** (`#241a12`): the page. A single vertical ground from `#2b1e14` through enamel to `#20160d`; no
  radial washes.
- **Enamel Deep** (`#170f07`): document background and the bottom of the page.
- **Panel** (`#2c2016`): raised panels — the fare instrument and the "3 KM" chip. The storefront
  meal offers use the continuous vermilion-plate strip instead.
- **Board** (`#1b130d`): the price-board section surround and the address board, one step darker than the
  page. The price-board menu panel itself is cream.
- **Line** (`#4a3728`): painted rules and borders; `--line-soft` (`rgba(203,191,168,.22)`) for hairlines over
  photos. Price-board rows use solid line separators at 18% alpha rather than dotted price leaders.
- **Tan** (`#e0c9a6`) and **Tan Dim** (`#b39c7c`): secondary type and labels, 10.6:1 and 6.5:1 on enamel.
- **Cream** (`#f7eedd`): primary type, 14.8:1 on enamel.
- **Ink** (`#0f0906`): type on cream plates and the inherited base text of the cream price-board panel;
  explicit row names and prices use enamel.

Cream is the only light ink on a painted plate (`#a3301a`, 6.55:1); the brighter `#fff6e9` is retired.

### Named Rules

**The One Vermilion Rule.** Bright vermilion is a state, not a surface. If a rectangle carries type, it is
`#a3301a`, `#8a2a18`, or cream — never `#d8452a`.

**The Enamel Ground Rule.** The page is one vertical gradient from `#2b1e14` to `#20160d`. Depth comes from
panels and plates, never from coloured glows or radial halos.

### Price-board color assignments

The local menu panel uses cream with enamel names and prices; its inherited base text is ink.
Vermilion-plate sets category headings, their solid underlines and promotional prices on cream.
A tan top edge joins the panel to its dark surround. The two meal offers share one vermilion-plate
strip with cream text and a cream separator at 35% alpha. Column separators use line at 25% alpha;
row separators use line at 18%. These flat local surfaces introduce no new palette primitives.

### Flutter menu color assignments

Reuse the existing primitives: `MenuTheme.enamel` is enamel, `board` is board, `panel` is panel,
`line` is line, `cream` is cream, `tan` is tan, `muted` is tan-dim, and `accent` is vermilion-plate.
The menu ground is solid enamel; board carries the sidebar and chooser, panel carries product cards
and the chooser footer. Primary actions and selected categories use vermilion-plate with cream type.
Selected options use panel with a tan border; unselected options use board with a line border.
Material's local dark color scheme uses tan for primary/secondary and board for their on-colors;
surface/onSurface are board/cream and outline is muted. Focus uses tan at 22% alpha, hover at 8%.
Disabled filled buttons use line/muted. Snackbars use cream with board text. No app-wide theme changes.

## Typography

Two self-hosted variable faces, `font-display: swap`, preloaded:

- **Big Shoulders Display** (100–900): signage. Headings, wordmark, prices, plate labels, tags. Uppercase,
  tight leading (0.84–1.02), tracking at or below `0.01em`, never below the 6rem ceiling.
- **Karla** (200–800): the spoken layer. Body copy, labels, nav, footer. Body at 16–17px / 1.55; labels at
  0.74–0.95rem, weight 700, tracking `0.16em`–`0.3em`, uppercase.

### Hierarchy

- **Wordmark** — Big Shoulders 900, `clamp(3.7rem, 10.2vw, 6rem)`, leading 0.78, three stacked lines with the
  middle line in tan.
- **Section head** — Big Shoulders 900, `clamp(1.7rem, 3.2vw, 2.3rem)`, uppercase, leading 1.02.
- **Price-board item** — Karla 600, 1rem (16px), leading 1.35; **price** — Big Shoulders 800,
  2rem (32px), leading 1, tabular numerals, enamel, right-aligned. Promotional prices use vermilion-plate.
- **Price-board title** — Big Shoulders 900, `clamp(3.6rem, 7vw, 6rem)`, leading 0.9, uppercase;
  subtitle in Karla 400, 1rem / 1.5. Category headings use Big Shoulders 800,
  `clamp(1.8rem, 2.7vw, 2.5rem)` / 1, uppercase, vermilion-plate.
- **Price-board offer** — name in Big Shoulders 800, `clamp(1.65rem, 2.4vw, 2rem)` / 1;
  price in Big Shoulders 900, `clamp(3.2rem, 5vw, 4rem)` / 0.95, tabular numerals;
  description in Karla 400, 0.95rem / 1.5.
- **Body** — Karla 400, 16–17px, 1.55, max ~58 characters.
- **Label / kicker** — Karla 700, 0.74–0.95rem, uppercase, tracking 0.16em–0.3em, tan or tan-dim.

### Named Rules

**The Signage-and-Speech Rule.** Big Shoulders never sets a paragraph, Karla never sets a price. A line is
either painted signage or spoken copy, and the face says which.

**The Wide-Label Rule.** Functional labels (nav, plates, tags, footer) are uppercase Karla at 0.16em tracking
or wider, minimum 0.72rem (11.5px) — the compact bar plate included.

### Flutter menu families and hierarchy

The bundled TTF families are registered in `pubspec.yaml` as `BigShoulders`
(`assets/fonts/BigShoulders.ttf`) and `Karla` (`assets/fonts/Karla.ttf`), with their OFL licenses.
`BigShoulders` is the intentional Flutter family alias for the Big Shoulders heading face; the
storefront retains its CSS family `Big Shoulders Display` and fallback stack. Treat these family names
as platform-specific declarations of the approved pairing, not a third font or a CSS stack to rename.

Menu token sizes are Flutter logical pixels. `MenuTheme.heading(size)` uses BigShoulders 800 / 1.08:
wordmark 23 (28 on desktop), category 36, subgroup 28, sidebar and item-details heading 32.
`MenuTheme.body` uses Karla / 1.4, default size 16. Product card names use the menu-product-name
role, limited to three lines with ellipsis; prices and filled-button labels use menu-price-control.
Category choices use Karla 14/700, sidebar labels 15/700, option names/prices and descriptions 15,
helper copy 14, and promotional labels 12/700 on cards and 13 in details.

The preceding storefront signage and wide-label rules remain scoped to the storefront. In the menu,
BigShoulders sets wordmark/category/item headings; Karla sets product-card names, prices, options,
quantity and controls. Native task labels do not inherit storefront-wide uppercase tracking.

## Layout

- **Page width**: one content column, `max-width: 1120px`, inside gutters `clamp(18px, 4.6vw, 60px)`. Every
  section holds the same left edge (160px at 1440, 18px at 390). The price-board panel's local internal
  column insets are the scoped exception; its outer edges retain the shared content alignment.
- **Section rules**: flat 1px cream at 28% alpha (`--hairline`); the top strip is a flat 2px tan line, not a
  gradient imitation of chrome. The price-board panel has its own column and row insets documented below.
- **Hero**: two columns `minmax(0,1fr) minmax(430px,1.04fr)`: wordmark, copy and ordering actions left;
  a large mounted shawarma photograph and its `₱60 each` tag right. The delivery disclosure spans both
  columns beneath them. At 940px and below, the DOM and visual order are introduction, photograph,
  ordering actions, then delivery estimate. The phone wordmark runs on one line where space permits;
  the photo is at least 200px tall. Food, its price and the order action appear in the first phone viewport.
- **Section links**: targets have `scroll-margin-top: 6rem`, leaving the heading below the sticky bar.
  Below 900px the location line and Facebook link yield to persistent Prices, Photos and Find us links,
  each with a 44px minimum hit height, beside the Order plate.
- **Price board**: a large painted header and full-menu link above one cream panel with a 6px tan top
  edge. Above 940px, three equal columns use `minmax(0,1fr)` with solid vertical separators;
  panel padding is `clamp(22px, 3vw, 36px) 0`, column inset `clamp(20px, 2.2vw, 30px)`.
  At 940px and below, categories stack continuously with horizontal separators and 24px inset;
  at 700px and below the horizontal inset is 20px and the full-menu link fills the header width.
  Two ₱99 meal offers share a continuous red strip directly below the panel. All 17 item rows and both
  offers retain their names, amounts and qualifications, including Solo halo-halo and Medium caramel
  macchiato. The footer repeats the separate rider-confirmed delivery fee and links into the app.
- **Window wall**: 12-column grid of rotated photo mounts, spans a4/b2/c3/d3; 2×2 at 6 columns on tablet;
  full / pair-pair / full on phones.
- **Find**: heading and intro in a two-column head, then one address board carrying the landmark callout.
- **Close**: full-bleed vermilion band, centered kicker, cream plate, painted note chip, then the footer.
- **Breakpoints**: 940px (hero stacks, price-board categories stack, offers reflow, wall pairs), 700px,
  460px (compact bar plate).
- **Phone-first budget**: no horizontal overflow at 320px (`overflow-x: clip` on `html` as a backstop).

### Flutter menu and chooser layout

At viewport widths of 1000 logical pixels and above, show the 216-wide category sidebar; below that,
show the horizontally scrolling category bar. Its height follows text scale (44 × scale + 24), with
16/10 horizontal/vertical inset and 8 between choices. Category heading and subtitle scroll with products.
The grid uses floor(available width / 260), clamped to two through four columns; 16 gaps, 16 gutters
below 600 available width and 28 otherwise. Card height is card width × 0.8 + 144 × text scale.
Names reserve scaled three-line space; images occupy the remaining height. The header uses 16 or
28 horizontal inset and 12 vertical inset. The populated order action spans its available width up
to 700 inside a board rail; it opens the existing cart.

The chooser is at most 960 wide and normally 90% of viewport height. Fixed-price items without variants
at viewport widths of 700 or above cap height at 460. Its body scrolls with 20 inset while quantity and
add action persist below. At 600 available body width, a 240-wide image and details share a row with
28 gap; otherwise they stack with 20 gap. Image heights are 260/170 for row/stack layouts.
Below 400 available footer width, quantity and action stack with 8 gap; otherwise they share a row.
The footer inset is 20/12/20/16 (left/top/right/bottom), plus safe-area protection.

## Elevation & Depth

Depth is painted, never blurred into a glow.

- **Plate**: `box-shadow: 0 .06em 0 var(--verm-deep), 0 .55em 1em -.55em rgba(0,0,0,.9)` at rest — a hairline
  of the darker red under the edge plus a soft cast. Hover lifts `translateY(-2px)` and lengthens the cast;
  active presses to `translateY(2px)` with a short one.
- **Panel**: `inset 0 2px 0 rgba(255,255,255,.045), 0 34px 60px -46px #000` — a lit top edge and a long soft
  cast.
- **Photo mount**: the image carries a 6px cream paper border and `0 22px 34px -22px #000`; the figure is
  rotated 1–2 degrees off-axis.
- **Sticky bar**: acquires `0 14px 26px -22px #000` once scrolled past 6px. Photo tags carry only a cast:
  `0 6px 14px -8px rgba(0,0,0,.9)`.
- **Focus**: `outline: 2px solid var(--tan); outline-offset: 3px` (5px on the rail).

### Named Rules

**The Painted Cast Rule.** Depth is a short dark line under the edge plus one soft black cast. No hard
zero-blur offset slabs, no coloured glow, no zero-offset halo, no backdrop blur.

### Flutter menu depth

The menu extension uses flat tonal layering and line borders with native Material interaction feedback.
The local bottom sheet has transparent surface tint. Storefront plate casts, photo rotation and hover
translation are not prescribed for menu cards or controls; the existing item-image Hero connection remains.

## Shapes

Square corners everywhere (`0px`) — this is a painted board, not a card UI. Rules are flat: a 2px tan strip
at the top and 1px cream at 28% under section edges. The price board is a local printed-menu exception:
solid row and category rules replace dotted leaders; the spacer between name and price is unpainted.
`clip-path` cuts the one swash under the wordmark. Rotation carries the print quality:
tags at ~2.2°, photo mounts between 1° and 2° off true.

The Flutter menu carries the same square form through framed product images, category choices,
buttons and bordered options. Product images have 3 logical pixels of inset; the chooser image has a
3-pixel cream border. Native radios and checkboxes retain their standard control geometry.

## Components

### Plates (buttons and links)

- **Shape:** square, painted, uppercase Karla 700 at 0.16em tracking.
- **Primary:** vermilion plate `#a3301a` with cream type; lip in `--verm-deep`; padding `1.1em 1.7em`.
- **Cream:** `--plate--invert` — cream ground, `--verm-deep` type, cast in black at 35%; used for the one
  order action on the closing band.
- **Ghost:** transparent with `inset 0 0 0 2px rgba(224,201,166,.5)`, tan type; hover fills the border to
  `--tan`.
- **Compact:** `--plate--sm` at 0.72rem / 0.1em for the 320px bar; `--plate--xl` at 1.25em / 2.3em for the
  closing call to action.
- **States:** hover lifts 2px and darkens to `#b8381e`; active presses 2px down; focus uses the tan ring.

### Delivery notice

A static board below the ordering actions says **Delivery fee applies** and explains that
the rider confirms the amount, charged separately from food. Use the existing board ground,
tan border, Big Shoulders heading and Karla body. No calculator, numeric fare or per-kilometre
rate is shown. Checkout and receipts label delivery-order totals **Food total** and repeat
the notice; online payments cover food only.

### Offer lines

The two ₱99 offers share one full-width vermilion-plate strip within the content column, with cream text,
8px vertical strip inset and `clamp(20px, 3vw, 36px)` horizontal inset. Each offer has 22px vertical padding;
a solid cream rule at 35% separates them. Above 940px the name, description and large price share a row
with 24px gaps. At 940px and below, explicit grid areas keep name and price together above the description,
with 12px row and 20px column gaps. Names and prices use the local Big Shoulders offer roles; descriptions
use Karla 0.95rem / 1.5. No dotted leader or separate price badge; no new animation.

### Photo mounts

Paper-white border, rotated, with a vermilion-plate tag pinned bottom-right (`HALO-HALO ₱49`). Tags are
painted signage, not chips.

### Price rows

On the cream menu panel, names use Karla 16px/600 and prices use Big Shoulders 32px/800 tabular
numerals. Both are enamel; promotional prices use vermilion-plate. Rows align on the baseline with
10px gaps, 13px vertical padding and solid line separators at 18% alpha; the final row drops its bottom
rule and bottom padding. The flexible spacer has no dotted leader and prices do not shrink. Names may
wrap while the amount remains aligned right. The ₱ glyph appears once per price.

### Address board

Board ground, 3px cream top rule, address in Big Shoulders at 1.3 leading, and the landmark callout — "Unahan
lang gamay sa 7/11" with `7/11` in the lighter red `#e2603f` — set on the same baseline. A fourth line holds
the hours slot the owner has not filled yet: `Oras · opening hours` with `to follow` on a dashed underline,
so the hole is visible and marked instead of invented. Actions sit below.

### Flutter menu primitives and item chooser

- **Navigation:** square Material ChoiceChips below desktop width; labelled ListTiles with outlined
  category icons on desktop. Selected categories use vermilion-plate/cream. These functional native
  icons are scoped to the menu and do not change the storefront's icon restriction.
- **Product card:** square panel with a line border, real cover-fit food image, Karla product name and
  tan price. Variant items qualify the price with “From”. A square vermilion add affordance belongs to
  the clickable card; promotional labels use the same painted accent. Image failure shows a panel
  fallback with a tan restaurant outline.
- **Primary action:** square filled button, minimum 48 × 52, Karla 16/700. Icon buttons have minimum
  48 × 48 targets. Native focus/hover feedback uses the local theme; disabled actions use line/muted.
- **Option row:** square border, 10 bottom gap, 12/4 horizontal/vertical content inset. A single choice
  uses a native radio group; multiple choices use checkboxes. Selection changes the border to tan and
  ground to panel, with tan radio state or vermilion/cream checkbox state.
- **Chooser:** BigShoulders item heading above wrapping Karla description and required options.
  Add remains disabled until the existing selection condition is met; helper text explains the state.
  The persistent footer shows quantity and total. Closing details leaves the cart untouched; documented
  styling does not alter pricing, selection limits, fixed bundles or existing add-to-cart behavior.

## Do's and Don'ts

### Do:

- **Do** use cream for the local price-board menu panel, enamel for its names/prices and vermilion-plate
  for category headings, promotional prices and the continuous cream-lettered offer strip.
- **Do** use `--verm-plate` for type-bearing red surfaces and check cream on it (6.55:1).
- **Do** set functional labels at 11.5px or larger, uppercase Karla, 0.16em tracking or wider.
- **Do** give raised surfaces a short dark edge plus one soft black cast, and lift 2px on hover.
- **Do** keep the delivery notice visible without requiring interaction.
- **Do** rotate photo mounts 1–2° and pin a painted tag on them.
- **Do** end with one full-bleed vermilion band and one cream plate.

### Don't:

- **Don't** put cream type on `#d8452a`; that brightness is a live state, not a background.
- **Don't** add coloured glows, zero-offset halos, or radial background washes.
- **Don't** use colored left-border tabs on cards, equal-card rows for offers, glyph icons, or a second
  accent hue.
- **Don't** round corners, use backdrop-filter, fake chrome with gradients, or draw depth with blur alone.
- **Don't** mark hours, phone or ratings as if they existed; use the `to follow` slot.
- **Don't** invent business facts — hours, phone numbers, ratings, and testimonials do not exist yet.
- **Don't** duplicate the ordering flow here; every order action links to `/kiosk/`.
