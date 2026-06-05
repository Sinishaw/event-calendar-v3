import 'package:flutter/material.dart';

import 'screens/about/about_page.dart';
import 'screens/company/company_content.dart';
import 'screens/converter/converter_page.dart';
import 'screens/events/national_event_page.dart';
import 'screens/plans/user_event_page.dart';
import 'screens/home/home_page.dart';
import 'screens/settings/setting_page.dart';
import 'screens/terms/terms_of_service.dart';
import 'screens/year/year_page.dart';

class Pages {
  static const List<Widget> screenViewOptions = <Widget>[
    HomePage(),
    YearPage(),
    ConverterPage(),
    CompanyContentPage(),
    Placeholder(),
    UserEventPage(),
    NationalEventsPage(),
    AboutPage(),
    SettingPage(),
    TermsOfServicesPage()
  ];
}
