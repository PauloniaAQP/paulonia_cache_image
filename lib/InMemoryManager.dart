import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:paulonia_cache_image/paulonia_cache_image.dart';
import 'package:paulonia_cache_image/paulonia_cache_image_mobile.dart'
    if (dart.library.html) 'package:paulonia_cache_image/paulonia_cache_image_web.dart';

class InMemoryManager {
  /// Stores the images in memory
  static HashMap<String, ImageStreamCompleter> _manager = HashMap();

  /// Get the image
  ///
  /// Verifies if the image is in memory cache and returns it. Otherwise it calls
  /// [getImage()] from the service of the platform.
  static ImageStreamCompleter getImage(PCacheImage key) {
    if (_manager.containsKey(key.url)) return _manager[key.url];
    _manager[key.url] = MultiFrameImageStreamCompleter(
      codec: PCacheImageService.getImage(
        key.url,
        key.retryDuration,
        key.maxRetryDuration,
        key.enableCache,
      ),
      scale: key.imageScale,
    );
    return _manager[key.url];
  }
}
