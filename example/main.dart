/*
 * Copyright (c) 2019. Black Salt Kft.  All rights reserved.
 * Author: Albert Papp
 *
 */
import 'dart:io';

import 'package:pixabay_picker/model/PixabayMedia.dart';
import 'package:pixabay_picker/pixabay_picker.dart';

import 'key.dart';

void main() async {
  PixabayPicker picker = PixabayPicker(apiKey: ApiKey, language: "hu");

  PixabayResponse res = await picker.api
      .requestImages(resultsPerPage: 1, category: Category.business);

  if (res != null) {
    res.hits.forEach((f) {
      print(f);
    });
  }

  print("--------------------------------------");

  res = await picker.api
      .requestImagesWithKeyword(keyword: "kutya", resultsPerPage: 30);

  if (res != null) {
    res.hits.forEach((f) {
      print(f);
    });

    BytesBuilder bytes =
        await picker.api.downloadMedia(res.hits[0], Resolution.medium);

    print(bytes.length);
  }

  res = await picker.api.requestVideos();

  if (res != null) {
    res.hits.forEach((f) {
      print(f);
    });
  }

  res = await picker.api
      .requestVideosWithKeyword(keyword: "kutya", resultsPerPage: 30);
  if (res != null) {
    res.hits.forEach((f) {
      print(f);
    });

    BytesBuilder bytes =
        await picker.api.downloadMedia(res.hits[0], Resolution.medium);

    print(bytes.length);
  }
}
