/*
 * Copyright (c) 2019. Black Salt Kft.  All rights reserved.
 * Author: Albert Papp
 *
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:pixabay_picker/model/PixabayMedia.dart';

class PixabayImageProvider {
  final String apiKey;
  String language;

  PixabayImageProvider({this.apiKey, String language}) {
    this.language = language ?? 'en';
  }

  Future<PixabayResponse> requestImages(
      {int resultsPerPage = 30, int page, String category}) async {
    return requestMediaWithKeyword(
        media: MediaType.photo,
        resultsPerPage: resultsPerPage,
        page: page,
        category: category);
  }

  // pageing is prepared but not used yet
  // we just return the first 30 image
  Future<PixabayResponse> requestImagesWithKeyword(
      {String keyword,
      int resultsPerPage = 30,
      int page,
      String category}) async {
    return requestMediaWithKeyword(
        media: MediaType.photo,
        keyword: keyword,
        resultsPerPage: resultsPerPage,
        page: page,
        category: category);
  }

  Future<PixabayResponse> requestVideos(
      {int resultsPerPage = 30, int page, String category}) async {
    return requestMediaWithKeyword(
        media: MediaType.video,
        resultsPerPage: resultsPerPage,
        page: page,
        category: category);
  }

  // pageing is prepared but not used yet
  // we just return the first 30 image
  Future<PixabayResponse> requestVideosWithKeyword(
      {String keyword,
      int resultsPerPage = 30,
      int page,
      String category}) async {
    return requestMediaWithKeyword(
        media: MediaType.video,
        keyword: keyword,
        resultsPerPage: resultsPerPage,
        page: page,
        category: category);
  }

  getImages(String url) async {
    // setup Http Get
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    // Process the response.
    if (response.statusCode == 200) {
      // response: OK
      // decode JSON
      String json = await response.transform(utf8.decoder).join();
      var data = jsonDecode(json);
      return data;
    } else {
      // something went wrong :(
      print("Http error: ${response.statusCode}");
      return [];
    }
  }

  getVideos(String url) async {
    // setup Http Get
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    // Process the response.
    if (response.statusCode == 200) {
      // response: OK
      // decode JSON
      String json = await response.transform(utf8.decoder).join();
      var data = jsonDecode(json);
      return data;
    } else {
      // something went wrong :(
      print("Http error: ${response.statusCode}");
      return [];
    }
  }

  Future<BytesBuilder> downloadMedia(PixabayMedia media, String res,
      [Function callback]) async {
    var completer = new Completer<BytesBuilder>();

    HttpClient httpClient = new HttpClient();
    String downloadUrl = media.getDownloadLink(res: res);

    print("Downloading $downloadUrl");
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(downloadUrl));
    HttpClientResponse response = await request.close();
    // Process the response.
    if (response.statusCode == 200) {
      // response: OK
      int fileSize = response.contentLength;
      int downloaded = 0;

      // store on file system?
      // String dir = (await getApplicationDocumentsDirectory()).path;
      //response.pipe(File('$dir/${image.getId()}.jpg').openWrite());

      var contents = new BytesBuilder();

      response.listen((List<int> data) {
        downloaded += data.length;
        contents.add(data);
        // handle data
        double progress = downloaded / fileSize;

        if (callback != null) callback(progress);
      }, onDone: () => completer.complete(contents));
    } else {
      // something went wrong :(
      print("Http error: ${response.statusCode}");
    }

    return completer.future;
  }

  Future<PixabayResponse> requestMediaWithKeyword(
      {MediaType media,
      String keyword,
      int resultsPerPage = 30,
      int page,
      String category}) async {
    // Search for media associated with the keyword
    String url = "https://pixabay.com/api/";
    PixabayResponse res;

    if (media == MediaType.video) url += "videos/";

    if (resultsPerPage < 3) // API restriction
      resultsPerPage = 3;

    url += "?key=" + apiKey;

    if (keyword != null) url += "&q=" + Uri.encodeFull(keyword);

    url +=
        "&lang=" + Uri.encodeFull(this.language) + "&per_page=$resultsPerPage";

    if (category != null) url += "&category=$category";
    if (page != null) url += "&page=$page";

    if (media == MediaType.video) {
      var data = await getVideos(url);

      if (data != null && data.length > 0) {
        List<PixabayVideo> videos =
            new List<PixabayVideo>.generate(data['hits'].length, (index) {
          return new PixabayVideo.fromJson(data['hits'][index]);
        });

        res = PixabayResponse(
            total: data["total"], totalHits: data["totalHits"], hits: videos);
      }
    } else {
      var data = await getImages(url);

      if (data != null && data.length > 0) {
        List<PixabayImage> images =
            new List<PixabayImage>.generate(data['hits'].length, (index) {
          return new PixabayImage.fromJson(data['hits'][index]);
        });

        res = PixabayResponse(
            total: data["total"], totalHits: data["totalHits"], hits: images);
      }
    }
    return res;
  }
}
