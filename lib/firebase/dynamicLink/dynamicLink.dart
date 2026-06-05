// ignore_for_file: use_build_context_synchronously


// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/configs/theme/theme_model.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FirebaseDynamicLink {
  FirebaseDynamicLink();

  /// Hard-coded deep link that mimics what Firebase Dynamic Links provided.
  /// Change the company value to whatever your app expects.
  static final Uri hardCodedDeepLink = Uri.parse(
    'https://example.page.link/?${Constants.CompanyPreference}=ZEMEN',
  );

  static Future getParametersAndStoreLocally(Uri deepLink, BuildContext context) async {
    try {
      debugPrint("------ Deep Link All Params: ${deepLink.queryParametersAll}");
      debugPrint("------ Deep Link Company Name: ${deepLink.queryParameters[Constants.CompanyPreference]}");
      String company = deepLink.queryParameters[Constants.CompanyPreference]!;

      // ✅ Remote Config still works exactly as before
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
      String remoteCompanyConfig_ = remoteConfig.getString(company);
      debugPrint("------  Deep Link Company Config Remote: $remoteCompanyConfig_");

      if (remoteCompanyConfig_.isNotEmpty) {
        Globals.prefs!.setString(Constants.CompanyConfig, remoteCompanyConfig_);

        Map<String, dynamic> companyThemeSetting = jsonDecode(remoteCompanyConfig_);

        String defaultLanguage = companyThemeSetting[Constants.CompanyDefaultLanguage];
        String companyPref = companyThemeSetting[Constants.CompanyPreference];
        String companyLogo = companyThemeSetting[Constants.CompanyLogo];
        String defaultTheme = companyThemeSetting[Constants.CompanyDefaultTheme];
        String monthImages = jsonEncode(companyThemeSetting[Constants.MonthImages]);

        Globals.prefs!.setString(Constants.CompanyPreference, companyPref);
        Globals.prefs!.setString(Constants.CompanyLogo, companyLogo);
        Globals.prefs!.setString(Constants.ThemePreference, defaultTheme);
        Globals.prefs!.setString(Constants.LanguagePreference, defaultLanguage);

        Globals.prefs!.setString(Constants.CompanyDefaultLanguage, defaultLanguage);
        Globals.prefs!.setString(Constants.CompanyDefaultTheme, defaultTheme);
        Globals.prefs!.setString(Constants.MonthImages, monthImages);

        try {
          String numberFormat = companyThemeSetting[Constants.NumberFormat];
          Globals.prefs!.setString(Constants.NumberFormat, numberFormat);
        } catch (e) {
          debugPrint(e.toString());
          Globals.prefs!.setString(Constants.NumberFormat, "ግዕዝ");
        }

        debugPrint("------ Deep Link Company Default Language:  ($defaultLanguage) THEME($defaultTheme)");
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();

        Globals.initCompanySettingIfAny();
        Globals.prefs!.remove(Constants.ServiceProviderTermsAndPoliciesVersion);
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Entry point: now just calls the hard-coded deep link.
  static Future<String> configureAppFromDynamicLinkV2(BuildContext context) async {
    // Skip FirebaseDynamicLinks entirely; go straight to our Uri
    await configureCompany(hardCodedDeepLink, context);
    Globals.prefs!.setString(Constants.IsBackgroundDynamicLink, "yes");
    return "Done";
  }

  static Future<void> configureCompany(Uri deepLink, BuildContext context) async {
    String? cloudFollowingCompany = Globals.prefs!.getString(Constants.CompanyUserFollowing);
    String? localCompany = Globals.prefs!.getString(Constants.CompanyPreference);

    String companyFromLink = deepLink.queryParameters[Constants.CompanyPreference]!;

    if ((cloudFollowingCompany == null && localCompany == null) ||
        (cloudFollowingCompany == Constants.DefaultCompany)) {
                  debugPrint("------ HERE 1 $cloudFollowingCompany");
      Globals.prefs!.setString(Constants.CompanyPreference, companyFromLink);
      await getParametersAndStoreLocally(deepLink, context);
    } else {
              debugPrint("------ HERE 2 $companyFromLink");
      Globals.prefs!.setString(Constants.DynamicLinkCompany, companyFromLink);
    }
  }
}

// import 'dart:convert';

// import 'package:event_calendar_v2/common/constants.dart';
// import 'package:event_calendar_v2/common/globals.dart';
// import 'package:event_calendar_v2/configs/theme/theme_model.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// /// Handles company configuration without Firebase Dynamic Links.
// class FirebaseDynamicLink {
//   FirebaseDynamicLink();

//   /// Fetch and store all parameters for the hardcoded company.
//   static Future<void> getParametersAndStoreLocally(
//     BuildContext context,
//   ) async {
//     const String hardcodedCompany = "MyHardcodedCompany"; // <-- change to yours

//     try {
//       final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
//       String remoteCompanyConfig = remoteConfig.getString(hardcodedCompany);
//       debugPrint("------ Company Config Remote: $remoteCompanyConfig");

//       if (remoteCompanyConfig.isNotEmpty) {
//         Globals.prefs!.setString(Constants.CompanyConfig, remoteCompanyConfig);

//         String? localCompanyConfig = Globals.prefs!.getString(Constants.CompanyConfig);
//         debugPrint("------ COMPANY CONFIG LOCAL $localCompanyConfig");

//         Map<String, dynamic> companyThemeSetting =
//             jsonDecode(remoteCompanyConfig);

//         String defaultLanguage =
//             companyThemeSetting[Constants.CompanyDefaultLanguage];
//         String company = companyThemeSetting[Constants.CompanyPreference];
//         String companyLogo = companyThemeSetting[Constants.CompanyLogo];
//         String defaultTheme = companyThemeSetting[Constants.CompanyDefaultTheme];
//         String monthImages =
//             jsonEncode(companyThemeSetting[Constants.MonthImages]);

//         Globals.prefs!.setString(Constants.CompanyPreference, company);
//         Globals.prefs!.setString(Constants.CompanyLogo, companyLogo);
//         Globals.prefs!.setString(Constants.ThemePreference, defaultTheme);
//         Globals.prefs!.setString(Constants.LanguagePreference, defaultLanguage);

//         Globals.prefs!.setString(Constants.CompanyDefaultLanguage, defaultLanguage);
//         Globals.prefs!.setString(Constants.CompanyDefaultTheme, defaultTheme);
//         Globals.prefs!.setString(Constants.MonthImages, monthImages);

//         try {
//           /// SETTING IS ADDED AFTER FIRST RELEASE & MUST SKIP UNEXPECTED ERRORS
//           String numberFormat = companyThemeSetting[Constants.NumberFormat];
//           Globals.prefs!.setString(Constants.NumberFormat, numberFormat);
//         } catch (e) {
//           debugPrint(e.toString());
//           Globals.prefs!.setString(Constants.NumberFormat, "ግዕዝ");
//         }

//         debugPrint(
//           "------ Company Default Language: ($defaultLanguage) THEME($defaultTheme)",
//         );
//         Provider.of<ThemeProvider>(context, listen: false).toggleTheme();

//         // Localize.initMenuWithSelectedLanguage(); // uncomment if still needed
//         Globals.initCompanySettingIfAny();

//         Globals.prefs!.remove(
//           Constants.ServiceProviderTermsAndPoliciesVersion,
//         );
//       }
//     } on Exception catch (e) {
//       debugPrint(e.toString());
//     }
//   }

//   /// Configure the app for the hardcoded company.
//   static Future<String> configureAppCompany(BuildContext context) async {
//     // Fetch the latest remote config first if needed
//     // await FirebaseRemoteConfigV2.fetchRemoteConfig(); // uncomment if you have a custom wrapper

//     const String hardcodedCompany = "MyHardcodedCompany"; // <-- change to yours
//     debugPrint("------ Configuring hardcoded company: $hardcodedCompany");

//     await configureCompany(context, hardcodedCompany);
//     return "Done";
//   }

//   /// Store company information and run first-time setup if required.
//   static Future<void> configureCompany(
//     BuildContext context,
//     String company,
//   ) async {
//     String? cloudFollowingCompany =
//         Globals.prefs!.getString(Constants.CompanyUserFollowing);
//     String? localCompany =
//         Globals.prefs!.getString(Constants.CompanyPreference);

//     if ((cloudFollowingCompany == null && localCompany == null) ||
//         (cloudFollowingCompany == Constants.DefaultCompany)) {
//       // First-time or default: set hardcoded company and load its parameters
//       Globals.prefs!.setString(Constants.CompanyPreference, company);
//       await getParametersAndStoreLocally(context);
//     } else {
//       // Already following a company: just record the hardcoded one if desired
//       Globals.prefs!.setString(Constants.DynamicLinkCompany, company);
//     }
//   }
// }


// // ignore_for_file: use_build_context_synchronously

// import 'dart:convert';

// import 'package:event_calendar_v2/common/constants.dart';
// import 'package:event_calendar_v2/common/globals.dart';
// import 'package:event_calendar_v2/configs/theme/theme_model.dart';
// // import 'package:event_calendar_v2/firebase/remoteConfig/firebase_remote_config.dart';
// // import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class FirebaseDynamicLink {
//   FirebaseDynamicLink();

//   static Future getParametersAndStoreLocally(Uri deepLink, BuildContext context) async {
//     try {
//       debugPrint("------ Deep Link All Params: ${deepLink.queryParametersAll}");
//       debugPrint("------ Deep Link Company Name: ${deepLink.queryParameters[Constants.CompanyPreference]}");
//       String company = deepLink.queryParameters[Constants.CompanyPreference]!;

//       // FirebaseRemoteConfig frc = FirebaseRemoteConfig();
//       // String _remoteCompanyConfig = await frc.getRemoteConfig(company);
//       final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
//       String remoteCompanyConfig_ = remoteConfig.getString(company);
//       debugPrint("------  Deep Link Company Config Remote: $remoteCompanyConfig_");

//       if (remoteCompanyConfig_.isNotEmpty) {
//         Globals.prefs!.setString(Constants.CompanyConfig, remoteCompanyConfig_);

//         String? localCompanyConfig = Globals.prefs!.getString(Constants.CompanyConfig);
//         debugPrint("------ DEEP LINK COMPANY CONFIG LOCAL $localCompanyConfig");

//         Map<String, dynamic> companyThemeSetting = jsonDecode(remoteCompanyConfig_);

//         String defaultLanguage = companyThemeSetting[Constants.CompanyDefaultLanguage];
//         String company = companyThemeSetting[Constants.CompanyPreference];
//         String companyLogo = companyThemeSetting[Constants.CompanyLogo];
//         String defaultTheme = companyThemeSetting[Constants.CompanyDefaultTheme];
//         String monthImages = jsonEncode(companyThemeSetting[Constants.MonthImages]);

//         Globals.prefs!.setString(Constants.CompanyPreference, company);
//         Globals.prefs!.setString(Constants.CompanyLogo, companyLogo);
//         Globals.prefs!.setString(Constants.ThemePreference, defaultTheme);
//         Globals.prefs!.setString(Constants.LanguagePreference, defaultLanguage);

//         Globals.prefs!.setString(Constants.CompanyDefaultLanguage, defaultLanguage);
//         Globals.prefs!.setString(Constants.CompanyDefaultTheme, defaultTheme);
//         Globals.prefs!.setString(Constants.MonthImages, monthImages);

//         try {
//           ///SETTING IS ADDED AFTER FIRST RELEASE & MUST SKIP UNEXPECTED ERRORS
//           String numberFormat = companyThemeSetting[Constants.NumberFormat];
//           Globals.prefs!.setString(Constants.NumberFormat, numberFormat);
//         } catch (e) {
//           debugPrint(e.toString());
//           Globals.prefs!.setString(Constants.NumberFormat, "ግዕዝ");
//         }

//         debugPrint("------ Deep Link Company Default Language:  ($defaultLanguage) THEME($defaultTheme)");
//         Provider.of<ThemeProvider>(context, listen: false).toggleTheme();

//         ///TODO: Commented
//         // Localize.initMenuWithSelectedLanguage();
//         Globals.initCompanySettingIfAny();

//         Globals.prefs!.remove(Constants.ServiceProviderTermsAndPoliciesVersion);
//       }
//     } on Exception catch (e) {
//       debugPrint(e.toString());
//     }
//   }

//   static Future<String> configureAppFromDynamicLinkV2(BuildContext context) async {
//   //   await FirebaseRemoteConfigV2.fetchRemoteConfig();
//   //   final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

//   //   if (initialLink != null) {
//   //     final Uri deepLink = initialLink.link;
//   //     String companyFromLink = deepLink.queryParameters[Constants.CompanyPreference]!;
//   //     debugPrint("------ $companyFromLink");
//   //     await configureCompany(deepLink, context);
//   //     Globals.prefs!.setString(Constants.IsBackgroundDynamicLink, "yes");
//   //   }

//   //   FirebaseDynamicLinks.instance.onLink.listen(
//   //     (pendingDynamicLinkData) async {
//   //       if (pendingDynamicLinkData != null) {
//   //         final Uri deepLink = pendingDynamicLinkData.link;
//   //         String companyFromLink = deepLink.queryParameters[Constants.CompanyPreference]!;
//   //         debugPrint("------ Company From Deep Link $companyFromLink");
//   //         await configureCompany(deepLink, context);
//   //         Globals.prefs!.setString(Constants.IsBackgroundDynamicLink, "yes");
//   //       }
//   //     },
//   //   );
//     return "Done";
//   }

//   // static Future<void> configureCompany(Uri deepLink, BuildContext context) async {
//   //   String? cloudFollowingCompany = Globals.prefs!.getString(Constants.CompanyUserFollowing);
//   //   String? localCompany = Globals.prefs!.getString(Constants.CompanyPreference);

//   //   String companyFromLink = deepLink.queryParameters[Constants.CompanyPreference]!;

//   //   ///User did not install the app and app is configuring for the first time
//   //   ///On app restart and sync, the app COUNTED under the company from the link and not the DEFAULT
//   //   if ((cloudFollowingCompany == null && localCompany == null) ||
//   //       (cloudFollowingCompany == Constants.DefaultCompany)) {
//   //     ///Its possible to switch from null/default to a subscribed company
//   //     Globals.prefs!.setString(Constants.CompanyPreference, companyFromLink);

//   //     ///Store the company setting because it is NEW
//   //     await getParametersAndStoreLocally(deepLink, context);
//   //   } else {
//   //     ///Other logics implementation
//   //     ///Check company subscription mode and act accordingly (Trial, Basic, Standard Premium)
//   //     ///Define all business logics to switch fairly between subscription modes
//   //     ///For the time being, no need to switch between companies

//   //     ///Store the attempting company link and use it later with step by step user to switch
//   //     ///the company they installed. Once switch remove this link and wait for another link click
//   //     ///Everytime the app opens, it can check the availability of new link and apply logic on it
//   //     Globals.prefs!.setString(Constants.DynamicLinkCompany, companyFromLink);
//   //   }
//   //   // await getParametersAndStoreLocally(deepLink, context);
//   // }

// }
