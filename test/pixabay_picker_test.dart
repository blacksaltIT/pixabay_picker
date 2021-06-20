import 'dart:async';

import 'package:pixabay_picker/model/pixabay_media.dart';
import 'package:pixabay_picker/pixabay_api.dart';
import 'package:test/test.dart';

import '../example/key.dart';

void main() async {
  // todo
  group('Pixabay Picker Tests:', () {
    late PixabayMediaProvider api;

    setUp(() {
      api = PixabayMediaProvider(apiKey: ApiKey, language: "en");
    });

    test('Get photos by category...', () async {
      PixabayResponse? res = await api.requestImages(
          resultsPerPage: 1, category: Category.business);
      equals((res != null && res.hits!.isNotEmpty) == true);
    });

    test('Request random videos...', () async {
      PixabayResponse? res = await api.requestVideos();
      equals((res != null && res.hits!.isNotEmpty) == true);
    });

    test('Stream controller', () async {
      double? progress;
      PixabayResponse? res = await api.requestVideosWithKeyword(
          keyword: "dog", resultsPerPage: 30);
      if (res != null) {
        StreamSubscription subscription =
            api.progressStreamController.stream.listen((data) {
          progress = data;
          //print(data.toString());
        });
        await api.downloadMedia(res.hits![0], Resolution.medium);
        subscription.cancel();
      }
      equals((res != null && res.hits!.isNotEmpty && progress == 1.0) == true);
    });
  });
}
