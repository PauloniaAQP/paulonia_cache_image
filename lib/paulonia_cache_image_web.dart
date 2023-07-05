import 'dart:convert';
import 'dart:ui' as ui;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:paulonia_cache_image/constants.dart';
import 'package:http/http.dart' as http;

import 'package:paulonia_cache_image/hive_cache_image.dart';
import 'package:paulonia_cache_image/utils.dart';

class PCacheImageService {
  /// Url of the proxy entry point set by the user
  ///
  /// This proxy is used only with network images in web. This allow to user
  /// to set another entry point to fix the CORS problem with that type of images.
  static String? _proxy;

  /// Codec used to convert the image url to base 64; the id of the images in
  /// the storage.
  static final Codec<String, String> _stringToBase64 = utf8.fuse(base64);

  /// Hive box used to store the image as a persistent storage
  static var _cacheBox = Hive.box(Constants.HIVE_CACHE_IMAGE_BOX);
  static get cacheBox => _cacheBox;

  /// Initialize the service on web
  ///
  /// This function initialize the [proxy] that the service uses in the
  /// network images.
  static Future<void> init({String? proxy}) {
    _proxy = proxy;
    return SynchronousFuture<void>(null);
  }

  /// Get the image codec
  ///
  /// This function gets the image codec of [url]. It verifies if the image is
  /// in cache and returns it if [enableCache] is true. If the images is not in cache
  /// then the function download the image and stores in cache if [enableCache]
  /// is true.
  static Future<ui.Codec> getImage(String url, Duration retryDuration, Duration maxRetryDuration, bool enableCache,
      {bool clearCacheImage = false}) async {
    Uint8List bytes;
    if (clearCacheImage) {
      await deleteHiveImage(url);
    }
    HiveCacheImage? cacheImage = getHiveImage(url);
    if (cacheImage == null) {
      bytes = await downloadImage(
        url,
        retryDuration,
        maxRetryDuration,
      );
      if (bytes.lengthInBytes != 0) {
        if (enableCache) saveHiveImage(url, bytes);
      } else {
        /// TODO
        throw "Image couldn't be downloaded";
      }
    } else {
      bytes = cacheImage.binaryImage;
    }
    return ui.instantiateImageCodec(bytes);
  }

  /// delete all images from storage
  static Future<void> clearAllImages() async {
    await _cacheBox.close();
    await _cacheBox.deleteFromDisk();
    _cacheBox = await Hive.openBox(Constants.HIVE_CACHE_IMAGE_BOX);
  }

  /// Gets the number of cached images in the actual session
  static int get length => _cacheBox.length;

  /// Downloads the image
  ///
  /// If the [url] is a Google Cloud Storage url, then the function get the download
  /// url. The function sends a GET requests to [url] and return the binary response.
  /// If there is an error in the requests, then the function retry the download
  /// after [retryDuration]. If the accumulated time of the retry attempts is
  /// greater than [maxRetryDuration] then the function returns an empty list
  /// of bytes.
  /// If the url is a network image and [_proxy] is set, then the function
  /// make the request to the proxy (ex. https://my-proxy.com/http:\\my-image-url.jpg)
  @visibleForTesting
  static Future<Uint8List> downloadImage(
    String url,
    Duration retryDuration,
    Duration maxRetryDuration,
  ) async {
    int totalTime = 0;
    Uint8List bytes = Uint8List(0);
    Duration _retryDuration = Duration(microseconds: 1);
    if (Utils.isGsUrl(url))
      url = await _getStandardUrlFromGsUrl(url);
    else if (_proxy != null) url = _proxy! + url;
    while (totalTime <= maxRetryDuration.inSeconds && bytes.lengthInBytes <= 0) {
      await Future.delayed(_retryDuration).then((_) async {
        try {
          http.Response response = await http.get(Uri.parse(url));
          bytes = response.bodyBytes;
          if (bytes.lengthInBytes <= 0) {
            _retryDuration = retryDuration;
            totalTime += retryDuration.inSeconds;
          }
        } catch (error) {
          _retryDuration = retryDuration;
          totalTime += retryDuration.inSeconds;
        }
      });
    }
    return bytes;
  }

  /// Get the image form the hive storage
  @visibleForTesting
  static HiveCacheImage? getHiveImage(String url) {
    String id = _stringToBase64.encode(url);
    if (!_cacheBox.containsKey(id)) return null;
    return _cacheBox.get(id);
  }

  /// Delete the image form the hive storage
  @visibleForTesting
  static Future<void> deleteHiveImage(String url) {
    String id = _stringToBase64.encode(url);
    return _cacheBox.delete(id);
  }

  /// Save the image in the hive storage
  @visibleForTesting
  static HiveCacheImage saveHiveImage(String url, Uint8List image) {
    String id = _stringToBase64.encode(url);
    HiveCacheImage cacheImage = HiveCacheImage(
      url: url,
      binaryImage: image,
    );
    _cacheBox.put(id, cacheImage);
    return cacheImage;
  }

  /// Get the network from a [gsUrl]
  ///
  /// This function get the download url from a Google Cloud Storage url
  static Future<String> _getStandardUrlFromGsUrl(String gsUrl) async {
    Uri uri = Uri.parse(gsUrl);
    String bucketName = '${uri.scheme}://${uri.authority}';
    FirebaseStorage storage = FirebaseStorage.instanceFor(bucket: bucketName);
    return await storage.ref().child(uri.path).getDownloadURL();
  }
}
