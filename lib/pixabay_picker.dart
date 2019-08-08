library pixabay_picker;

import 'package:pixabay_picker/pixabay_api.dart';

class PixabayPicker {
  PixabayMediaProvider api;

  PixabayPicker({String apiKey, String language}) {
    api = PixabayMediaProvider(apiKey: apiKey, language: language);
  }
}
