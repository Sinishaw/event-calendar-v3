import 'dart:convert';

import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/configs/company/application_configs.dart';
import 'package:event_calendar_v2/configs/theme/theme_initializer.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData? currentTheme;

  ThemeProvider() {
    String? currentThemeName = Globals.prefs?.getString(Constants.ThemePreference);
    currentThemeName ??= 'Dark';
    currentTheme = ApplicationConfigs.getPreferenceTheme(currentThemeName);
  }

  getAppTheme() async {
    String? currentThemeName = Globals.prefs!.getString(Constants.ThemePreference);

    if (currentThemeName == null) {
      Globals.prefs!.setString(Constants.ThemePreference, "Dark");
      currentThemeName = "Dark";
    }
    debugPrint("------ THEME MODEL GET APP THEME: $currentThemeName");
    currentTheme = ApplicationConfigs.getPreferenceTheme(currentThemeName);
    return notifyListeners();
  }

  getAppThemeV2() async {
    debugPrint("------ INIT THEME FROM LATEST OR DEFAULT REMOTE CONFIG...");
    currentTheme = ApplicationConfigs.getPreferenceThemeV2();
    return notifyListeners();
  }

  toggleTheme() async {
    await getAppTheme();
  }

  applySetting() {
    return notifyListeners();
  }

  static setLocalConfig(BuildContext context) async {
    String? company = Globals.prefs!.getString(Constants.CompanyPreference);
    if (company != null) {
      await setupRemoteConfigThemeNew(company);

      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
      String companyConfig = remoteConfig.getString(Constants.CompanyConfig);

      if (companyConfig.isNotEmpty) {
        Map<String, dynamic> remoteConfig = jsonDecode(companyConfig);
        String companyDefaultTheme = remoteConfig[Constants.CompanyDefaultTheme]?.toString() ?? 'Dark';
        Globals.prefs!.setString(Constants.ThemePreference, companyDefaultTheme);
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
      }
    }
  }
}
