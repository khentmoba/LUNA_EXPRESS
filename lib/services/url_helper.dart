import 'url_helper_stub.dart'
    if (dart.library.js_interop) 'url_helper_web.dart' as helper_impl;

void openUrlInBrowser(String url) {
  try {
    helper_impl.openExternalUrl(url);
  } catch (_) {}
}
