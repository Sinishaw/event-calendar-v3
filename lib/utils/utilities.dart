import 'dart:convert';

import 'package:event_calendar_v2/l10n/app_localizations.dart';import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/geez_numbers.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/company/models/company_content_model.dart';
import 'package:event_calendar_v2/screens/company/widgets/company_picker_dialog.dart';
import 'package:event_calendar_v2/screens/home/model/core_model.dart';
import 'package:event_calendar_v2/screens/terms/widgets/terms_and_policies_agreement_dialog.dart';
import 'package:event_calendar_v2/screens/topic/model/topic_model.dart';
import 'package:event_calendar_v2/screens/topic/widgets/topic_picker_dialog.dart';
import 'package:event_calendar_v2/shared/models/local_date_model.dart';
import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:flutter/material.dart';

class Utility {
  static Color? colorConvert(String color) {
    color = color.replaceAll("#", "");
    Color? converted;
    if (color.length == 6) {
      converted = Color(int.parse("0xFF$color"));
    } else if (color.length == 8) {
      converted = Color(int.parse("0x$color"));
    }
    return converted;
  }

  static showTermsDialog(BuildContext context) {
    try {
      var generalTermsVersion = Globals.prefs!.getInt(Constants.GeneralTermsAndPoliciesVersion);
      var providerTermsVersion = Globals.prefs!.getInt(Constants.ServiceProviderTermsAndPoliciesVersion);
      debugPrint("------ Showing terms and policies SHARED PREFERENCE flags...");
      debugPrint("------ General terms version: $generalTermsVersion");
      debugPrint("------ Provider terms version: $providerTermsVersion");

      var fetchedGeneralTermsVersion = Globals.generalSetting.termsAndPolicies!.version!;
      var fetchedProviderTermsVersion = Globals.setting.termsAndPolicies!.version!;
      debugPrint("------ Showing terms and policies local REMOTE CONFIG FETCHED flags...");
      debugPrint("------ Fetched General terms version: $fetchedGeneralTermsVersion");
      debugPrint("------ Fetched Provider terms version: $fetchedProviderTermsVersion");

      bool needToShowTermsAndPoliciesDialog = false;
      int newGenTerm = int.tryParse(fetchedGeneralTermsVersion) ?? 0;
      int newProTerm = int.tryParse(fetchedProviderTermsVersion) ?? 0;

      if (generalTermsVersion == null || providerTermsVersion == null) {
        needToShowTermsAndPoliciesDialog = true;
      } else if (newGenTerm > generalTermsVersion || newProTerm > providerTermsVersion) {
        needToShowTermsAndPoliciesDialog = true;
      }

      if (needToShowTermsAndPoliciesDialog) {
        Future.delayed(const Duration(milliseconds: 300), () {
          showDialog(
            context: context,
            builder: (_) => TermsAndPoliciesAgreementDialog(
              tabIndex: 0,
              generalTermsVersion: newGenTerm,
              providerTermsVersion: newProTerm,
            ),
          );
        });
      }
    } catch (e) {
      debugPrint("------ Error on populating terms and services");
      debugPrint(e.toString());

      ///TODO: Make sure this operation will not bottleneck the program flow and prevent users from using
    }
  }

