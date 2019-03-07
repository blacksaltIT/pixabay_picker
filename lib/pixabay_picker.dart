library pixabay_picker;

import 'package:pixabay_picker/pixabay_api.dart';

class PixabayPicker {
  PixabayImageProvider api;

  PixabayPicker({String apiKey, String language}) {
    api = PixabayImageProvider(apiKey: apiKey, language: language);
  }
}
