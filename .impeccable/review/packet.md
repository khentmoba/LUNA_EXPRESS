# Finish review packet — Luna Bites & Delights storefront

## Original request (user's words, condensed from the thread)

Build a landing page for the business "Luna Bites & Delights" (Facebook:
https://www.facebook.com/profile.php?id=100090686762896) that shows what the business is, pulls brand info
from the Facebook page, and carries a clickable button that launches the kiosk ordering flow.

Follow-up the user gave while this ran:

- The Flutter landing page that existed before was rejected as "AI slop". Replace it with a hand-built static
  storefront at `/`, keep the Flutter ordering app at `/kiosk/`, and make the storefront link into it — never
  duplicate the ordering flow.
- Add the Facebook page link to `AGENTS.md` so later agents can reference it.

## Confirmed answers (user, this round)

- Surface location: **static page at the site root**, Flutter kiosk stays at `/kiosk/`.
- Audience emphasis: **"Mostly, deliveries actually"** — delivery-first, walk-in secondary.
- Opening hours / contact number: **"no other info for now, ill add later"** — do not invent them.

## Artifact under review

- `site/index.html` — the storefront markup (shipped at `/`)
- `site/styles.css` — the whole visual world
- `site/app.js` — fare-rail instrument + sticky bar
- `site/img/*.webp`, `site/images/og-cover.jpg` — shipping rasters (all carry provenance)
- `site/fonts/*.woff2` — self-hosted Big Shoulders Display + Karla
- Shipped assembly: `tool/assemble_site.dart` moves the Flutter web build to `build/web/kiosk/` and copies
  `site/` to the root; `firebase.json` rewrites `/kiosk/**` to the Flutter index and everything else to the
  storefront. The storefront's order plate points at `/kiosk/#/menu`.

A local server may be running at `http://127.0.0.1:8099/` (assembled build) and `http://127.0.0.1:8110/`
(site only). You have no browser; if either is dead, read the source files instead of relying on it.

## Screenshots (all REQUIRED — these are the only views you get)

- `.impeccable/review/desktop.png` — 1440×900 full page, from the document top, entrance motion settled
- `.impeccable/review/mobile.png` — 390×844 full page, same rules
- `.impeccable/review/state-rail-desktop.png` — fare rail focused, driven to 8 km with the keyboard
- `.impeccable/review/state-rail-mobile.png` — same state at 390px

Earlier rounds also inspected 1180 / 820 / 320 widths and the kiosk handoff; those captures are not in the
packet, so do not score what you cannot see. Overflow was probed programmatically at every width
(`scrollWidth === clientWidth`) and the 320px bar was fixed to pass.

## Direction contract

`.impeccable/surfaces/site-index-html.md` — read it. It carries the six blocks (world, visitor path, first
viewport, signature interaction, motion grammar, honest risk). World: **Harap ng Jeepney** — Luna's storefront
painted like the front of a jeepney: fare board, painted plates, a real fare instrument.

This is a **code-led** build: there is no approved comp. The chosen decision comp rides in the comp slot as
the **critique reference, not the composition law**: `.impeccable/mocks/decision/assigned.html`, rendered at
`C:/Users/Admin/AppData/Local/Temp/luna-dec/assigned.png`. Audit the build against what that card promised
(the jeepney fare-board world, the painted-plate language, the rail as a real instrument), not against its
pixels.

## Craft-floor reference

`C:\Users\Admin\.pi\agent\skills\impeccable\reference\craft-floor.md` — the finish bar (contrast floor,
offset-shadow depth, display type ceiling, tracking floor, one authored motion moment, themed browser
surfaces, no anti-tell tells).

## Product truth files

- `PRODUCT.md` — the product record from `impeccable init`
- `AGENTS.md` — business reference section, house rules
- `lib/data/menu_data.dart` — the kiosk's source of truth for names and prices; the price board must not
  contradict it (spot-check a few rows)

## Existing hook findings (mechanical detector, `impeccable detect`)

The detector ran on `site/index.html` + `site/styles.css`. It went from 13 findings to **3**, all
`cramped-padding`, all on elements whose computed inset the build thread measured in the live page:

- `<section class="board">` — computed padding 64px top / 60px sides / 52px bottom at 1440; first child
  (`.board__head`) starts 70px below the section top and 40px in from its content edge
- `<section class="find">` — computed padding 96px / 60px / 84px; last child is 85px above the bottom border
- `<div class="find__board">` — 20–28px inner padding at 1440, holding a bordered address block

Fixed this round from detector findings: every vermilion surface that carries text moved to
`--verm-plate #a3301a` (cream on it = 6.55:1); the zero-offset red glow on the fare needle is gone; the
radial background halo is now a single vertical ground; the offer card's 4px colored left tab is gone, its
₱99 now sits on a painted plate; the rail's "3 KM" tag carries its own panel chip; the bar's compact plate
was raised to the 11px floor. Judge the three remaining findings on the screenshots: if the inset reads
cramped, it is a fix; if the space is real, say so.

## What the build thread already knows and is not asking you to re-litigate

- Prices and dish names come from `lib/data/menu_data.dart`; the fare math is ₱39 × km, 1–12 km.
- The kiosk handoff was verified live: clicking the order plate lands on `/kiosk/#/menu` with the Flutter app
  rendering and no page errors.
- Photos are the business's own product photos from its Facebook page, re-encoded to WebP; provenance is
  embedded and `impeccable embed-prompt --scan` reports 0 missing.

## Return contract

Return the five contract sections from `agents/finish-reviewer.md` (verdict, findings with dispositions,
what you could not check, the finish bar, and the one-line disclosure of anything substituted). Findings must
name the section and, where possible, the screenshot and region, so the build thread can act on them.
