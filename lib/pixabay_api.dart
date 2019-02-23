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

  Future<PixabayResponse> requestImages([int resultsPerPage = 30]) async {
    String url = "https://pixabay.com/api/?key=" +
        apiKey +
        "&lang=" +
        Uri.encodeFull(this.language) +
        "&per_page=${resultsPerPage}";

    var data = await getImages(url);

    List<PixabayImage> images =
        new List<PixabayImage>.generate(data["hits"].length, (index) {
      return new PixabayImage.fromJson(data["hits"][index]);
    });

    PixabayResponse res = PixabayResponse(
        total: data["total"], totalHits: data["totalHits"], hits: images);

    return res;
  }

  // pageing is prepared but not used yet
  // we just return the first 30 image
  Future<PixabayResponse> requestImagesWithKeyword(
      {String keyword, int resultsPerPage}) async {
    // Search for image associated with the keyword
    String url = "https://pixabay.com/api/?key=" +
        apiKey +
        "&q=" +
        Uri.encodeFull(keyword) +
        "&lang=" +
        Uri.encodeFull(this.language) +
        "&per_page=${resultsPerPage}";

    var data = await getImages(url);
    List<PixabayImage> images =
        new List<PixabayImage>.generate(data['hits'].length, (index) {
      return new PixabayImage.fromJson(data['hits'][index]);
    });

    PixabayResponse res = PixabayResponse(
        total: data["total"], totalHits: data["totalHits"], hits: images);

    return res;
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

  Future<BytesBuilder> downloadMedia(PixabayMedia media, Resolution res,
      [Function callback]) async {
    var completer = new Completer<BytesBuilder>();

    HttpClient httpClient = new HttpClient();
    String downloadUrl = media.getDownloadLink(res);

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

  Future<PixabayResponse> requestVideos([int resultsPerPage = 20]) async {
    String url = "https://pixabay.com/api/?key=" +
        apiKey +
        "&lang=" +
        Uri.encodeFull(this.language) +
        "&per_page=${resultsPerPage}";

    var data = await getImages(url);

    List<PixabayImage> images =
        new List<PixabayImage>.generate(data["hits"].length, (index) {
      return new PixabayImage.fromJson(data["hits"][index]);
    });

    PixabayResponse res = PixabayResponse(
        total: data["total"], totalHits: data["totalHits"], hits: images);

    return res;
  }

  // pageing is prepared but not used yet
  // we just return the first 30 image
  Future<PixabayResponse> requestVideosWithKeyword(
      {String keyword, int resultsPerPage}) async {
    // Search for image associated with the keyword
    String url = "https://pixabay.com/api/?key=" +
        apiKey +
        "&q=" +
        Uri.encodeFull(keyword) +
        "&lang=" +
        Uri.encodeFull(this.language) +
        "&per_page=${resultsPerPage}";

    var data = await getImages(url);
    List<PixabayVideo> images =
        new List<PixabayVideo>.generate(data['hits'].length, (index) {
      return new PixabayVideo.fromJson(data['hits'][index]);
    });

    PixabayResponse res = PixabayResponse(
        total: data["total"], totalHits: data["totalHits"], hits: images);

    return res;
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
}
