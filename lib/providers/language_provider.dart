import 'package:flutter/material.dart';

class LanguageProvider with ChangeNotifier {
  Locale? _currentLocale = const Locale('pt', 'BR');

  Locale? get currentLocale => _currentLocale;

  void setLanguage(Locale? locale) {
    _currentLocale = locale;
    notifyListeners();
  }

  String get languageCode => _currentLocale?.languageCode ?? 'pt';

  String get countryCode => _currentLocale?.countryCode ?? 'BR';

  String get fullLocale =>
      '${_currentLocale?.languageCode ?? 'pt'}_${_currentLocale?.countryCode ?? 'BR'}';

  bool get isPortuguese => (_currentLocale?.languageCode ?? 'pt') == 'pt';
  bool get isEnglish => (_currentLocale?.languageCode ?? 'pt') == 'en';
  bool get isSpanish => (_currentLocale?.languageCode ?? 'pt') == 'es';
}