  static showTimeDifference({required BuildContext context, required LocalDate gcDate, required LocalDate etDate}) {
    DateTime now = DateTime.now();
    DateTime schedule = DateTime(gcDate.year!, gcDate.month!, gcDate.day!);

    Duration diff = schedule.difference(now);
    bool isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;

    int leapCounts = 0;
    for (int year = etDate.year!; year < MonthGlobals.etNowYear!; year++) {
      if (MonthModel.isLeapYear(year)) leapCounts++;
    }

    String direction = AppLocalizations.of(context)!.future;
    int absDiff = 0;
    if (diff.inDays < 0) {
      direction = AppLocalizations.of(context)!.past;
    }
    int days = diff.inDays.abs() - leapCounts;
    int yearResult = days ~/ 365;
    int dayResult = diff.inDays.abs() - ((yearResult * 365) + leapCounts);

    debugPrint("------ Total Days : ${diff.inDays.abs()}, Leap Count: $leapCounts");

    ///Remove zero values from string message

    String resultString = "${yearResult > 0 ? "$yearResult ${AppLocalizations.of(context)!.year}" : ""} "
        "${dayResult > 0 ? "$dayResult ${AppLocalizations.of(context)!.days}" : ""} ";

    // double? boldTextSize = Theme.of(context).textTheme.headline5!.fontSize;
    double boldTextSize = 25;
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 0,
            shadowColor: Theme.of(context).primaryColor,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                children: [
                  Text(
                    "${isGeezNumbers ? GeezNumbers.geezNumbers[etDate.day! - 1] : etDate.day}/${isGeezNumbers ? GeezNumbers.geezNumbers[etDate.month! - 1] : etDate.month}/${isGeezNumbers ? GeezNumbers.geezYears[etDate.year! - 1900] : etDate.year} ዓም",
                    style: const TextStyle(fontSize: 10, letterSpacing: 1),
                  ),
                  Text(
                    "${gcDate.day}/${gcDate.month}/${gcDate.year} GC",
                    style: const TextStyle(fontSize: 10, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: Colors.transparent,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: FittedBox(fit: BoxFit.fitWidth, child: Text(direction, style: TextStyle(fontSize: boldTextSize))),
            ),
          ),
          Card(
            color: Colors.transparent,
            elevation: 0,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${yearResult > 0 ? "$yearResult" : ""} ",
                      style: TextStyle(
                        fontSize: boldTextSize,
                      )),
                  Text("${yearResult > 0 ? AppLocalizations.of(context)!.year : ""} "),
                  Text(
                    "${dayResult > 0 ? "$dayResult" : ""} ",
                    style: TextStyle(fontSize: boldTextSize),
                  ),
                  Text("${dayResult > 0 ? AppLocalizations.of(context)!.days : ""} "),
                ],
              ),
            ),
          ),
          const Text("")
        ],
      ),
    );
  }

  static isDateValidAndSupported({CalendarType? calendarType, required int year, int? month, int? day}) {
    try {
      if (year < 1900 || year > 2050) return false;
      if (calendarType == CalendarType.Ethiopian) {
        if (day! < 1 || day > 30) return false;
        if (month! < 1 || month > 13) return false;
        if (month == 13) {
          int pagume = MonthModel.isLeapYear(year) ? 6 : 5;
          if (day > pagume) return false;
        }
      } else {
        if (day! < 1 || day > 31) return false;
        int monthLength = MonthModel.getDaysInGcMonth(month! /*- 1*/, year);
        if (day > monthLength) return false;
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static getFormattedEtDate(gcDateString) {
    bool isGeezNumbers = Utility.getNumberFormat() != 'Eng' ? true : false;

    DateTime gcDate = DateTime.parse(gcDateString);
    print("Gregorian date is: ${gcDate.year}");
    LocalDate etDate = MonthModel.toEc(day: gcDate.day, month: gcDate.month, year: gcDate.year)!;
    print("Ethiopian date is:  ${etDate.month}");

    String etDay = isGeezNumbers ? GeezNumbers.geezNumbers[etDate.day!] : "${etDate.day}";
    String etYear = isGeezNumbers ? GeezNumbers.geezYears[etDate.year! - 1900] : "${etDate.year}";
    String? etMonth = MonthGlobals.etMonthsLong[etDate.month! - 1];

    String etDateFormatted = "$etMonth $etDay, $etYear";
    return etDateFormatted;
  }

  static showServiceProviderExpiryNoticeDialog(BuildContext context, {bool dismissible = true}) {
    try {
      DateTime comparableDate = DateTime.now().subtract(const Duration(days: 1));
      debugPrint("------ Dismissible: $dismissible");
      debugPrint("------ Companies To Follow: ${Globals.prefs!.getString(Constants.CompaniesToFollow)}");
      debugPrint("------ Company Config: ${Globals.prefs!.getString(Constants.CompanyConfig)}");
      debugPrint("------ Expiration Date: ${Globals.setting.expirationDate}");

      ///If global setting is not initialized correctly yet, try to fetch local
      if (Globals.setting.expirationDate == null) {
        dismissible = true;
        Globals.initCompanySettingFromLocalIfAny();
      } else {
        if (Globals.setting.companyReference == Constants.DefaultCompany) {
          String? companiesToFollow = Globals.prefs!.getString(Constants.CompaniesToFollow);
          if (companiesToFollow != null && companiesToFollow.isNotEmpty) {
            Map<String, dynamic> companies = jsonDecode(companiesToFollow);
            if (companies.length > 1) {
              String? dateString = Globals.prefs!.getString(Constants.DefaultSettingAskMeLatterTime);
              if (dateString != null) {
                DateTime showTimeSchedule = DateTime.parse(dateString);
                comparableDate = showTimeSchedule;
              } else {
                comparableDate = DateTime.now().subtract(const Duration(days: 1));
                Globals.prefs!.setString(Constants.DefaultSettingAskMeLatterTime, comparableDate.toIso8601String());
              }
            } else if (companies.length == 1) {
              ///DEFAULT COMPANY config is downloaded and has expiration date surely
              try {
                comparableDate = Globals.setting.expirationDate!;
              } catch (e) {
                debugPrint(e.toString());
              }
            }
          }
        } else {
          comparableDate = Globals.setting.expirationDate!;
        }
      }
      if (comparableDate.isBefore(DateTime.now()) && Globals.prefs!.getString(Constants.CompaniesToFollow) != null) {
        showDialog(
          context: context,
          barrierDismissible: true,
          useSafeArea: true,
          builder: (_) => const CompanyPickerDialog(
            dismissPopupIfEmpty: true,
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static showTopicSubscriptionListDialog(BuildContext context, {bool dismissible = true}) {
    try {
      List<Topic> allTopicList = [];
      debugPrint("------ Dismissible: $dismissible");
      String? topicsLocallySubscribed = Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal);
      int localSubscription = 0;
      if (topicsLocallySubscribed != null) {
        Iterable iterable = json.decode(topicsLocallySubscribed);
        allTopicList = List<Topic>.from(iterable.map((model) => Topic.fromJson(model)));
        localSubscription = allTopicList
            .where((element) => (element.syncStatus == TopicSyncStatusOption.selected ||
                element.syncStatus == TopicSyncStatusOption.followed))
            .length;
        debugPrint("------ Length Lambda expression: $localSubscription");
        if (localSubscription < 3) {
          showDialog(
            context: context,
            barrierDismissible: true,
            useSafeArea: true,
            builder: (_) => const TopicPickerDialog(),
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  ///Get Setting Parameters

  static getAppTheme() {
    String? currentTheme = Globals.prefs!.getString(Constants.ThemePreference);
    currentTheme ??= 'Light';
    return currentTheme;
  }

  static getNumberFormat() {
    String? currentNumberFormat = Globals.prefs!.getString(Constants.NumberFormat);
    currentNumberFormat ??= 'ግዕዝ';
    return currentNumberFormat;
  }

  static getWeekStartDay() {
    String? currentNumberFormat = Globals.prefs!.getString(Constants.WeekStartDay);
    currentNumberFormat ??= 'Mon';
    return currentNumberFormat;
  }

  static getBottomMenuDisplayStatus() {
    var showBottomMenu = Globals.prefs!.getString(Constants.ShowBottomMenu);
    if (showBottomMenu == null) {
      return true;
    } else if (showBottomMenu == 'false') {
      return false;
    }
    return true;
  }

  static bool isUserAllowNotificationChannel(String? channel) {
    String? company = Globals.prefs!.getString(Constants.CompanyUserFollowing);
    if (company == channel) {
      String? companyChannelEnabled = Globals.prefs!.getString(Constants.CompanyNotificationChannel);
      if (companyChannelEnabled == null || companyChannelEnabled == 'true') return true;
      return false;
    } else {
      String? interestsChannelEnabled = Globals.prefs!.getString(Constants.InterestsNotificationChannel);
      if (interestsChannelEnabled == null || interestsChannelEnabled == 'true') return true;
      return false;
    }
  }

  static int getZeroOrNumber(int? number) {
    int result = 0;
    if (number != null) {
      result = int.parse(number.toString());
    }
    return result;
  }

  static void getDeviceInfo(BuildContext context) {
    Globals.deviceWidth = MediaQuery.of(context).size.width;
    Globals.deviceHeight = MediaQuery.of(context).size.height;
    Globals.deviceDip = MediaQuery.of(context).devicePixelRatio;
  }

  static void cacheUserRelatedContents() async {
    List<String> topics = [];
    var company = Globals.prefs!.getString(Constants.CompanyPreference);
    topics.clear();
    if (company != null) {
      topics.add(company);
    } else {
      company = "default";
    }
    List<Topic> followedTopics = Topic.getUserSubscribedTopics();
    for (var element in followedTopics) {
      var data = element.name!.split("~");
      topics.add(data[0]);
    }
    debugPrint("------ Cache Topics Subscriptions: $topics");
    CompanyContentModel().cacheUserRelatedContents(company, topics);
  }
}
