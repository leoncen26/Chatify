import 'package:flutter/material.dart';

class ThemeProvider  with ChangeNotifier{
  ThemeMode themeMode = ThemeMode.system;

  ThemeMode get theme => themeMode;

  bool get isDark => themeMode == ThemeMode.dark;

  void toggleMode(bool isDarkMode){
    themeMode = isDarkMode ? ThemeMode.light: ThemeMode.dark ;
    notifyListeners();
  }
}