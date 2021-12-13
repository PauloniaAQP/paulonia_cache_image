import 'package:flutter_test/flutter_test.dart';
import 'package:paulonia_cache_image/utils.dart';

void main() {

  group('Utils functions:', () {
    test('isGsUrl()', () {
      String gsUrl = 'gs://test.appspot.com/images/answers/jIAaGJrUR23t2XRBvOcN.png';
      String networkUrl = 'https://i.imgur.com/jhRBVEp.jpg';

      expect(Utils.isGsUrl(gsUrl), isTrue);
      expect(Utils.isGsUrl(networkUrl), isFalse);
    });
  });

}