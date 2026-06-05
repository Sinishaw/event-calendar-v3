import 'package:event_calendar_v2/common/config/company_config_model.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FirebaseRC {
  Future<String> getRemoteConfig(String name) async {
    debugPrint("------ Getting Remote Congig");
    final remoteConfig = FirebaseRemoteConfig.instance;
    try {
      String remoteConfigString = remoteConfig.getString(name);
      return remoteConfigString;
    } on PlatformException catch (exception) {
      debugPrint("------ FetchThrottledException: ${exception.toString()}");
      rethrow;
    } catch (exception) {
      debugPrint("------ Exception: ${exception.toString()}");
      rethrow;
    }
  }

  Future<void> setupRemoteConfigTheme(String company) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    //TODO: Return default theme below; Set defaults only related to theme;
    try {
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10), minimumFetchInterval: const Duration(minutes: 5)));

      await remoteConfig.setDefaults(
        <String, dynamic>{
          "company": "eLexicon",
          "primaryColorLight": "#23ccc8",
          "accentColorLight": "#a7d1d0",
          "primaryColorDark": "#5323cc",
          "accentColorDark": "#a18fcf",
        },
      );
      await remoteConfig.fetchAndActivate();
    } on PlatformException catch (exception) {
      debugPrint(exception.toString());
    } catch (exception) {
      remoteConfig.setDefaults(
        <String, dynamic>{
          "company": "eLexicon",
          "primaryColorLight": "#1f655d",
          "accentColorLight": "#1f655d",
          "primaryColorDark": "#0000ff",
          "accentColorDark": "#0000ff",
        },
      );
    }
    //TODO: Get Company Name from firestore database on app initialization
    String companyConfig = remoteConfig.getString(company);
    Globals.prefs!.setString("companyConfig", companyConfig);
  }
}

class FirebaseRemoteConfigV2 {
  String? version;
  DateTime? lastFetchTimeStamp;
  String? remoteConfig;

  static Future<void> fetchRemoteConfig() async {
    debugPrint("------ Fetching all config for the app ...");
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

    try {
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5), minimumFetchInterval: const Duration(minutes: 1)));
      await initDefaultParameters(remoteConfig);
      await remoteConfig.fetchAndActivate();
      if (remoteConfig.getString(Constants.CompaniesToFollow).isNotEmpty) {
        Globals.prefs!.setString(Constants.CompaniesToFollow, remoteConfig.getString(Constants.CompaniesToFollow));
        debugPrint("------ Companies to follow: ${remoteConfig.getString(Constants.CompaniesToFollow)}");
      }
    } on PlatformException catch (exception) {
      debugPrint("------ Exception: ${exception.toString()}");
      debugPrint("------ PrimaryColorLight ${remoteConfig.getString("primaryColorLight")}");
      debugPrint(remoteConfig.getString(Constants.CompaniesToFollow).isNotEmpty.toString());
    } catch (exception) {
      debugPrint("------ Casual Exception ${exception.toString()}");
      debugPrint("------ PrimaryColorLight ${remoteConfig.getString("primaryColorLight")}");
      if (remoteConfig.getString(Constants.CompaniesToFollow).isNotEmpty) {
        Globals.prefs!.setString(Constants.CompaniesToFollow, remoteConfig.getString(Constants.CompaniesToFollow));
        debugPrint("------ Companies to follow exception: ${remoteConfig.getString(Constants.CompaniesToFollow)}");
      }
    }
  }

  static Future<bool> initDefaultParameters(FirebaseRemoteConfig remoteConfig) async {
    try {
      CompanyConfig config = CompanyConfig(expirationDate: DateTime(2050));
      Map<String, dynamic> jsonConfig = config.toJson();

      await remoteConfig.setDefaults(jsonConfig);
      debugPrint("------ Remote Config Default Configuration");
      debugPrint(jsonConfig.toString());
      debugPrint("------ End of Default Remote Config ");
      return true;
    } catch (e) {
      debugPrint("------ Error on initDefaultParameters");
      debugPrint(e.toString());
      return false;
    }
  }

  static void initLocalParameters(FirebaseRemoteConfig remoteConfig) {
    debugPrint("------ Print all remote config for the app");
    if (remoteConfig.lastFetchTime.year == 1970) {
      debugPrint("------ Remote config never fetched at all or correctly");
      debugPrint("------ Date ${remoteConfig.lastFetchTime}");
    } else {
      debugPrint("------ Remote config has been successfully fetched.");
      debugPrint("------ Date ${remoteConfig.lastFetchTime}");
    }
  }
}
