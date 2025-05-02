import 'package:special_characters/model/theme.dart';

class ThemePresenter {
  final ThemeModel _themeModel;

  ThemePresenter(this._themeModel);

  bool get isDarkMode => _themeModel.isDarkMode;

  void toggleDarkMode(bool value) {
    _themeModel.toggleDarkMode(value);
  }
}
