import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'hive_cache_image.g.dart';

@HiveType(typeId: 17)
class HiveCacheImage {
  @HiveField(0)
  String url;

  @HiveField(1)
  Uint8List binaryImage;

  HiveCacheImage({
    required this.url,
    required this.binaryImage,
  });
}
