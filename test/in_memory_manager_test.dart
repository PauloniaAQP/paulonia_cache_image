import 'package:flutter_test/flutter_test.dart';
import 'package:paulonia_cache_image/InMemoryManager.dart';
import 'package:paulonia_cache_image/paulonia_cache_image.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'utils.dart';

void main() {
  group('In memory manager functions:', () {
    setUp(() async {
      PathProviderPlatform.instance = FakePathProviderPlatform();
    });

    List<String> validUrls = [
      'https://i.imgur.com/jhRBVEp.jpg',
      'https://i.imgur.com/5RhnXjE.jpg',
      'https://i.imgur.com/inAkwKw.jpg',
    ];

    test('getImage() && clearAllImages()', () async {
      await PCacheImage.init(maxInMemoryImages: 7);

      /// Normal behaviour
      expect(InMemoryManager.length, equals(0));
      for (int i = 0; i < validUrls.length; i++) {
        PCacheImage key = PCacheImage(
          validUrls[i],
          retryDuration: Duration(seconds: 1),
          maxRetryDuration: Duration(seconds: 5),
          enableCache: true,
          imageScale: 1,
        );

        InMemoryManager.getImage(key);
        expect(InMemoryManager.length, equals(i + 1));
      }
      expect(InMemoryManager.length, equals(validUrls.length));

      /// Cached image
      PCacheImage key = PCacheImage(
        validUrls.first,
        retryDuration: Duration(seconds: 1),
        maxRetryDuration: Duration(seconds: 5),
        enableCache: true,
        imageScale: 1,
      );
      InMemoryManager.getImage(key);
      expect(InMemoryManager.length, equals(validUrls.length));

      /// Clear image
      InMemoryManager.getImage(key, clearMemoryImg: true);
      expect(InMemoryManager.length, equals(validUrls.length));

      /// Clear all images
      await InMemoryManager.clearAllImages();
      expect(InMemoryManager.length, equals(0));

      /// Verify images queue
      await PCacheImage.init(maxInMemoryImages: 2);
      for (int i = 0; i < validUrls.length; i++) {
        PCacheImage key = PCacheImage(
          validUrls[i],
          retryDuration: Duration(seconds: 1),
          maxRetryDuration: Duration(seconds: 5),
          enableCache: true,
          imageScale: 1,
        );

        InMemoryManager.getImage(key);
      }
      expect(InMemoryManager.length, equals(2));
      expect(InMemoryManager.savedImages.first, equals(validUrls[1]));
      expect(InMemoryManager.savedImages.last, equals(validUrls.last));
    });
  });
}
