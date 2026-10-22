/// Single source of truth for the public-facing business copy.
///
/// Everything here is taken from the Luna Bites & Delights Facebook page
/// (see AGENTS.md → Business Reference) so the landing page, metadata and
/// future marketing surfaces stay consistent.
class LunaBusiness {
  const LunaBusiness._();

  static const String name = 'Luna Bites & Delights';
  static const String shortName = 'Luna Bites';

  /// The page intro, verbatim from Facebook.
  static const String tagline = 'Good food, sweet drinks, moonlit vibes.';

  static const String blurb =
      'Tambayan ng good food, sweet drinks, at moonlit vibes. '
      'Feel the comfort, taste the delight — only at Luna Bites & Delights.';

  // ─── Contact ──────────────────────────────────────────────────
  static const String facebookUrl =
      'https://www.facebook.com/profile.php?id=100090686762896';
  static const String messengerUrl = 'https://m.me/100090686762896';

  // ─── Location ─────────────────────────────────────────────────
  static const String street = 'Purok 5, Poblacion, Magallanes';
  static const String region = 'Agusan del Norte, Philippines';
  static const String landmark = 'Unahan lang gamay sa 7/11';

  static const String directionsUrl =
      'https://www.google.com/maps/search/?api=1&query='
      'Luna+Bites+%26+Delights+Poblacion+Magallanes+Agusan+del+Norte';

  // ─── Social proof ─────────────────────────────────────────────
  static const String followerLabel = '866 followers';
  static const String category = 'Food & Drink · Kiosk';
}
