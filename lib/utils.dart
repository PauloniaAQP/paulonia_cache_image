import 'package:paulonia_cache_image/constants.dart';

class Utils {
  /// Verify if [url] is a Google Cloud Storage (gs) url.
  static bool isGsUrl(String url) {
    Uri uri = Uri.parse(url);
    return uri.scheme == Constants.GS_SCHEME;
  }
}
