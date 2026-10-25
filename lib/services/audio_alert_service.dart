import 'audio_alert_stub.dart'
    if (dart.library.js_interop) 'audio_alert_web.dart'
    as alert_impl;

class AudioAlertService {
  static bool soundEnabled = true;

  static void playOrderChime() {
    if (!soundEnabled) return;
    try {
      alert_impl.playAlertSound();
    } catch (_) {}
  }
}
