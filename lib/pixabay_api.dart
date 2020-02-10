/*
 * Copyright (c) 2019. Black Salt Kft.  All rights reserved.
 * Author: Albert Papp
 *
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:pixabay_picker/model/pixabay_media.dart';

/// Class to access pixabay.com http API
class PixabayMediaProvider {
  final String apiKey;
  String language;
  StreamController progressStreamController;
  StreamSubscription<List<int>> _downloadStreamSub;

  PixabayMediaProvider({this.apiKey, String language}) {
    this.language = language ?? 'en';

    progressStreamController = StreamController.broadcast(
        onCancel: () {
          _downloadStreamSub?.cancel();
        });
  }

  /// request random images by category
  Future<PixabayResponse> requestImages(
      {int resultsPerPage = 30, int page, String category}) async {
    return requestMediaWithKeyword(
        media: MediaType.photo,
        resultsPerPage: resultsPerPage,
        page: page,
        category: category);
  }

  /// request random media (images and/or videos) for a list of categories
  Stream<Map<String, Map<MediaType, PixabayResponse>>> requestMapByCategory(
      {int photoResultsPerCategory,
      int videoResultsPerCategory,
      List<String> categories}) async* {
    for (int i = 0; i < Category.categories.length; i++) {
      PixabayResponse resVideo;
      PixabayResponse resImage;

      if (categories == null ||
          categories.indexOf(Category.categories[i]) >= 0) {
        String category = Category.categories[i];

        if (photoResultsPerCategory != null)
          resImage = await requestImages(
              resultsPerPage: photoResultsPerCategory, category: category);

        if (photoResultsPerCategory != null)
          resVideo = await requestVideos(
              resultsPerPage: videoResultsPerCategory, category: category);

        yield Map.from({
          category: {MediaType.photo: resImage, MediaType.video: resVideo}
        });
      }
    }
  }

  /// pageing is prepared but not used yet
  /// request images for a given keyword or
  /// search term
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

  /// request random videos
  Future<PixabayResponse> requestVideos(
      {int resultsPerPage = 30, int page, String category}) async {
    return requestMediaWithKeyword(
        media: MediaType.video,
        resultsPerPage: resultsPerPage,
        page: page,
        category: category);
  }

  /// pageing is prepared but not used yet
  /// request videos for a given keyword or
  /// search term
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
    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    // Process the response.
    if (response.statusCode == 200) {
      // response: OK
      // decode JSON
      String json = await utf8.decoder.bind(response).join();
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
    HttpClient httpClient = HttpClient();
    HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
    HttpClientResponse response = await request.close();
    // Process the response.
    if (response.statusCode == 200) {
      // response: OK
      // decode JSON
      String json = await utf8.decoder.bind(response).join();
      var data = jsonDecode(json);
      return data;
    } else {
      // something went wrong :(
      print("Http error: ${response.statusCode}");
      return [];
    }
  }

  /// Common function to download media
  /// pixabay.com does not prefer hotlinking
  Future<BytesBuilder> downloadMedia(PixabayMedia media, String res,
      [Function callback]) async {
    var completer = Completer<BytesBuilder>();

    HttpClient httpClient = HttpClient();
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

      var contents = BytesBuilder();

      _downloadStreamSub = response.listen((List<int> data) {
        downloaded += data.length;
        contents.add(data);
        // handle data
        double progress = downloaded / fileSize;

        if (callback != null) callback(progress);
        progressStreamController.add(progress);
      }, onDone: () {
        _downloadStreamSub = null;
        progressStreamController = StreamController.broadcast(
            onCancel: () {
              _downloadStreamSub?.cancel();
            });
        completer.complete(contents);
      });
    } else {
      // something went wrong :(
      completer.completeError("Http error: ${response.statusCode}");
      print("Http error: ${response.statusCode}");
    }

    return completer.future;
  }

  /// main request method for all kind of media
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
            List<PixabayVideo>.generate(data['hits'].length, (index) {
          return PixabayVideo.fromJson(data['hits'][index]);
        });

        res = PixabayResponse(
            total: data["total"], totalHits: data["totalHits"], hits: videos);
      }
    } else {
      var data = await getImages(url);

      if (data != null && data.length > 0) {
        List<PixabayImage> images =
            List<PixabayImage>.generate(data['hits'].length, (index) {
          return PixabayImage.fromJson(data['hits'][index]);
        });

        res = PixabayResponse(
            total: data["total"], totalHits: data["totalHits"], hits: images);
      }
    }
    return res;
  }
}
