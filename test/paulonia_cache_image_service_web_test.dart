@TestOn('chrome')

import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:paulonia_cache_image/hive_cache_image.dart';
import 'package:paulonia_cache_image/paulonia_cache_image.dart';
import 'package:paulonia_cache_image/paulonia_cache_image_web.dart';

void main() {

  group('Web service functions:', () {
    test('Hive CRUD: saveHiveImage(), getHiveImage(), deleteHiveImage(), clearAllImages()', () async{
      Uint8List randomBytes = Uint8List.fromList([0,0,1,0,1]);
      await PCacheImage.init();

      expect(PCacheImageService.cacheBox.isEmpty, isTrue);
      String url = 'pcacheImageTestFile';
      PCacheImageService.saveHiveImage(url, randomBytes);
      expect(PCacheImageService.cacheBox.length, 1);

      HiveCacheImage? image = PCacheImageService.getHiveImage(url);
      expect(image, isNotNull);
      expect(image!.binaryImage.lengthInBytes, randomBytes.lengthInBytes);

      await PCacheImageService.deleteHiveImage(url);
      image = PCacheImageService.getHiveImage(url);
      expect(PCacheImageService.cacheBox.isEmpty, isTrue);
      expect(image, isNull);

      PCacheImageService.saveHiveImage(url, randomBytes);
      expect(PCacheImageService.cacheBox.length, 1);
      await PCacheImageService.clearAllImages();
      expect(PCacheImageService.cacheBox.isEmpty, isTrue);
    });
  });

}