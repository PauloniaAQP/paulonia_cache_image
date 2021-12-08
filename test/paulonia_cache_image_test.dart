import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paulonia_cache_image/InMemoryManager.dart';
import 'package:paulonia_cache_image/constants.dart';
import 'package:paulonia_cache_image/global_values.dart';
import 'package:paulonia_cache_image/paulonia_cache_image.dart';

void main() {

  group('Initialize package', () {
    test('with default values', () async {
      await PCacheImage.init();
      expect(GlobalValues.globalImageScale, Constants.DEFAULT_IMAGE_SCALE);
      expect(GlobalValues.globalEnableCacheValue, Constants.DEFAULT_ENABLE_CACHE_VALUE);
      expect(GlobalValues.globalRetryDuration, Constants.DEFAULT_RETRY_DURATION);
      expect(GlobalValues.globalMaxRetryDuration, Constants.DEFAULT_MAX_RETRY_DURATION);
      expect(GlobalValues.globalInMemoryValue, Constants.DEFAULT_IN_MEMORY_VALUE);
      expect(InMemoryManager.maxInMemoryImages, Constants.DEFAULT_IN_MEMORY_IMAGES);
      if (kIsWeb) {
        expect(Hive.isBoxOpen(Constants.HIVE_CACHE_IMAGE_BOX), isTrue);
        expect(Hive.isAdapterRegistered(17), isTrue);
      }
    });

    test('with custom values', () async {
      double imageScale = 3.0;
      bool enableCache = false;
      int retryDuration = 2;
      int maxRetryDuration = 20;
      bool enableInMemory = false;
      int maxInMemoryImages = 4;

      await PCacheImage.init(
        imageScale: imageScale,
        enableCache: enableCache,
        retryDuration: retryDuration,
        maxRetryDuration: maxRetryDuration,
        enableInMemory: enableInMemory,
        maxInMemoryImages: maxInMemoryImages,
      );

      expect(GlobalValues.globalImageScale, imageScale);
      expect(GlobalValues.globalEnableCacheValue, enableCache);
      expect(GlobalValues.globalRetryDuration, retryDuration);
      expect(GlobalValues.globalMaxRetryDuration, maxRetryDuration);
      expect(GlobalValues.globalInMemoryValue, enableInMemory);
      expect(InMemoryManager.maxInMemoryImages, maxInMemoryImages);
      if (kIsWeb) {
        expect(Hive.isBoxOpen(Constants.HIVE_CACHE_IMAGE_BOX), isTrue);
        expect(Hive.isAdapterRegistered(17), isTrue);
      }
    });
  });
}
