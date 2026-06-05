import 'dart:convert';

import 'package:event_calendar_v2/common/config/company_config_model.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

class ApplicationConfigs {
  static Future<ThemeData> getPreferenceTheme(String themeType) async {
    /// TODO: If the try - catch is not enough for error prevention, then
    ///Make sure companyConfig is initialized correctly and do not raise null or empty exception
    // final RemoteConfig remoteConfig = RemoteConfig.instance;
    String? companyConfig = Globals.prefs!.getString(Constants.CompanyConfig);

    ThemeData lightTheme, darkTheme;
    Color? primaryColorLight;
    Color? accentColorLight;
    Color? primaryColorDark;
    Color? accentColorDark;
    try {
      Map<String, dynamic> companyThemeSetting = jsonDecode(companyConfig!);
      debugPrint("------ APPLICATION THEMES GET PREFERENCE");
      debugPrint(companyThemeSetting.toString());
      primaryColorLight = Utility.colorConvert(companyThemeSetting["primaryColorLight"]);
      accentColorLight = Utility.colorConvert(companyThemeSetting["accentColorLight"]);
      primaryColorDark = Utility.colorConvert(companyThemeSetting["primaryColorDark"]);
      accentColorDark = Utility.colorConvert(companyThemeSetting["accentColorDark"]);

      ///Separate the logic of application configuration from theme configuration for more read & maintainability
      await setCompanyConfigToGlobals(companyThemeSetting);
    } catch (ex) {
      ///TODO: Define better and professional look Light and Dark default themes
      CompanyConfig config = CompanyConfig(expirationDate: DateTime(2025));
      primaryColorLight = Utility.colorConvert(config.primaryColorLight!);
      accentColorLight = Utility.colorConvert(config.accentColorLight!);
      primaryColorDark = Utility.colorConvert(config.primaryColorDark!);
      accentColorDark = Utility.colorConvert(config.accentColorDark!);
    }

    darkTheme = ThemeData.dark().copyWith(
      primaryColor: primaryColorDark,
      colorScheme: ColorScheme.dark(secondary: accentColorDark!, primary: primaryColorDark!),
      appBarTheme: AppBarTheme(backgroundColor: primaryColorDark),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColorDark,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.elliptical(7, 7))),
        textTheme: ButtonTextTheme.accent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: accentColorDark,
        unselectedItemColor: primaryColorDark,
      ),
    );

    lightTheme = ThemeData.light().copyWith(
      primaryColor: primaryColorLight,
      colorScheme: ColorScheme.light(secondary: accentColorLight!),
      appBarTheme: AppBarTheme(backgroundColor: primaryColorLight),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColorLight,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.elliptical(7, 7))),
        textTheme: ButtonTextTheme.accent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: accentColorLight,
        unselectedItemColor: primaryColorLight,
      ),
    );

    debugPrint("------ Theme Type:  $themeType");
    if (themeType == 'Light') {
      return lightTheme;
    } else {
      return darkTheme;
    }
  }

  static Future<ThemeData> getPreferenceThemeV2() async {
    CompanyConfig config = CompanyConfig(expirationDate: DateTime(2023));

    ///TODO: If the try - catch is not enough for error prevention, then
    /// Make sure companyConfig is initialized correctly and do not raise null or empty exception

    // String companyConfig = Globals.prefs.getString(Constants.CompanyConfig);
    ThemeData lightTheme, darkTheme;
    Color? primaryColorLight;
    Color? accentColorLight;
    Color? primaryColorDark;
    Color? accentColorDark;
    try {
      debugPrint("------ APPLICATION THEMES GET PREFERENCE");
      primaryColorLight = Utility.colorConvert(config.primaryColorLight!);
      accentColorLight = Utility.colorConvert(config.primaryColorLight!);
      primaryColorDark = Utility.colorConvert(config.primaryColorLight!);
      accentColorDark = Utility.colorConvert(config.primaryColorLight!);

      ///Separate the logic of application configuration from theme configuration for more read & maintainability
      // await setCompanyConfigToGlobals(_companyThemeSetting);
    } catch (ex) {
      ///TODO: Define better and professional look Light and Dark default themes
      // _primaryColorLight = Colors.cyan;
      // _accentColorLight = Colors.cyanAccent;
      // _primaryColorDark = Colors.purple;
      // _accentColorDark = Colors.purpleAccent;
    }

    darkTheme = ThemeData.dark().copyWith(
      primaryColor: primaryColorDark,
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColorDark,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.elliptical(7, 7))),
        textTheme: ButtonTextTheme.accent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: accentColorDark,
        unselectedItemColor: primaryColorDark,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accentColorDark),
    );

    lightTheme = ThemeData.light().copyWith(
      primaryColor: primaryColorLight,
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColorLight,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.elliptical(7, 7))),
        textTheme: ButtonTextTheme.accent,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: accentColorLight,
        unselectedItemColor: primaryColorLight,
      ),
      colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accentColorLight),
    );

    debugPrint("------ Theme Type:  ${config.defaultTheme}");
    if (config.defaultTheme == 'Light') {
      return lightTheme;
    } else {
      return darkTheme;
    }
  }

  static Future<void> setCompanyConfigToGlobals(Map<String, dynamic> companyThemeSetting) async {
    String? companyLogo;
    try {
      debugPrint("------ APPLICATION CONFIGURATION GLOBAL ACCESS SETUP ++++++++++");
      debugPrint(companyThemeSetting.toString());
      companyLogo = companyThemeSetting[Constants.CompanyLogo];
    } catch (ex) {
      ///TODO: Define better and professional look Light and Dark default themes
      companyLogo = null;
    }

    Globals.prefs!.setString(Constants.CompanyLogo, companyLogo!);
  }
}
