/*
 * Copyright (c) 2019. Black Salt Kft.  All rights reserved.
 * Author: Albert Papp
 *
 */

enum MediaType { photo, video }

enum Resolution { large, medium, small }

class PixabayResponse {
  int totalHits;
  int total;

  List<PixabayMedia> hits;

  PixabayResponse({this.total, this.totalHits, this.hits});
}

abstract class PixabayMedia {
  int id;
  int userId;
  int views;
  int comments;
  int likes;
  int favorites;
  int downloads;
  String tags;
  String user;
  String type;

  PixabayMedia(
      {this.id,
      this.userId,
      this.views,
      this.comments,
      this.likes,
      this.favorites,
      this.downloads,
      this.tags,
      this.user,
      this.type});
  MediaType getType();

  String getDownloadLink(Resolution res);

  @override
  String toString() {
    return (this.getDownloadLink(Resolution.medium) ?? "null") +
        " by " +
        this.user +
        " tags: " +
        this.tags;
  }
}

// Model for Unsplash Image

class PixabayImage extends PixabayMedia {
  String largeImageURL;
  String fullHDURL;
  String webformatURL;
  String previewURL;
  String userImageURL;
  String pageURL;
  int webformatHeight;
  int webformatWidth;
  int imageWidth;
  int imageHeight;
  int previewHeight;
  int imageSize;
  int previewWidth;

  PixabayImage({
    String tags,
    String type,
    String user,
    int downloads,
    int likes,
    int id,
    int userId,
    int views,
    int comments,
    int favorites,
    this.largeImageURL,
    this.fullHDURL,
    this.webformatHeight,
    this.webformatWidth,
    this.imageWidth,
    this.pageURL,
    this.imageHeight,
    this.webformatURL,
    this.previewHeight,
    this.imageSize,
    this.previewWidth,
    this.userImageURL,
    this.previewURL,
  }) : super(
            user: user,
            downloads: downloads,
            favorites: favorites,
            comments: comments,
            id: id,
            userId: userId,
            views: views,
            likes: likes,
            tags: tags,
            type: type);

  factory PixabayImage.fromJson(Map<String, dynamic> data) {
    return new PixabayImage(
      largeImageURL: data['largeImageURL'],
      fullHDURL: data['fullHDURL'],
      webformatHeight: data['webformatHeight'],
      webformatWidth: data['webformatWidth'],
      likes: data['likes'],
      imageWidth: data['imageWidth'],
      type: data['type'],
      id: data['id'],
      userId: data['user_id'],
      views: data['views'],
      comments: data['comments'],
      pageURL: data['pageURL'],
      imageHeight: data['imageHeight'],
      webformatURL: data['webformatURL'],
      previewHeight: data['previewHeight'],
      tags: data['tags'],
      downloads: data['downloads'],
      user: data['user'],
      favorites: data['favorites'],
      imageSize: data['imageSize'],
      previewWidth: data['previewWidth'],
      userImageURL: data['userImageURL'],
      previewURL: data['previewURL'],
    );
  }

  String getDownloadLink(Resolution res) {
    switch (res) {
      case Resolution.large:
        return this.fullHDURL;
      case Resolution.medium:
        return this.largeImageURL;
      case Resolution.small:
        return this.webformatURL;
    }

    return this.fullHDURL ?? this.largeImageURL ?? this.webformatURL;
  }

  @override
  MediaType getType() {
    return MediaType.photo;
  }
}

class PixabayVideoDescriptor {
  String url;
  int width;
  int height;
  int size;
  Resolution res;

  PixabayVideoDescriptor(
      {this.url, this.width, this.height, this.size, this.res});
}

class PixabayVideo extends PixabayMedia {
  int id;
  String pageURL;
  String type;
  String tags;
  int duration;
  String pictureId;
  List<PixabayVideoDescriptor> videos;
  int views;
  int downloads;
  int favorites;
  int likes;
  int comments;
  int userId;
  String user;
  String userImageURL;

  PixabayVideo({
    String tags,
    String type,
    String user,
    int downloads,
    int likes,
    int id,
    int userId,
    int views,
    int comments,
    int favorites,
    this.pageURL,
    this.duration,
    this.pictureId,
    this.videos,
    this.userImageURL,
  }) : super(
            user: user,
            downloads: downloads,
            favorites: favorites,
            comments: comments,
            id: id,
            userId: userId,
            views: views,
            likes: likes,
            tags: tags,
            type: type);

  factory PixabayVideo.fromJson(Map<String, dynamic> data) {
    List<PixabayVideoDescriptor> videos =
        new List<PixabayVideoDescriptor>.generate(data['videos'].length,
            (index) {
      return new PixabayVideoDescriptor(
          url: data['videos'][index]['url'],
          height: data['videos'][index]['height'],
          width: data['videos'][index]['width'],
          size: data['videos'][index]['size']);
    });

    return new PixabayVideo(
      id: data['id'],
      pageURL: data['pageURL'],
      type: data["type"],
      tags: data["tags"],
      duration: data["duration"],
      pictureId: data["picture_id"],
      videos: videos,
      views: data["views"],
      downloads: data["downloads"],
      favorites: data["favorites"],
      likes: data["likes"],
      comments: data["comments"],
      userId: data["user_id"],
      user: data["user"],
      userImageURL: data["userImageURL"],
    );
  }

  String getDownloadLink(Resolution res) {
    videos.forEach((f) {
      if (f.res == res) return f.url;
    });

    return null;
  }

  @override
  MediaType getType() {
    return MediaType.video;
  }
}
