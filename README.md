# pixabay_picker

A new Flutter/Dart package project.

## Getting Started

We have provided a pure dart API for getting media from pixabay.com.

Later on we will enhance this project with a Flutter Media picker too.

## Usage:

### Create API interface

Note that you can search pixabay localized, if you set the language parameter accordingly in constructor.
Safe search is default true. You can change this value in the constructor.

```
  PixabayPicker picker = PixabayPicker(apiKey: ApiKey, language: "hu", safeSearch: true);
```

### Get images for business category
```
  PixabayResponse res = await picker.api
      .requestImages(resultsPerPage: 4, category: Category.business);   
```

You can iterate the result like this

```
  res.hits.forEach((f) {
      // use your media
      print(f);
    });
```

### Get Images with keywords

```
// get 30 image tagged as dog from pixabay
// note we created the api object with hungarian
// language so the keyword is in hungarian too

res =
      await api.requestImagesWithKeyword(keyword: "kutya", resultsPerPage: 30);

```

### Search other media
You can search for videos too
```
 res =
      await api.requestVideosWithKeyword(keyword: "kutya", resultsPerPage: 30);

```

### Download media

```
  BytesBuilder bytes =
        await api.downloadMedia(res.hits[0], Resolution.medium);

```

### Get 3 video and 3 image for each category 

```
  Stream<Map<String, Map<MediaType, PixabayResponse>>> result =
      api.requestMapByCategory(
          photoResultsPerCategory: 3, videoResultsPerCategory: 3);

  result.listen((Map<String, Map<MediaType, PixabayResponse>> onData) {
    var values = onData.values.toList();
    var keys = onData.keys.toList();

    print(keys[0] + ":" + values[0][MediaType.video].hits[0].toString());
    print(keys[0] + ":" + values[0][MediaType.photo].hits[0].toString());
  });

  ```