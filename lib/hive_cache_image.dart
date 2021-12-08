import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:paulonia_cache_image/constants.dart';

part 'hive_cache_image.g.dart';

@HiveType(typeId: Constants.HIVE_ADAPTER_ID)
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
