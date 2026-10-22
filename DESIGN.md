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
rounded:
  none: "0px"
spacing:
  gutter: "clamp(18px, 4.6vw, 60px)"
  section: "clamp(38px, 5vw, 64px)"
  stack: "1.15rem"
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
    backgroundColor: "{colors.panel}"
    textColor: "{colors.cream}"
    rounded: "{rounded.none}"
    padding: "clamp(18px, 2.4vw, 26px)"
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
- **Panel** (`#2c2016`): raised panels — the fare instrument, offer cards, the "3 KM" chip.
- **Board** (`#1b130d`): the price board and the address board, one step darker than the page.
- **Line** (`#4a3728`): painted rules and borders; `--line-soft` (`rgba(203,191,168,.22)`) for hairlines over
  photos and dotted price leaders.
- **Tan** (`#e0c9a6`) and **Tan Dim** (`#b39c7c`): secondary type and labels, 10.6:1 and 6.5:1 on enamel.
- **Cream** (`#f7eedd`): primary type, 14.8:1 on enamel.
- **Ink** (`#0f0906`): type on cream plates only.

Cream is the only light ink on a painted plate (`#a3301a`, 6.55:1); the brighter `#fff6e9` is retired.

### Named Rules

**The One Vermilion Rule.** Bright vermilion is a state, not a surface. If a rectangle carries type, it is
`#a3301a`, `#8a2a18`, or cream — never `#d8452a`.

**The Enamel Ground Rule.** The page is one vertical gradient from `#2b1e14` to `#20160d`. Depth comes from
panels and plates, never from coloured glows or radial halos.

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
- **Dish name** — Big Shoulders 700, 1.18–1.45rem; **price** — Karla 500, tabular numerals, tan, right-aligned
  against a dotted leader.
- **Body** — Karla 400, 16–17px, 1.55, max ~58 characters.
- **Label / kicker** — Karla 700, 0.74–0.95rem, uppercase, tracking 0.16em–0.3em, tan or tan-dim.

### Named Rules

**The Signage-and-Speech Rule.** Big Shoulders never sets a paragraph, Karla never sets a price. A line is
either painted signage or spoken copy, and the face says which.

**The Wide-Label Rule.** Functional labels (nav, plates, tags, footer) are uppercase Karla at 0.16em tracking
or wider, minimum 0.72rem (11.5px) — the compact bar plate included.

## Layout

- **Page width**: one content column, `max-width: 1120px`, inside gutters `clamp(18px, 4.6vw, 60px)`. Every
  section holds the same left edge (160px at 1440, 18px at 390); no section may inset its content further.
- **Section rules**: flat 1px cream at 28% alpha (`--hairline`); the top strip is a flat 2px tan line, not a
  gradient imitation of chrome.
- **Hero**: two columns `minmax(0,1fr) minmax(430px,1.04fr)` — wordmark and copy left, the fare instrument
  panel right. The panel's photo mount is 16:9, capped at 176px tall on desktop, 260px below 940px.
- **Price board**: the painted header, then the three columns of dish rows, then the two ₱99 offer lines.
  Rows start at y≈790 on a 1440×900 first viewport, so prices are legible above the fold.
- **Window wall**: 12-column grid of rotated photo mounts, spans a4/b2/c3/d3; 2×2 at 6 columns on tablet;
  full / pair-pair / full on phones.
- **Find**: heading and intro in a two-column head, then one address board carrying the landmark callout.
- **Close**: full-bleed vermilion band, centered kicker, cream plate, painted note chip, then the footer.
- **Breakpoints**: 940px (hero stacks, offers stack, wall pairs), 700px, 460px (compact bar plate, single
  column).
- **Phone-first budget**: no horizontal overflow at 320px (`overflow-x: clip` on `html` as a backstop).

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

## Shapes

Square corners everywhere (`0px`) — this is a painted board, not a card UI. Rules are flat: a 2px tan strip
at the top, 1px cream at 28% under section edges, dotted leaders (`1px dotted`, cream at 22–26%) connecting a
dish to its price. `clip-path` cuts the one swash under the wordmark. Rotation carries the print quality:
tags at ~2.2°, photo mounts between 1° and 2° off true.

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

### Fare rail (signature component)

A real instrument, not a decoration. A 52px-tall `role="slider"` spans 1–12 km; ticks, fare labels and the
fare table live **outside** the slider in `.rail-wrap`, so the control keeps its own hit area and
`aria-describedby="rail-note"`. Tall ticks sit on the labelled stops (1, 3, 6, 9, 12 km), never on an
unlabelled one. Above 940px the rail prints all twelve fares (₱39…₱468, 11.2px) and bolds the active stop;
below 940px the five majors remain. A red needle with a "3 KM" chip rides the track, `left` driven by
`--v`, spring easing (`cubic-bezier(.3, 1.24, .42, 1)`) except while dragging (`.1s linear`). The fare
readout, every `[data-km]` / `[data-peso]`, and `aria-valuenow` / `aria-valuetext` update together. Pointer
capture for drag, arrows / Page / Home / End for keyboard, needle entrance from 1→3 km on load unless
`prefers-reduced-motion`. The focus ring clears the labels by 9px.

### Offer lines

The two ₱99 offers are board lines, not cards: tag in Big Shoulders, the flavour list in Karla at 0.82rem, a
dotted leader, and the price on a painted plate at the right edge. Below 700px the tag and price take the
first row and the flavour list spans the second. No panel, no equal-card row.

### Photo mounts

Paper-white border, rotated, with a vermilion-plate tag pinned bottom-right (`HALO-HALO ₱49`). Tags are
painted signage, not chips.

### Price rows

Dish name in Big Shoulders 700 on the left, a dotted leader span between, price in Karla 500 tabular
numerals on the right; promo rows tint the price `#ffb9a4`. The ₱ glyph appears once per price.

### Address board

Board ground, 3px cream top rule, address in Big Shoulders at 1.3 leading, and the landmark callout — "Unahan
lang gamay sa 7/11" with `7/11` in the lighter red `#e2603f` — set on the same baseline. A fourth line holds
the hours slot the owner has not filled yet: `Oras · opening hours` with `to follow` on a dashed underline,
so the hole is visible and marked instead of invented. Actions sit below.

## Do's and Don'ts

### Do:

- **Do** paint every type-bearing surface in `--verm-plate` and check cream on it (6.55:1).
- **Do** set functional labels at 11.5px or larger, uppercase Karla, 0.16em tracking or wider.
- **Do** give raised surfaces a short dark edge plus one soft black cast, and lift 2px on hover.
- **Do** keep the fare rail's ticks and labels outside the slider element.
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
