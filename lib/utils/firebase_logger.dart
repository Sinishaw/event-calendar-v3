import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class FirebaseLogger {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  static final Map<String, String> _screensToLog = {
    'HomePage': 'Home Page',
    'YearPage': 'Year Page',
    'ConverterPage': 'Converter Page',
    'CompanyContentPage': 'Company Content Page',
    '': '',
    'UserEventPage': 'User Event Page',
    'HolidaysPage': 'Holidays Page',
    'AboutPage': 'About Page',
    'SettingPage': 'Setting Page',
    'TermsOfServicePage': 'Terms Of Service Page',
    'NationalEventDetail': 'National Event Detail',
    'CompanyContentDetail': 'Company Content Detail',
    'TopicContentDetail': 'Topic Content Detail',
    'NationalDayArticles': 'National Day Articles',
    'NationalDayArticleDetail': 'National Day Article Detail',
  };

  static final String logBelongsTo = Globals.prefs!.getString(Constants.CompanyPreference) != null
      ? "${Globals.prefs!.getString(Constants.CompanyPreference)!}_EventsLog"
      : "Default_EventsLog";

  static getCompanyName() {
    String logBelongsTo = Globals.prefs!.getString(Constants.CompanyPreference) != null
        ? "${Globals.prefs!.getString(Constants.CompanyPreference)!}_EventsLog"
        : "Default_EventsLog";
    return logBelongsTo;
  }

  static logGlobalScreenView(int index) async {
    ///TODO: Enable logging on production
    return;
    if (index >= _screensToLog.length) return;
    
    analytics.logScreenView(
      screenName: _screensToLog.values.elementAt(index),
      screenClass: _screensToLog.keys.elementAt(index),
    ).whenComplete(() => debugPrint('*** Global Screen View Log: *** ${_screensToLog.keys.elementAt(index)}'));
  }

  static logCompanyScreenView(int index) async {
    ///TODO: Enable logging on production
    return;
    String longBelongsTo = getCompanyName();
    analytics.logEvent(
      name: longBelongsTo,
      parameters: <String, String>{
        'ScreenView': _screensToLog.keys.elementAt(index),
      },
    ).whenComplete(
        () => debugPrint('*** Company Screen View Log: *** ${_screensToLog.keys.elementAt(index)} $logBelongsTo'));
  }
}
