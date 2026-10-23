---
version: 1
slug: "kiosk-menu"
primary_target: "lib/screens/menu_page.dart"
related_targets:
  - "lib/widgets/kiosk/menu_theme.dart"
  - "lib/widgets/kiosk/product_card.dart"
  - "lib/widgets/kiosk/category_bar.dart"
  - "lib/widgets/kiosk/sidebar.dart"
  - "lib/widgets/kiosk/customization_modal.dart"
---

## Mode

Operate. Visitors choose a category, inspect a dish and its price, choose any required options, set quantity, and add it to their order.

## Scope and confirmed answer

The user requested visual continuity between the storefront and menu, and selected **Menu + item chooser**. Cart, checkout, staff tools, pricing, payment and delivery remain outside the redesign. The dark menu theme is local to the menu and chooser; staff dialogs retain their original application theme.

## Established world

Inherit the storefront's coffee enamel, cream and tan lettering, square framed food photographs, condensed display headings, and deeper vermilion for primary actions. This is a task screen: product names, prices, options, and buttons use readable Karla rather than decorative display lettering. Big Shoulders is reserved for the wordmark, category and item headings. Bundle both fonts and their OFL licenses.

## Direction contract

THESIS: Browsing the menu feels like stepping up to the same Luna price board seen on the storefront. Photographs and prices lead, with standard controls for selecting food.

OWN-WORLD: Enamel #241A12, board #1B130D, panel #2C2016, cream #F7EEDD, tan #E0C9A6, muted tan #B39C7C, and vermilion plate #A3301A. Square geometry, real food photography, flat rules, and restrained native focus/selection feedback. No decorative emoji navigation, rounded pills, or page entrance choreography.

STORY: Choose a category, recognize the food, read its actual price, and open the item. Required choices are explicit and the add button remains disabled until the existing selection rule is satisfied. Quantity and total remain available at the bottom of the chooser. Closing details leaves the cart untouched.

FIRST VIEWPORT: A compact logo/wordmark row with order count and a secondary utilities menu. Phones and tablets have horizontally scrolling category choices; desktop has a labelled category sidebar at 1000px and above. Category heading and factual subtitle scroll with the products so enlarged text cannot consume the whole screen. A responsive two-to-four-column grid shows real images, full product names where possible, qualified starting prices and a clear add affordance. A bottom order action appears once the cart contains items.

FORM: Refine the existing category navigation, product grid and item-details sheet inside the established storefront world. This is the confirmed menu-plus-chooser scope, not a new surface or visual-world selection. No concept seed was run or claimed: `new-work.md` excludes precisely specified refinements from the concept tournament. Desktop keeps a labelled sidebar and image grid; phones keep horizontal category choices and a two-column grid. The sheet keeps standard option controls with a persistent action area.

INTERACTION: Native category choices, buttons, radio groups and checkboxes provide keyboard and assistive-technology behavior. Fixed-price, single-option and multiple-option products retain their existing price and selection logic. The chooser uses a scrolling body and persistent action area, with stacked quantity/action controls on narrow phones and image/details columns on wider screens.

## Quality bar

The confirmed task is complete when the menu reads as the same Luna business as the storefront, product names and real prices remain readable, native controls expose selection and disabled states, and phone/tablet/desktop layouts preserve the path from category to item options to the existing cart. The supplied screenshots and ordering tests are the evidence for this established-world refinement. Ornament, a new composition tournament, and generated imagery are outside this task.

## Verification requirements

Inspect actual Flutter web renders at 320px, 390px, tablet and desktop widths, including menu, chooser, selected variants and the populated order bar. Verify large text, single-option price and quantity, multi-select limits and fixed bundle prices, cancel behavior, and category changes. Run existing analysis/tests and required Functions checks. Never submit a live order for visual verification.
