/*
 * Copyright (c) 2019. Black Salt Kft.  All rights reserved.
 * Author: Albert Papp
 *
 */
import 'dart:io';

import 'package:pixabay_picker/model/pixabay_media.dart';
import 'package:pixabay_picker/pixabay_api.dart';

import 'key.dart'; // import your API key

void main() async {
  PixabayImageProvider api =
      PixabayImageProvider(apiKey: ApiKey, language: "hu");

  PixabayResponse res =
      await api.requestImages(resultsPerPage: 1, category: Category.business);

  if (res != null) {
    res.hits.forEach((f) {
      print(f);
    });
  }

  print("--------------------------------------");

  res =
      await api.requestImagesWithKeyword(keyword: "kutya", resultsPerPage: 30);

  if (res != null) {
    res.hits.forEach((f) {
      print(f);
    });

    BytesBuilder bytes =
        await api.downloadMedia(res.hits[0], Resolution.medium);

    print(bytes.length);
  }

  res = await api.requestVideos();

  if (res != null) {
    res.hits.forEach((f) {
      print(f);
    });
  }

  res =
      await api.requestVideosWithKeyword(keyword: "kutya", resultsPerPage: 30);
  if (res != null) {
    res.hits.forEach((f) {
      print(f);
    });

    BytesBuilder bytes =
        await api.downloadMedia(res.hits[0], Resolution.medium);

    print(bytes.length);
  }

  Stream<Map<String, Map<MediaType, PixabayResponse>>> result =
      api.requestMapByCategory(
          photoResultsPerCategory: 3, videoResultsPerCategory: 3);

  result.listen((Map<String, Map<MediaType, PixabayResponse>> onData) {
    var values = onData.values.toList();
    var keys = onData.keys.toList();

    print(keys[0] + ":" + values[0][MediaType.video].hits[0].toString());
    print(keys[0] + ":" + values[0][MediaType.photo].hits[0].toString());
  });
}
