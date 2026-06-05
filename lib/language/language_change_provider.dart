import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:flutter/material.dart';

class LanguageChangeProvider with ChangeNotifier {
  Locale _currentLocal = const Locale("am");

  Locale get currentLocal => _currentLocal;
  changeLocal(String localCode) {
    _currentLocal = Locale(localCode);
    notifyListeners();
  }

  String getCurrentLocaleCode() {
    String? languagePref = Globals.prefs!.getString(Constants.LanguagePreference);
    languagePref ??= 'አማርኛ';
    String languageCode;
    switch (languagePref) {
      case "Oromiffa":
        languageCode = "or";
        break;

      case "ትግርኛ":
        languageCode = "te";
        break;

      case "English":
        languageCode = "en";
        break;
      default:
        {
          languageCode = "am";
        }
    }
    return languageCode;
  }

  Locale getCurrentLocale() {
    String languageCode = getCurrentLocaleCode();
    return Locale(languageCode);
  }
}
