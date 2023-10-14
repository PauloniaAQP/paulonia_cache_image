import 'package:flutter_test/flutter_test.dart';
import 'package:paulonia_cache_image/paulonia_cache_image.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:paulonia_cache_image/paulonia_cache_image_mobile.dart'
    if (dart.library.html) 'package:paulonia_cache_image/paulonia_cache_image_web.dart';

import 'utils.dart';

void main() {
  group('Service functions:', () {
    setUp(() async {
      PathProviderPlatform.instance = FakePathProviderPlatform();
    });

    List<String> validUrls = [
      'https://i.imgur.com/aWLjDHS.jpg',
      'https://i.imgur.com/5laDaRD.jpg',
      'https://i.imgur.com/IWA7U8X.jpg',
    ];

    test('downloadImage()', () async {
      String invalidUrl = 'https://i.imgur.com/in.jpg';

      for (String testUrl in validUrls) {
        var bytes = await PCacheImageService.downloadImage(
          testUrl,
          Duration(seconds: 1),
          Duration(seconds: 3),
        );
        expect(bytes.lengthInBytes != 0, isTrue);
      }

      var bytes = await PCacheImageService.downloadImage(
        invalidUrl,
        Duration(seconds: 1),
        Duration(seconds: 3),
      );
      expect(bytes.lengthInBytes, equals(0));
    });

    test('getImage()', () async {
      await PCacheImage.init();

      expect(PCacheImageService.length, equals(0));

      /// Without cache
      await PCacheImageService.getImage(
        validUrls.first,
        Duration(seconds: 1),
        Duration(seconds: 5),
        false,
      );
      expect(PCacheImageService.length, equals(0));

      /// Normal behaviour
      for (int i = 0; i < validUrls.length; i++) {
        var codec = await PCacheImageService.getImage(
          validUrls[i],
          Duration(seconds: 1),
          Duration(seconds: 5),
          true,
        );
        expect(codec.frameCount, equals(1));
        expect(PCacheImageService.length, equals(i + 1));
      }

      /// Cached image
      await PCacheImageService.getImage(
        validUrls.first,
        Duration(seconds: 1),
        Duration(seconds: 5),
        true,
      );
      expect(PCacheImageService.length, equals(validUrls.length));

      /// Clear and not cached
      await PCacheImageService.getImage(
        validUrls.first,
        Duration(seconds: 1),
        Duration(seconds: 5),
        false,
        clearCacheImage: true,
      );
      expect(PCacheImageService.length, equals(validUrls.length - 1));

      /// Clear and cached
      await PCacheImageService.getImage(
        validUrls.last,
        Duration(seconds: 1),
        Duration(seconds: 5),
        true,
        clearCacheImage: true,
      );
      expect(PCacheImageService.length, equals(validUrls.length - 1));

      /// To clear the cache for other tests
      await PCacheImageService.clearAllImages();
    });
  });
}
