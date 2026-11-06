# Luna Bites & Delights

Luna Bites & Delights is a food business application that enables customers to order, pay, and choose between delivery or pickup.

- **Storefront:** https://lunabitesanddelights.web.app
- **Ordering app:** https://lunabitesanddelights.web.app/kiosk/#/menu
- **Legacy domain:** `lunaexpress.web.app` permanently redirects (301) to the canonical domain above.

## Platform

Web only. There is no Android, iOS, Windows, macOS or Linux build in this
repository. On a phone the ordering app is installed to the home screen as a
PWA from `/kiosk/` — Chrome and Edge offer an install prompt, Safari uses
Share → Add to Home Screen. The manifest declares `display: standalone`, so an
installed copy opens without browser chrome.

## Project Vision

Our goal is to provide a seamless, mobile-optimized experience for food ordering while ensuring robust data security and payment processing.

## Governance

This project is governed by the [Project Constitution](.specify/memory/constitution.md). All contributors and developers must adhere to the core principles defined therein:
1. **User-Centric Ordering**
2. **Payment-First Fulfillment**
3. **Fulfillment Flexibility**
4. **Data Integrity & Security**
5. **Spec Kit Compliance**

## Development Workflow

We use the Spec Kit (Specify -> Plan -> Implement) methodology for all feature development. Ensure you have the `.agent` skills available for automated workflow management.

## Getting Started

1. **Environment Setup**: Ensure Flutter is installed and configured.
2. **Firebase Configuration**: Link the project to your Firebase instance using `firebase init`.
3. **Explore Specs**: View planned features in the `specs/` directory.

To build the deployable site locally:

```sh
flutter build web --release --base-href /kiosk/
dart run tool/assemble_site.dart
```

`assemble_site.dart` puts the Flutter build under `build/web/kiosk/` and the
static storefront at the root of `build/web/`.
