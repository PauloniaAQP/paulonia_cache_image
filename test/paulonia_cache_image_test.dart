import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:paulonia_cache_image/InMemoryManager.dart';
import 'package:paulonia_cache_image/constants.dart';
import 'package:paulonia_cache_image/global_values.dart';
import 'package:paulonia_cache_image/paulonia_cache_image.dart';
import 'package:paulonia_cache_image/paulonia_cache_image_mobile.dart'
    if (dart.library.html) 'package:paulonia_cache_image/paulonia_cache_image_web.dart';

class TestCanvas implements Canvas {
  final List<Invocation> invocations = <Invocation>[];

  @override
  void noSuchMethod(Invocation invocation) {
    invocations.add(invocation);
  }
}

void main() {
  Future<ui.Codec> _basicDecoder(Uint8List bytes,
      {int? cacheWidth, int? cacheHeight, bool? allowUpscaling}) {
    return ui.instantiateImageCodec(bytes,
        allowUpscaling: allowUpscaling ?? false);
  }

  group('Initialize package', () {
    test('with default values', () async {
      await PCacheImage.init();
      expect(GlobalValues.globalImageScale, Constants.DEFAULT_IMAGE_SCALE);
      expect(GlobalValues.globalEnableCacheValue,
          Constants.DEFAULT_ENABLE_CACHE_VALUE);
      expect(
          GlobalValues.globalRetryDuration, Constants.DEFAULT_RETRY_DURATION);
      expect(GlobalValues.globalMaxRetryDuration,
          Constants.DEFAULT_MAX_RETRY_DURATION);
      expect(
          GlobalValues.globalInMemoryValue, Constants.DEFAULT_IN_MEMORY_VALUE);
      expect(InMemoryManager.maxInMemoryImages,
          Constants.DEFAULT_IN_MEMORY_IMAGES);
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

  group('Cache functions:', () {
    List<String> validUrls = [
      'https://i.imgur.com/jhRBVEp.jpg',
      'https://i.imgur.com/5RhnXjE.jpg',
      'https://i.imgur.com/inAkwKw.jpg',
    ];

    test('load() & clearAllCacheImages()', () async {
      final List<dynamic> capturedErrors = <dynamic>[];

      expect(PCacheImageService.length, equals(0));
      expect(InMemoryManager.length, equals(0));

      void loadImage(String url,
          {bool enableCache = true, bool enableInMemory = false}) {
        PCacheImage image = PCacheImage(url,
            enableCache: enableCache, enableInMemory: enableInMemory);
        var completer = image.load(image, _basicDecoder);
        completer.addListener(ImageStreamListener(
          (ImageInfo image, bool synchronousCall) {},
          onError: (dynamic error, StackTrace? stackTrace) {
            capturedErrors.add(error);
          },
        ));
      }

      /// Normal behaviour
      await PCacheImage.init();
      loadImage(validUrls.first);
      await Future.delayed(Duration(seconds: 2));
      expect(capturedErrors, isEmpty);
      expect(PCacheImageService.length, equals(1));
      expect(InMemoryManager.length, equals(0));

      /// Cached image
      loadImage(validUrls.first);
      await Future.delayed(Duration(seconds: 2));
      expect(capturedErrors, isEmpty);
      expect(PCacheImageService.length, equals(1));
      expect(InMemoryManager.length, equals(0));

      /// In memory cache
      loadImage(validUrls[1], enableInMemory: true);
      await Future.delayed(Duration(seconds: 2));
      expect(capturedErrors, isEmpty);
      expect(PCacheImageService.length, equals(2));
      expect(InMemoryManager.length, equals(1));

      /// In memory cached image
      loadImage(validUrls[1], enableInMemory: true);
      await Future.delayed(Duration(seconds: 2));
      expect(capturedErrors, isEmpty);
      expect(PCacheImageService.length, equals(2));
      expect(InMemoryManager.length, equals(1));

      /// Not cached image
      loadImage(validUrls[2], enableCache: false);
      await Future.delayed(Duration(seconds: 2));
      expect(capturedErrors, isEmpty);
      expect(PCacheImageService.length, equals(2));
      expect(InMemoryManager.length, equals(1));

      /// Clear all images
      await PCacheImage.clearAllCacheImages(eraseMemory: true);
      await Future.delayed(Duration(seconds: 2));
      expect(PCacheImageService.length, equals(0));
      expect(InMemoryManager.length, equals(0));
    });
  });
}
