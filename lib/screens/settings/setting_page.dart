// ignore_for_file: unnecessary_string_interpolations

import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/l10n/app_localizations.dart';import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/configs/theme/theme_model.dart';
import 'package:event_calendar_v2/language/language_change_provider.dart';
import 'package:event_calendar_v2/screens/company/widgets/company_picker_dialog.dart';
import 'package:event_calendar_v2/screens/topic/model/topic_model.dart';
import 'package:event_calendar_v2/screens/topic/widgets/topic_picker_dialog.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingPage extends StatefulWidget {
  static const String routeName = '/setting';
  const SettingPage({super.key, this.title});
  final String? title;

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late List<bool> _themeSelections;
  late List<bool> _numberFormatSelections;
  late List<bool> _weekDayStartSelections;
  String? _theme;
  String? _numberFormat;
  String? _weekStartDay;
  String? _languagePreference;
  String? _companyFollowing;
  String? _topicsOfInterest;
  String? _languageDropdownValue = 'One';
  bool? _companyNotificationChannel;
  bool? _interestsNotificationChannel;
  List<String?> _languageOptions = List.generate(0, (index) => null, growable: true);
  bool isSelected = true;
  @override
  void initState() {
    super.initState();
    _initAllSetting();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(AppLocalizations.of(context)!.setting)),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          Container(),
        ],
      ),
      body: _getCustomSettingList(),
    );
  }

  _getCustomSettingList() {
    Color pc = Theme.of(context).primaryColor;
    Color? tc = Theme.of(context).textTheme.bodyLarge!.color;
    TextStyle ts = const TextStyle(fontSize: 12);
    return ListView(
      children: [
        ListTile(
            leading: Icon(Icons.language, color: pc),
            title: Text(AppLocalizations.of(context)!.language),
            subtitle: Text("$_languagePreference", style: ts),
            trailing: DropdownButton<String>(
              value: _languageDropdownValue,
              iconSize: 24,
              elevation: 16,
              style: const TextStyle(color: Colors.grey),
              onChanged: (String? language) {
                setState(() {
                  if (language == 'One') {
                    language = 'አማርኛ';
                  }
                  _languageDropdownValue = language;
                  _languagePreference = language;
                  _languageOptions = ["አማርኛ", "Oromiffa", "ትግርኛ", "English"];
                  String languageCode = "am";
                  switch (language) {
                    case "Oromiffa":
                      languageCode = "or";
                      break;

                    case "ትግርኛ":
                      languageCode = "te";
                      break;

                    case "English":
                      languageCode = "en";
                      break;
                    default:
                      {
                        languageCode = "am";
                      }
                  }
                  Globals.prefs!.setString(Constants.LanguagePreference, language!);
                  Provider.of<LanguageChangeProvider>(context, listen: false).changeLocal(languageCode);
                });
              },
              items: _languageOptions.map<DropdownMenuItem<String>>((String? value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value == 'One' ? 'Select Language' : value!),
                );
              }).toList(),
            )),
        ListTile(
          leading: Icon(Icons.brightness_medium_sharp, color: pc),
          title: Text(AppLocalizations.of(context)!.theme),
          subtitle: Text(_theme == "Dark" ? AppLocalizations.of(context)!.dark : AppLocalizations.of(context)!.light,
              style: ts),
          trailing: ToggleButtons(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            isSelected: _themeSelections,
            fillColor: pc.withOpacity(0.5),
            selectedColor: tc,
            onPressed: (int index) {
              _onPressTheme(index);
            },
            children: <Widget>[
              Text(AppLocalizations.of(context)!.light),
              Text(AppLocalizations.of(context)!.dark),
            ],
          ),
        ),
        ListTile(
          leading: Text(
            "፩/1",
            style: TextStyle(color: pc, fontWeight: FontWeight.bold),
          ),
          title: Text(AppLocalizations.of(context)!.numberFormat),
          subtitle: Text("$_numberFormat", style: ts),
          trailing: ToggleButtons(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            isSelected: _numberFormatSelections,
            fillColor: pc.withOpacity(0.5),
            selectedColor: tc,
            onPressed: (int index) {
              _onPressNumberFormat(index);
            },
            children: const <Widget>[
              Text('፩,፪,...'),
              Text('1,2,...'),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.today, color: pc),
          title: Text(AppLocalizations.of(context)!.weekStartDay),
          subtitle: Text(_weekStartDay == "Mon" ? AppLocalizations.of(context)!.mon : AppLocalizations.of(context)!.sun,
              style: ts),
          trailing: ToggleButtons(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            isSelected: _weekDayStartSelections,
            fillColor: pc.withOpacity(0.5),
            selectedColor: tc,
            onPressed: (int index) {
              _onPressWeekStartDay(index);
              Globals.todayIsInitialized = false;
            },
            children: <Widget>[
              Text(AppLocalizations.of(context)!.mon),
              Text(AppLocalizations.of(context)!.sun),
            ],
          ),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.notifications, color: pc),
          title: Text(AppLocalizations.of(context)!.notifications),
          subtitle: Text(AppLocalizations.of(context)!.restartIsRequired, style: ts),
        ),

        ///COMPANY
        ListTile(
          leading: const Text(""),
          title: Text(AppLocalizations.of(context)!.companyChannel),
          subtitle: _companyNotificationChannel!
              ? Text(AppLocalizations.of(context)!.enabled)
              : Text(AppLocalizations.of(context)!.disabled),
          subtitleTextStyle: ts,
          trailing: Switch(
            value: _companyNotificationChannel ?? true,
            onChanged: (bool value) {
              setState(() {
                isSelected = value;
                Globals.prefs!.setString(Constants.CompanyNotificationChannel, "$value");
                _initCompanyNotificationChannel();
                debugPrint("------ Company Notification Channel: $value");
              });
            },
          ),
        ),
        ListTile(
          leading: const Text(""),
          title: Text(AppLocalizations.of(context)!.interestChannel),
          subtitle: _interestsNotificationChannel!
              ? Text(AppLocalizations.of(context)!.enabled)
              : Text(AppLocalizations.of(context)!.disabled),
          subtitleTextStyle: ts,
          trailing: Switch(
            value: _interestsNotificationChannel ?? true,
            onChanged: (bool value) {
              setState(() {
                Globals.prefs!.setString(Constants.InterestsNotificationChannel, "$value");
                _initInterestsNotificationChannel();
                debugPrint("------ Interests Notification Channel: $value");
              });
            },
          ),
        ),

        ListTile(
          leading: Icon(Icons.business_center, color: pc),
          title: Text(AppLocalizations.of(context)!.serviceProvider),
          subtitle: Text("$_companyFollowing", style: ts),
          trailing: TextButton(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                AppLocalizations.of(context)!.select,
                style: TextStyle(color: pc),
              ),
            ),
            onPressed: () {
              setState(() {
                showDialog(
                  context: context,
                  builder: (_) => CompanyPickerDialog(
                    companyChangedListenerCallback: _companyChangeUpdateCallback,
                  ),
                );
              });
            },
          ),
        ),

        ListTile(
          leading: Icon(Icons.topic, color: pc),
          title: Text(AppLocalizations.of(context)!.interests),
          subtitle: Text("$_topicsOfInterest", style: ts),
          trailing: TextButton(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                AppLocalizations.of(context)!.update,
                style: TextStyle(color: pc),
              ),
            ),
            onPressed: () {
              setState(() {
                showDialog(
                  context: context,
                  builder: (_) => TopicPickerDialog(
                    callBack: _topicChangeUpdateCallback,
                  ),
                );
              });
            },
          ),
        ),
      ],
    );
  }

  _getLanguage() {
    String? languagePref = Globals.prefs!.getString(Constants.LanguagePreference);
    languagePref ??= 'አማርኛ';
    return languagePref;
  }

  _onPressTheme(int index) {
    if (index == 1) {
      Globals.prefs!.setString(Constants.ThemePreference, 'Dark');
    } else {
      Globals.prefs!.setString(Constants.ThemePreference, 'Light');
    }
    setState(() {
      _theme = Utility.getAppTheme();
      for (int i = 0; i < _themeSelections.length; i++) {
        _themeSelections[i] = i == index;
      }
      Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
    });
  }

  _onPressNumberFormat(index) {
    if (index == 0) {
      Globals.prefs!.setString(Constants.NumberFormat, 'ግዕዝ');
    } else {
      Globals.prefs!.setString(Constants.NumberFormat, 'Eng');
    }
    setState(() {
      _numberFormat = Utility.getNumberFormat();
      for (int i = 0; i < _numberFormatSelections.length; i++) {
        _numberFormatSelections[i] = i == index;
      }
    });
  }

  _onPressWeekStartDay(index) {
    if (index == 0) {
      Globals.prefs!.setString(Constants.WeekStartDay, 'Mon');
    } else {
      Globals.prefs!.setString(Constants.WeekStartDay, 'Sun');
    }
    setState(() {
      _weekStartDay = Utility.getWeekStartDay();
      for (int i = 0; i < _weekDayStartSelections.length; i++) {
        _weekDayStartSelections[i] = i == index;
      }
    });
  }

  _initAllSetting() {
    try {
      _initLanguageOptions();
      _initAppTheme();
      _initNumberFormat();
      _initWeekStartDay();
      _initCompanyPreference();
      _initCompanyNotificationChannel();
      _initInterestsNotificationChannel();
    } catch (e) {
      debugPrint("------ Setting init page error 1");
      debugPrint(e.toString());
    }
    try {
      _initTopicInterests();
    } catch (e) {
      debugPrint("------ Setting init page error 2");
      debugPrint(e.toString());
    }
  }

  _initLanguageOptions() {
    for (var element in Globals.languagesNameValue) {
      debugPrint("------ Language Option: $element");
    }

    try {
      _languagePreference = _getLanguage();
      _languageDropdownValue = _languagePreference;
      if (Globals.languagesNameValue.isNotEmpty) {
        _languageOptions.clear();
        _languageOptions.add("One");
        for (var element in Globals.languagesNameValue) {
          _languageOptions.add(element["name"]);
        }
      } else {
        ///TODO: Get available language options from json file that comes from firebase remote config
        _languageOptions = ["አማርኛ", "Oromiffa", "ትግርኛ", "English"];
      }
    } catch (e) {
      debugPrint(e.toString());
      _languageOptions = ["አማርኛ", "Oromiffa", "ትግርኛ", "English"];
    }
  }

  _initAppTheme() {
    _theme = Utility.getAppTheme();

    debugPrint("------ Current theme of app: $_theme");
    if (_theme == "Dark") {
      _themeSelections = [false, true];
    } else {
      _themeSelections = [true, false];
    }
  }

  _initNumberFormat() {
    _numberFormat = Utility.getNumberFormat();
    if (_numberFormat == "ግዕዝ") {
      _numberFormatSelections = [true, false];
    } else {
      _numberFormatSelections = [false, true];
    }
  }

  _initWeekStartDay() {
    _weekStartDay = Utility.getWeekStartDay();
    if (_weekStartDay == "Mon") {
      _weekDayStartSelections = [true, false];
    } else {
      _weekDayStartSelections = [false, true];
    }
  }

  _initCompanyPreference() {
    var foll = Globals.prefs!.getString(Constants.CompanyUserFollowing);
    _companyFollowing =
        foll != null ? "${Globals.setting.companyName}" : AppLocalizations.of(MonthGlobals.context!)!.noCompany;
  }

  _initTopicInterests() {
    String? interests = Topic.getUserSubscribedTopicsInCSV();
    interests = interests != null && interests.isNotEmpty
        ? interests
        : AppLocalizations.of(MonthGlobals.context!)!.noInterestIsSelected;
    _topicsOfInterest = "$interests";
  }

  _topicChangeUpdateCallback() {
    setState(() {
      _initTopicInterests();
    });
  }

  _companyChangeUpdateCallback() {
    setState(() {
      _initCompanyPreference();
    });
  }

  _initCompanyNotificationChannel() {
    var channel = Globals.prefs!.getString(Constants.CompanyNotificationChannel);
    _companyNotificationChannel = channel == null || channel == 'true' ? true : false;
  }

  _initInterestsNotificationChannel() {
    var channel = Globals.prefs!.getString(Constants.InterestsNotificationChannel);
    _interestsNotificationChannel = channel == null || channel == 'true' ? true : false;
  }
}
