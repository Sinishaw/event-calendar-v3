// ignore_for_file: constant_identifier_names, unnecessary_string_interpolations

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/firebase/cloudMessaging/FcmHandler.dart';
import 'package:event_calendar_v2/firebase/firestore/firestore.dart';
import 'package:event_calendar_v2/firebase/remoteConfig/firebase_remote_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

///Model cloud document fields
class CompanyFields {
  static const String COMPANY_NAME = "name";
  static const String COMPANY_REFERENCE = "company";
  static const String COMPANY_LOGO = "iUrl";
}

class CompanyModel {
  String? name;
  String? reference;
  String? logoUrl;

  late CloudFireStore _fireStore;
  static const String COLLECTION_NAME = "CompanyData";

  CompanyModel({this.name, this.reference, this.logoUrl}) {
    _fireStore = CloudFireStore();
  }

  Future<List<CompanyModel>> getAllRecords(String collection) async {
    List<QueryDocumentSnapshot> snapShotList = await _fireStore.getAllRecords(COLLECTION_NAME);
    List<CompanyModel> list = toModelList(snapShotList);
    return list;
  }

  List<CompanyModel> toModelList(List<QueryDocumentSnapshot> snapShotList) {
    List<CompanyModel> list = List.empty(growable: true);
    for (var doc in snapShotList) {
      list.add(CompanyModel(
          name: doc[CompanyFields.COMPANY_NAME],
          reference: doc[CompanyFields.COMPANY_REFERENCE],
          logoUrl: doc[CompanyFields.COMPANY_LOGO]));
    }
    return list;
  }

  static bool isCompanyConfigExists() {
    debugPrint("------ Company Confix Exist Checking...");
    String? config = Globals.prefs!.getString(Constants.CompanyConfig);

    if (config != null) {
      try {
        Map<String, dynamic> companySetting = jsonDecode(config);
        String? companyConfig = companySetting[Constants.CompanyConfig];
        debugPrint("------ 1: CONFIGURED! $companyConfig");
        return true;
      } catch (e) {
        debugPrint("------ 2: NOT CONFIGURED! And required correction");
        return false;
      }
    }
    debugPrint("------ 3: NOT CONFIGURED!");
    return false;
  }

  ///Fetches all company list from Remote Config and stores to local shared preference
  static fetchRemoteCompanyList() async {
    debugPrint("------ Fetching all company list option...");

    ///TODO: Set logical timeout period to avoid long term waiting
    FirebaseRC().getRemoteConfig(Constants.CompaniesToFollow).timeout(const Duration(seconds: 10)).then((value) {
      debugPrint("------ Companies to follow...");
      debugPrint(value);
      Globals.prefs!.setString(Constants.CompaniesToFollow, value);
    }).onError((dynamic error, stackTrace) {
      ///TODO: Handle remote config fetch error properly
      ///TODO: Redirect user to error handling page where system can try to resolve the issue.
    });
  }

  ///After successful read of company list, user will choose one and this method will handle
  ///to read details of user preferred company specifics and store them locally
  static fetchCompanyPreferredByUser() async {
    // String _companyUserPreferred = Globals.prefs.getString(Constants.CompanyUserFollowing);
    String? companyUserPreferred = Globals.prefs!.getString(Constants.CompanyPreference);
    debugPrint("------ Fetching company remote config: $companyUserPreferred");
    if (companyUserPreferred != null && companyUserPreferred.isNotEmpty) {
      ///TODO: Set logical timeout period to avoid long term waiting
      FirebaseRC().getRemoteConfig(companyUserPreferred).then((value) {
        debugPrint("------ Company config....");
        debugPrint(value);

        Globals.prefs!.setString(Constants.CompanyConfig, value);
        Map<String, dynamic> companySettings = jsonDecode(value);
        debugPrint("------ 1: ${companySettings[Constants.MonthImages]}");

        String defaultLanguage = companySettings[Constants.CompanyDefaultLanguage];
        String company = companySettings[Constants.CompanyPreference];
        String companyLogo = companySettings[Constants.CompanyLogo];
        String defaultTheme = companySettings[Constants.CompanyDefaultTheme];
        String monthImages = jsonEncode(companySettings[Constants.MonthImages]);

        debugPrint("------ 2: ");
        Globals.prefs!.setString(Constants.CompanyPreference, company);
        Globals.prefs!.setString(Constants.CompanyLogo, companyLogo);

        if (Globals.prefs!.getString(Constants.LanguagePreference) == null) {
          Globals.prefs!.setString(Constants.LanguagePreference, defaultLanguage);
        }

        Globals.prefs!.setString(Constants.CompanyDefaultLanguage, defaultLanguage);
        Globals.prefs!.setString(Constants.CompanyDefaultTheme, defaultTheme);
        debugPrint("------ 3: ");
        Globals.prefs!.setString(Constants.MonthImages, monthImages);
        Globals.prefs!.setString(Constants.CompanyUserFollowing, companyUserPreferred);
        debugPrint("------ 5: ");

        ///Set theme if only no preference is set before
        String? currentTheme = Globals.prefs!.getString(Constants.ThemePreference);
        if (currentTheme == null) {
          Globals.prefs!.setString(Constants.ThemePreference, defaultTheme);

          ///Default theme not set indicates company config default is not configured
          try {
            ///SETTING IS ADDED AFTER FIRST RELEASE & MUST SKIP UNEXPECTED ERRORS
            String numberFormat = companySettings[Constants.NumberFormat];
            Globals.prefs!.setString(Constants.NumberFormat, numberFormat);
          } catch (e) {
            debugPrint(e.toString());
            Globals.prefs!.setString(Constants.NumberFormat, "ግዕዝ");
          }
        }
        debugPrint("------ 6: $currentTheme");

        ///ADD NEW VERSION LOGICS BELOW
        try {
          String? companyCategoryValue = companySettings[Constants.CompanyCategoryField];
          Globals.prefs!
              .setString(Constants.CompanyCategory, companyCategoryValue != null ? companyCategoryValue : "DEFAULT");
          // ignore: empty_catches
        } catch (e) {}

        /// TODO: Commented
        // Localize.initMenuWithSelectedLanguage();

        debugPrint("------ 7: ");
        // Provider.of<ThemeModel>(context, listen: false).toggleTheme();
      }).onError((dynamic error, stackTrace) {
        ///TODO: Handle remote config fetch error properly
        ///TODO: Redirect user to error handling page where system can try to resolve the issue.
      });
    }
  }

