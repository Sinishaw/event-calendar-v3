import 'dart:convert';

import 'package:event_calendar_v2/common/config/company_config_model.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';

class ApplicationConfigs {
  static ThemeData getPreferenceTheme(String themeType) {
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

      setCompanyConfigToGlobals(companyThemeSetting);
    } catch (ex) {
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

  static ThemeData getPreferenceThemeV2() {
    CompanyConfig config = CompanyConfig(expirationDate: DateTime(2023));

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
    } catch (ex) {
      // Ignored
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

  static void setCompanyConfigToGlobals(Map<String, dynamic> companyThemeSetting) {
    String? companyLogo;
    try {
      debugPrint("------ APPLICATION CONFIGURATION GLOBAL ACCESS SETUP ++++++++++");
      debugPrint(companyThemeSetting.toString());
      companyLogo = companyThemeSetting[Constants.CompanyLogo];
    } catch (ex) {
      companyLogo = null;
    }

    if (companyLogo != null) {
      Globals.prefs!.setString(Constants.CompanyLogo, companyLogo);
    }
  }
}
