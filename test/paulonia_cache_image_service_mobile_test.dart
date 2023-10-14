@TestOn('vm')

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:paulonia_cache_image/paulonia_cache_image_mobile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'utils.dart';

void main() {
  group('Mobile service functions:', () {
    setUp(() async {
      PathProviderPlatform.instance = FakePathProviderPlatform();
    });

    File validFile = File('./test/data/testText.txt');

    test('fileIsCached()', () {
      File invalidFile = File('');
      expect(PCacheImageService.fileIsCached(validFile), isTrue);
      expect(PCacheImageService.fileIsCached(invalidFile), isFalse);
    });

    test('saveFile() & clearAllImages()', () async {
      expect(PCacheImageService.cachedPaths, isEmpty);

      var tempPath = (await getTemporaryDirectory()).path;
      String path = tempPath + '/pcacheImageTestFile';
      File file = File(path);
      PCacheImageService.saveFile(file, validFile.readAsBytesSync());
      await file.length();

      /// To re sync with the file
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), validFile.lengthSync());
      expect(PCacheImageService.cachedPaths.length, 1);
      expect(PCacheImageService.cachedPaths.first, path);

      await PCacheImageService.clearAllImages();
      expect(file.existsSync(), isFalse);
      expect(PCacheImageService.cachedPaths, isEmpty);
    });
  });
}