  ///Check if user company selection is synced with firestore. If not synced and SR param will be null
  ///But if user is already following, then it will have the company. Also sync if Local and Cloud are sync
  ///with the same name, other wise remove previous follow up and add user under new company
  static syncUserFollowingCompany() async {
    String? cloudFollowingCompany = Globals.prefs!.getString(Constants.CompanyUserFollowing);
    debugPrint("------ Remote Company Following before Null check: ");
    String? localCompany;
    localCompany = Globals.prefs!.getString(Constants.CompanyPreference);
    if (cloudFollowingCompany == null) {
      debugPrint("------ Local Company Following on Remote Null $localCompany");

      ///If local company not sync with cloud, then register user under company and update CompanyUserFollowing SP
      if (localCompany != null) {
        debugPrint("------ Local - Cloud sync (Local Null). $localCompany - $cloudFollowingCompany");
        FieldValue timestamp = FieldValue.serverTimestamp();
        FirebaseMessaging.instance.getToken().then((token) {
          var tokens = token!.split(":");
          FirebaseFirestore.instance
              .collection("Companies")
              .doc("$localCompany")
              .collection("Users")
              .doc(tokens[0])
              .set({"id": tokens[0], "token": token, "createdTimestamp": timestamp}).then((value) {
            Globals.prefs!.setString(Constants.CompanyUserFollowing, localCompany!);
            debugPrint("------ SUBSCRIBING COMPANY $localCompany");
            FcmHandler.subscribeUserToTopic(localCompany);
            debugPrint("------ INCREASE INSTALLATION COUNTER");
            CloudFireStore().registerCompanyCount(company: localCompany, increaseBy: 1);
          });
        });
      } else {
        ///If cloud and local are null, then take the DEFAULT company
        String? companyToFollow = Globals.prefs!.getString(Constants.CompaniesToFollow);
        if (companyToFollow != null) {
          Globals.prefs!.setString(Constants.CompanyPreference, Constants.DefaultCompany);
          syncUserFollowingCompany();
        }
      }
    } else {
      debugPrint("------ Local - Cloud sync: $localCompany - $cloudFollowingCompany");

      debugPrint("------ Remote Company is Not null: $cloudFollowingCompany");
      if (cloudFollowingCompany != localCompany) {
        debugPrint("------ Remote and Local Company not match: $cloudFollowingCompany != $localCompany");

        ///TODO: Decide whether it is allowed to switch between companies. If yes, then unfollow remoteFollowing
        ///and follow local company at remote

        /// TODO: Commented
        FirebaseMessaging.instance.getToken().then((token) {
          var tokens = token!.split(":");
          FirebaseFirestore.instance
              .collection("Companies")
              .doc("$cloudFollowingCompany")
              .collection("Users")
              .doc("${tokens[0]}")
              .delete()
              .then((value) {
            ///Removing this SP will force the first "if" statement to execute on the next startup
            Globals.prefs!.remove(Constants.CompanyUserFollowing);
            debugPrint("------ UN-SUBSCRIBING COMPANY: $cloudFollowingCompany");
            FcmHandler.unSubscribeUserFromTopic(cloudFollowingCompany);
            // Globals.prefs.remove(Constants.CompanyConfig);
            ///DECREASE USER INSTALLATION BY ONE
            CloudFireStore().registerCompanyCount(company: cloudFollowingCompany, increaseBy: -1);

            ///TODO: Efficiency and infinite loop further check is required for recursion
            syncUserFollowingCompany();
            debugPrint("------ Nullify CompanyUserFollowing");
          });
        });
      }
    }
  }
}
