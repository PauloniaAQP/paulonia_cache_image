import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:paulonia_cache_image/paulonia_cache_image.dart';
import 'package:paulonia_cache_image/paulonia_cache_image_mobile.dart'
    if (dart.library.html) 'package:paulonia_cache_image/paulonia_cache_image_web.dart';

import 'constants.dart';

class InMemoryManager {
  /// Stores the images in memory
  static HashMap<String, ImageStreamCompleter> _manager = HashMap();
  static List<String> _savedImages;
  static int _maxInMemoryImages;

  /// Initialize the the In-memory manager
  static void init(
      {int maxInMemoryImages = Constants.INFINITE_IN_MEMORY_IMAGES}) {
    _maxInMemoryImages = maxInMemoryImages;
    _savedImages = List();
  }

  /// Get the image
  ///
  /// Verifies if the image is in memory cache and returns it. Otherwise it calls
  /// [getImage()] from the service of the platform.
  static ImageStreamCompleter getImage(PCacheImage key) {
    if (_manager.containsKey(key.url)) return _manager[key.url];
    ImageStreamCompleter res = MultiFrameImageStreamCompleter(
      codec: PCacheImageService.getImage(
        key.url,
        key.retryDuration,
        key.maxRetryDuration,
        key.enableCache,
      ),
      scale: key.imageScale,
    );
    if (_maxInMemoryImages != 0 && _savedImages.length == _maxInMemoryImages) {
      String removedUrl = _savedImages.removeAt(0);
      _manager.remove(removedUrl);
    }
    _savedImages.add(key.url);
    _manager[key.url] = res;
    return res;
  }
}
