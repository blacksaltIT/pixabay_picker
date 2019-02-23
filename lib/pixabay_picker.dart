library pixabay_picker;

import 'package:pixabay_picker/pixabay_api.dart';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

class PixabayPicker {
  PixabayImageProvider api;

  PixabayPicker({String apiKey, String language}) {
    api = PixabayImageProvider(apiKey: apiKey, language: language);
  }
}
