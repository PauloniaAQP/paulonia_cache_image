library paulonia_cache_image;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:paulonia_cache_image/InMemoryManager.dart';
import 'package:paulonia_cache_image/constants.dart';
import 'package:paulonia_cache_image/global_values.dart';
import 'package:paulonia_cache_image/hive_cache_image.dart';
import 'package:paulonia_cache_image/paulonia_cache_image_mobile.dart'
    if (dart.library.html) 'package:paulonia_cache_image/paulonia_cache_image_web.dart';

import 'InMemoryManager.dart';

class PCacheImage extends ImageProvider<PCacheImage> {
  PCacheImage(
    this.url, {
    this.imageScale,
    this.enableCache,
    this.retryDuration,
    this.maxRetryDuration,
    this.enableInMemory,
  });

  /// The url of the image
  final String url;

  /// The image scale
  double? imageScale;

  /// Enable or disable the cache.
  bool? enableCache;

  /// If download fails, retry after this duration
  Duration? retryDuration;

  /// Max accumulated time of retries
  Duration? maxRetryDuration;

  /// Enable the in memory cache
  bool? enableInMemory;

  /// Initialize the cache image package
  ///
  /// * This function must to be called in the start of the app (on main.dart)
  ///
  /// In this function you can set the default values to change it in all
  /// PCacheImage widgets in the app
  ///
  /// You can use [proxy] to set another entry point to send the GET request
  /// (ex. https://my-proxy.com/http:\\my-image-url.jpg).
  /// This param is used generally on web with network images for CORS. The proxy
  /// sends the CORS confirmation to the web app and then sends the image.
  static Future<void> init(
      {double imageScale = Constants.DEFAULT_IMAGE_SCALE,
      bool enableCache = Constants.DEFAULT_ENABLE_CACHE_VALUE,
      int retryDuration = Constants.DEFAULT_RETRY_DURATION,
      int maxRetryDuration = Constants.DEFAULT_MAX_RETRY_DURATION,
      bool enableInMemory = Constants.DEFAULT_IN_MEMORY_VALUE,
      int maxInMemoryImages = Constants.DEFAULT_IN_MEMORY_IMAGES,
      String? proxy}) async {
    await PCacheImageService.init(proxy: proxy);
    InMemoryManager.init(maxInMemoryImages: maxInMemoryImages);
    GlobalValues.globalImageScale = imageScale;
    GlobalValues.globalEnableCacheValue = enableCache;
    GlobalValues.globalRetryDuration = retryDuration;
    GlobalValues.globalMaxRetryDuration = maxRetryDuration;
    GlobalValues.globalInMemoryValue = enableInMemory;
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
    _initializeValues();
    if (enableCache! && enableInMemory!) return InMemoryManager.getImage(key);
    return MultiFrameImageStreamCompleter(
      codec: PCacheImageService.getImage(
          url, retryDuration!, maxRetryDuration!, enableCache!),
      scale: key.imageScale!,
    );
  }

  /// Initialize the null values to the global values
  void _initializeValues() {
    if (imageScale == null) imageScale = GlobalValues.globalImageScale;
    if (enableCache == null) enableCache = GlobalValues.globalEnableCacheValue;
    if (retryDuration == null)
      retryDuration = Duration(seconds: GlobalValues.globalRetryDuration);
    if (maxRetryDuration == null)
      maxRetryDuration = Duration(seconds: GlobalValues.globalMaxRetryDuration);
    if (enableInMemory == null)
      enableInMemory = GlobalValues.globalInMemoryValue;
  }
}
