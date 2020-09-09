// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_cache_image.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveCacheImageAdapter extends TypeAdapter<HiveCacheImage> {
  @override
  final int typeId = 17;

  @override
  HiveCacheImage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveCacheImage(
      url: fields[0] as String,
      binaryImage: fields[1] as Uint8List,
    );
  }

  @override
  void write(BinaryWriter writer, HiveCacheImage obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.binaryImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveCacheImageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
