import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

Future<void> setupRemoteConfigThemeNew(String? company) async {
  if (company == null) return;
  debugPrint("------ New remote config theme setting: $company");
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  String companyConfig = remoteConfig.getString(company);
  debugPrint("------ New remote config company setting For: $company");
  Globals.prefs!.setString(Constants.CompanyConfig, companyConfig);
  debugPrint("------ New remote config company setting Preference");
  debugPrint(companyConfig);
}
