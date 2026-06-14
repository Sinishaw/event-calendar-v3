import 'package:event_calendar_v2/common/config/company_profile_model.dart';

import 'month_image_urls_model.dart';
import 'terms_and_policies_model.dart';

class CompanyConfig {
  //region Constructor
  CompanyConfig({
    this.expirationDate,
    this.companyName,
    this.companyReference,
    this.topic,
    this.logo,
    this.menuHeaderImage,
    this.monthImages,
    this.defaultTheme = "Dark",
    this.defaultLanguage = "Amharic",
    this.leftMenu = false,
    this.menuBackgroundOpacity = 1,
    this.showBottomMenu = true,
    this.reverseAdsAnimation = false,
    this.verticalAxisAdsAnimation = true,
    this.primaryColorLight = "#F7D031",
    this.primaryColorDark = "#F7D031",
    this.accentColorLight = "#c75450",
    this.accentColorDark = "#c75450",
    // this.monthHeaderColor,
    // this.weekHeaderRowColor,
    // this.daysColor,
    // this.todayColor,
    // this.todaySundayColor = "#FFFFFF",
    // this.prevMonthDaysColor,
    // this.nextMonthDaysColor,
    // this.eventIndicatorColor,
    // this.menuIconColor,
    // this.menuTextColor,
    this.subscriptionPackage = "basic",
    this.logoLocation = "topLeft",
    this.adsScreenLocation = "right",
    this.isGeezNumberFormat = true,
    this.profile,
  });

  //endregion

  //region Fields
  DateTime? expirationDate;
  String? companyName, companyReference, topic, logo, menuHeaderImage, defaultTheme, defaultLanguage;
  bool? leftMenu, showBottomMenu, reverseAdsAnimation, verticalAxisAdsAnimation, isGeezNumberFormat;
  double menuBackgroundOpacity;
  MonthImageUrls? monthImages;

  ///TODO: Include ad window design option
  ///Horizontal Bottom, Vertical left/right
  ///Number of contents at a time
  ///Animation speed and type based on ad count
  String? primaryColorLight, primaryColorDark, accentColorLight, accentColorDark;
  // String? monthHeaderColor, weekHeaderRowColor, daysColor, todayColor, todaySundayColor, prevMonthDaysColor;
  // String? nextMonthDaysColor, eventIndicatorColor, menuIconColor, menuTextColor;
  String? subscriptionPackage, logoLocation, adsScreenLocation;

  CompanyProfile? profile;
  TermsAndPolicies? termsAndPolicies;

  //endregion

  //region JSON

  Map<String, dynamic> toJson() => {
        'expirationDate': expirationDate != null ? expirationDate.toString() : "",
        'companyName': companyName ?? "",
        'companyReference': companyReference ?? "",
        'topic': topic ?? "",
        'logo': logo ?? "",
        'menuHeaderImage': menuHeaderImage ?? "",
        'defaultTheme': defaultTheme ?? "",
        'defaultLanguage': defaultLanguage ?? "",
        'leftMenu': leftMenu ?? "",
        'menuBackgroundOpacity': menuBackgroundOpacity ?? "",
        'showBottomMenu': showBottomMenu ?? "",
        'reverseAdsAnimation': reverseAdsAnimation ?? "",
        'verticalAxisAdsAnimation': verticalAxisAdsAnimation ?? "",
        'monthImages': monthImages ?? "",
        'primaryColorLight': primaryColorLight ?? "",
        'primaryColorDark': primaryColorDark ?? "",
        'accentColorLight': accentColorLight ?? "",
        'accentColorDark': accentColorDark ?? "",
        // 'monthHeaderColor': monthHeaderColor != null ? monthHeaderColor : "",
        // 'weekHeaderRowColor': weekHeaderRowColor != null ? weekHeaderRowColor : "",
        // 'daysColor': daysColor != null ? daysColor : "",
        // 'todayColor': todayColor != null ? todayColor : "",
        // 'todaySundayColor': todaySundayColor != null ? todaySundayColor : "",
        // 'prevMonthDaysColor': prevMonthDaysColor != null ? prevMonthDaysColor : "",
        // 'nextMonthDaysColor': nextMonthDaysColor != null ? nextMonthDaysColor : "",
        // 'eventIndicatorColor': eventIndicatorColor != null ? eventIndicatorColor : "",
        // 'menuIconColor': menuIconColor != null ? menuIconColor : "",
        // 'menuTextColor': menuTextColor != null ? menuTextColor : "",
        'subscriptionPackage': subscriptionPackage ?? "",
        'logoLocation': logoLocation ?? "",
        'adsScreenLocation': adsScreenLocation ?? "",
        'isGeezNumberFormat': isGeezNumberFormat ?? "",
        'profile': profile ?? "",
        'termsAndPolicies': termsAndPolicies ?? "",
      };

  CompanyConfig.fromJson(Map<String, dynamic>? json)
      : expirationDate = json != null ? DateTime.parse(json['expirationDate']) : null,
        companyName = json != null ? json['name'] : null,
        companyReference = json != null ? json['company'] : null,
        topic = json != null ? json['category'] : null,
        logo = json != null ? json['logo'] : null,
        menuHeaderImage = json != null ? json['menuHeaderImage'] : null,
        defaultTheme = json != null ? json['defaultTheme'] : null,
        defaultLanguage = json != null ? json['defaultLanguage'] : null,
        leftMenu = json != null ? json['leftMenu'] : false,
        menuBackgroundOpacity = json != null ? _parseDouble(json['menuBackgroundOpacity']) : 1.0,
        showBottomMenu = json != null ? json['showBottomMenu'] : false,
        reverseAdsAnimation = json != null ? json['reverseAdsAnimation'] : false,
        verticalAxisAdsAnimation = json != null ? json['verticalAxisAdsAnimation'] : true,
        monthImages = json != null ? MonthImageUrls.fromJson(json['monthImages']) : null,
        primaryColorLight = json != null ? json['primaryColorLight'] : null,
        primaryColorDark = json != null ? json['primaryColorDark'] : null,
        accentColorLight = json != null ? json['accentColorLight'] : null,
        accentColorDark = json != null ? json['accentColorDark'] : null,
        // monthHeaderColor = json != null ? json['monthHeaderColor'] : null,
        // weekHeaderRowColor = json != null ? json['weekHeaderRowColor'] : null,
        // daysColor = json != null ? json['daysColor'] : null,
        // todayColor = json != null ? json['todayColor'] : null,
        // todaySundayColor = json != null ? json['todaySundayColor'] : null,
        // prevMonthDaysColor = json != null ? json['prevMonthDaysColor'] : null,
        // nextMonthDaysColor = json != null ? json['nextMonthDaysColor'] : null,
        // eventIndicatorColor = json != null ? json['eventIndicatorColor'] : null,
        // menuIconColor = json != null ? json['menuIconColor'] : null,
        // menuTextColor = json != null ? json['menuTextColor'] : null,
        subscriptionPackage = json != null ? json['subscriptionPackage'] : null,
        logoLocation = json != null ? json['logoLocation'] : null,
        adsScreenLocation = json != null ? json['adsScreenLocation'] : null,
        isGeezNumberFormat = json != null ? json['isGeezNumberFormat'] : null,
        profile = json != null ? CompanyProfile.fromJson(json['profile']) : null,
        termsAndPolicies = json != null ? TermsAndPolicies.fromJson(json['termsAndPolicies']) : null;
//endregion
}

/// Safely parses [value] to a double regardless of whether it arrives
/// from Remote Config JSON as a String ("0.8"), a double (0.8), or an int (1).
double _parseDouble(dynamic value, {double fallback = 1.0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}
