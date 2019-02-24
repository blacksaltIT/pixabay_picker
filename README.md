# pixabay_picker

A new Flutter/Dart package project.

## Getting Started

We have provided a pure dart API for getting media from pixabay.com.

Later on we will enhance this project with a Flutter Media picker too.

## Usage:

```void main() async {
  PixabayPicker picker = PixabayPicker(apiKey: ApiKey, language: "hu");

  PixabayResponse res = await picker.api
      .requestImages(resultsPerPage: 1, category: Category.business);
      
```
