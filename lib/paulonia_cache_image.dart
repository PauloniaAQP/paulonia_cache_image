library paulonia_cache_image;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:paulonia_cache_image/InMemoryManager.dart';
import 'package:paulonia_cache_image/constants.dart';
import 'package:paulonia_cache_image/hive_cache_image.dart';
import 'package:paulonia_cache_image/paulonia_cache_image_mobile.dart'
    if (dart.library.html) 'package:paulonia_cache_image/paulonia_cache_image_web.dart';

class PCacheImage extends ImageProvider<PCacheImage> {
  PCacheImage(
    this.url, {
    this.imageScale = Constants.DEFAULT_IMAGE_SCALE,
    this.enableCache = Constants.DEFAULT_ENABLE_CACHE_VALUE,
    this.retryDuration =
        const Duration(seconds: Constants.DEFAULT_RETRY_DURATION),
    this.maxRetryDuration =
        const Duration(seconds: Constants.DEFAULT_MAX_RETRY_DURATION),
    this.enableInMemory = Constants.DEFAULT_IN_MEMORY_VALUE,
  }) : assert(url != null);

  /// The url of the image
  final String url;

  /// The image scale
  final double imageScale;

  /// Enable or disable the cache.
  final bool enableCache;

  /// If download fails, retry after this duration
  final Duration retryDuration;

  /// Max accumulated time of retries
  final Duration maxRetryDuration;

  /// Enable the in memory cache
  final bool enableInMemory;

  /// Initialize the cache image package
  ///
  /// * This function must to be called in the start of the app (on main.dart)
  ///
  /// You can use [proxy] to set another entry point to send the GET request
  /// (ex. https://my-proxy.com/http:\\my-image-url.jpg).
  /// This param is used generally on web with network images for CORS. The proxy
  /// sends the CORS confirmation to the web app and then sends the image.
  static Future<void> init({String proxy}) async {
    PCacheImageService.init(proxy: proxy);
    if (kIsWeb) {
      Hive..registerAdapter(HiveCacheImageAdapter());
      if (!Hive.isBoxOpen(Constants.HIVE_CACHE_IMAGE_BOX)) {
        await Hive.openBox(Constants.HIVE_CACHE_IMAGE_BOX);
      }
    }
  }

  @override
  Future<PCacheImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PCacheImage>(this);
  }

  @override
  ImageStreamCompleter load(PCacheImage key, DecoderCallback decode) {
    if (enableCache && enableInMemory) return InMemoryManager.getImage(key);
    return MultiFrameImageStreamCompleter(
      codec: PCacheImageService.getImage(
          url, retryDuration, maxRetryDuration, enableCache),
      scale: key.imageScale,
    );
  }
}
