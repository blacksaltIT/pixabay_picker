/*
 * Copyright (c) 2019. Black Salt Kft.  All rights reserved.
 * Author: Albert Papp
 *
 */

/// Currently only photo and video media type
/// is supported
enum MediaType { photo, video }

/// To download a media you can provide a resolution
/// large  - 1920 * 1080
/// medium - 1280 *  720
/// small  -  950 *  540
/// tiny   -  640 *  360
class Resolution {
  static String large = "large";
  static String medium = "medium";
  static String small = "small";
  static String tiny = "tiny";

  static List<String> resolutions = [large, medium, small, tiny];
}

/// Categories currently avaiable in pixabay.com
class Category {
  static String fashion = "fashion";
  static String nature = "nature";
  static String backgrounds = "backgrounds";
  static String science = "science";
  static String education = "education";
  static String people = "people";
  static String feelings = "feelings";
  static String religion = "religion";
  static String health = "health";
  static String places = "places";
  static String animals = "animals";
  static String industry = "industry";
  static String food = "food";
  static String computer = "computer";
  static String sports = "sports";
  static String transportation = "transportation";
  static String travel = "travel";
  static String buildings = "buildings";
  static String business = "business";
  static String music = "music";

  static List<String> categories = [
    fashion,
    nature,
    backgrounds,
    science,
    education,
    people,
    feelings,
    religion,
    health,
    places,
    animals,
    industry,
    food,
    computer,
    sports,
    transportation,
    travel,
    buildings,
    business,
    music
  ];
}

/// class to wrap pixabay.com response
class PixabayResponse {
  int totalHits;
  int total;

  List<PixabayMedia> hits;

  PixabayResponse({this.total, this.totalHits, this.hits});
}

/// base class for returned media
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

  String getDownloadLink({String res});
  String getThumbnailLink();

  @override
  String toString() {
    return (this.getDownloadLink(res: Resolution.medium) ?? "null") +
        " by " +
        this.user +
        " tags: " +
        this.tags;
  }
}

/// Model of Pixabay Image
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

  @override
  String getThumbnailLink() {
    // TODO: implement getThumbnailLink

    return getDownloadLink(res: Resolution.tiny);
  }

  @override
  String getDownloadLink({String res}) {
    if (res == Resolution.large)
      return this.fullHDURL;
    else if (res == Resolution.medium)
      return this.largeImageURL;
    else if (res == Resolution.small)
      return this.webformatURL;
    else if (res == Resolution.tiny) return this.webformatURL;

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
  String res;

  PixabayVideoDescriptor(
      {this.url, this.width, this.height, this.size, this.res});
}

/// Model of Pixabay Video
class PixabayVideo extends PixabayMedia {
  String pageURL;

  int duration;
  String pictureId;
  List<PixabayVideoDescriptor> videos;
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
    Map large = data['videos']["large"];
    Map medium = data['videos']["medium"];
    Map small = data['videos']["small"];

    List<PixabayVideoDescriptor> videos = [
      new PixabayVideoDescriptor(
          url: large['url'],
          height: large['height'],
          width: large['width'],
          size: large['size'],
          res: Resolution.large),
      new PixabayVideoDescriptor(
          url: medium['url'],
          height: medium['height'],
          width: medium['width'],
          size: medium['size'],
          res: Resolution.medium),
      new PixabayVideoDescriptor(
          url: small['url'],
          height: small['height'],
          width: small['width'],
          size: small['size'],
          res: Resolution.small)
    ];

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
  @override
  String getDownloadLink({String res}) {
    String url;

    videos.forEach((f) {
      if (f.res == res) {
        url = f.url;
        return;
      }
    });

    return url;
  }

  @override
  String getThumbnailLink() {
    // TODO: implement getThumbnailLink
    String cdnLink = "https://i.vimeocdn.com/video/";
    String cdnExtension = ".jpg";
    String res = "_640x360";

    return cdnLink + id.toString() + res + cdnExtension;
  }

  @override
  MediaType getType() {
    return MediaType.video;
  }
}
