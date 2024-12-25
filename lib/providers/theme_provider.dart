import 'package:flutter/cupertino.dart';
import '../models/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  AppTheme _theme = AppTheme.light;

  AppTheme get theme => _theme;

  void setTheme(AppTheme newTheme) {
    _theme = newTheme;
    notifyListeners();
  }
} 