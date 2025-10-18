import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('pt', 'BR');

  Locale get currentLocale => _currentLocale;

  void setLanguage(Locale locale) {
    _currentLocale = locale;
    notifyListeners();
  }

  String get languageCode => _currentLocale.languageCode;

  String get countryCode => _currentLocale.countryCode ?? '';

  String get fullLocale => '${_currentLocale.languageCode}_${_currentLocale.countryCode}';

  bool get isPortuguese => _currentLocale.languageCode == 'pt';
  bool get isEnglish => _currentLocale.languageCode == 'en';
  bool get isSpanish => _currentLocale.languageCode == 'es';
}
