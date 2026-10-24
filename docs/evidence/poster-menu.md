# Favorites poster menu setup

The owner-supplied burger, fries and shawarma poster is the source for this update.

- Added the standalone Shawarma Rice Bowl at ₱50 alongside the separate ₱99 S3 meal.
- Overload now requires a size: Buddy (1–2 pax) at ₱99 or Barkada (3–5 pax) at ₱150.
- Corrected Cheese & Egg Burger naming and burger-with-egg photography using existing assets. All six poster burgers keep buy 1 take 1 pricing.
- The storefront includes every poster item, retaining the existing additional meals and drinks. It keeps the established cream price board rather than copying the poster artwork.
- Updated both checkout source and tracked compiled output; retained the old Egg & Cheese name as a ₱95 compatibility alias.

## Validation

- `flutter test --no-pub`: 27 passed. Includes required-size selection and two Barkada platters reaching the cart at ₱300, rice-bowl presence and asset existence, and menu/server price parity.
- `flutter analyze --no-pub --no-fatal-infos --no-fatal-warnings`: 119 informational findings, no errors or warnings.
- `flutter build web --no-pub --release --base-href /kiosk/`: passed; `dart run tool/assemble_site.dart`: passed. The build reports deprecated Flutter loader and unsupported Wasm-import notices; the JavaScript web build succeeds.
- Functions build and all 10 Functions tests passed. `npm audit --audit-level=high` passed with 16 moderate advisories and no high or critical advisories.
- Dart format and `git diff --check`: passed. Rules were not changed.
- The initial `flutter pub get` resolved packages but stopped at Windows symlink support. Analysis, tests and build then succeeded with `--no-pub`; SDK-induced lockfile edits were restored.

## Rendered checks and limitations

The actual storefront loaded locally and its desktop DOM showed the expected prices, three columns and no horizontal overflow. The extracted price-board markup and final stylesheet were rendered with embedded copies of the shipped fonts at 320, 768 and 1440px. Visual inspection found readable wrapping and aligned prices. Added 28px separation before the second category in a column after the first phone render showed crowding. These captures cover the price-board section, not the entire page.

The assembled Flutter app loaded locally. After the browser screenshot tools failed, a separate headless Edge session captured the actual app through Chrome DevTools Protocol. Desktop screenshots show the shawarma grid including the ₱50 rice bowl, the burger grid with Cheese & Egg Burger, both overload size options, and the selected Barkada option with an Add to order total of ₱150. A 390px phone capture verifies the burger grid layout. These are actual Flutter app captures, separate from the extracted storefront renders above. The 320px widget test also successfully selects Barkada and checks quantity and total; no live checkout, order submission or payment was performed.

Actual app captures: `poster-kiosk-shawarma-desktop.png`, `poster-kiosk-burgers-desktop.png`, `poster-kiosk-burgers-mobile.png`, `poster-kiosk-overload-desktop.png`, and `poster-kiosk-barkada-desktop.png`.

The Impeccable detector reported cramped-padding warnings. Rendered row padding is 13px vertically and column inset is 20–30px; parent and last-row warnings describe the existing continuous-board treatment. No palette, typography or navigation redesign was made.
