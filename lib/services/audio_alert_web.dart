import 'dart:js_interop';

@JS('playOrderAlert')
external void _triggerWebChime();

void playAlertSound() {
  try {
    _triggerWebChime();
  } catch (_) {}
}
