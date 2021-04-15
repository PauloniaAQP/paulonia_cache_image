import 'dart:convert';
import 'dart:io';

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:paulonia_cache_image/utils.dart';
import 'package:http/http.dart' as http;

/// Paulonia cache image service for mobile
///
/// This class has all function to download, store and get the images.
class PCacheImageService {
  /// Temporal directory path
  static late String _tempPath;

  /// Codec used to convert the image url to base 64; the id of the images in
  /// the storage.
  static final Codec<String, String> _stringToBase64 = utf8.fuse(base64);

  /// Initialize the service on mobile
  ///
  /// This function initialize the path of the temporal directory
  /// [proxy] is unused in this service.
  static Future<void> init({String? proxy}) async {
    _tempPath = (await getTemporaryDirectory()).path;
  }

  /// Get the image codec
  ///
  /// This function gets the image codec of [url]. It verifies if the image is
  /// in cache and returns it if [enableCache] is true. If the images is not in cache
  /// then the function download the image and stores in cache if [enableCache]
  /// is true.
  static Future<ui.Codec> getImage(
    String url,
    Duration retryDuration,
    Duration maxRetryDuration,
    bool enableCache,
  ) async {
    Uint8List bytes;
    String id = _stringToBase64.encode(url);
    String path = _tempPath + '/' + id;
    final File file = File(path);
    if (_fileIsCached(file))
      bytes = file.readAsBytesSync();
    else {
      bytes = await _downloadImage(url, retryDuration, maxRetryDuration);
      if (bytes.lengthInBytes != 0) {
        if (enableCache) {
          file.create(recursive: true);
          file.writeAsBytes(bytes);
        }
      } else {
        /// TODO The image can be downloaded
        return PaintingBinding.instance!.instantiateImageCodec(Uint8List(0));
      }
    }
    return PaintingBinding.instance!.instantiateImageCodec(bytes);
  }

  /// Downloads the image
  ///
  /// If the [url] is a Google Cloud Storage url, then the function get the download
  /// url. The function sends a GET requests to [url] and return the binary response.
  /// If there is an error in the requests, then the function retry the download
  /// after [retryDuration]. If the accumulated time of the retry attempts is
  /// greater than [maxRetryDuration] then the function returns an empty list
  /// of bytes.
  static Future<Uint8List> _downloadImage(
    String url,
    Duration retryDuration,
    Duration maxRetryDuration,
  ) async {
    int totalTime = 0;
    Uint8List bytes = Uint8List(0);
    Duration _retryDuration = Duration(microseconds: 1);
    if (Utils.isGsUrl(url)) url = await (_getStandardUrlFromGsUrl(url));
    while (
        totalTime <= maxRetryDuration.inSeconds && bytes.lengthInBytes <= 0) {
      await Future.delayed(_retryDuration).then((_) async {
        try {
          http.Response response = await http.get(Uri.parse(url));
          bytes = response.bodyBytes;
        } catch (error) {
          _retryDuration = retryDuration;
          totalTime += retryDuration.inSeconds;
        }
      });
    }
    return bytes;
  }

  /// Verifies if [file] is stored on cache
  static bool _fileIsCached(File file) {
    if (file.existsSync() && file.lengthSync() > 0) {
      return true;
    }
    return false;
  }

  /// Get the network from a [gsUrl]
  ///
  /// This function get the download url from a Google Cloud Storage url
  static Future<dynamic> _getStandardUrlFromGsUrl(String gsUrl) async {
    Uri uri = Uri.parse(gsUrl);
    return FirebaseStorage.instance.ref().child(uri.path).getDownloadURL();
  }
}
