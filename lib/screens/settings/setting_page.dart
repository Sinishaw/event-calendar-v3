// ignore_for_file: unnecessary_string_interpolations

import 'package:event_calendar_v2/screens/home/month_globals.dart';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/configs/theme/theme_model.dart';
import 'package:event_calendar_v2/language/language_change_provider.dart';
import 'package:event_calendar_v2/screens/company/widgets/company_picker_dialog.dart';
import 'package:event_calendar_v2/services/home_widget/home_widget_service.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.setting),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: _getCustomSettingList(),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Row(
        children: [
          Container(
            width: 3.5,
            height: 12,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({required List<Widget> children, required ThemeData theme, required bool isDark}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor.withOpacity(isDark ? 0.35 : 0.65),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildTopicsWrap(String topicsCsv, ThemeData theme) {
    final noInterest = AppLocalizations.of(MonthGlobals.context!)!.noInterestIsSelected;
    if (topicsCsv.isEmpty || topicsCsv == noInterest) {
      return Text(topicsCsv, style: const TextStyle(fontSize: 12, color: Colors.grey));
    }
    final topics = topicsCsv.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: topics.map((topic) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.2),
                width: 0.8,
              ),
            ),
            child: Text(
              topic,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _onLanguageSelected(String language) {
    setState(() {
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
      Globals.prefs!.setString(Constants.LanguagePreference, language);
      Globals.prefs!.setBool(Constants.UserLanguageOverride, true);
      Provider.of<LanguageChangeProvider>(context, listen: false).changeLocal(languageCode);
    });
    // Refresh the date widget after the MaterialApp rebuild applies the new
    // locale, so MonthGlobals' localized ET names are up to date before caching.
    WidgetsBinding.instance.addPostFrameCallback((_) => HomeWidgetService.refreshNow());
  }

  _getCustomSettingList() {
    Color pc = Theme.of(context).primaryColor;
    Color? tc = Theme.of(context).textTheme.bodyLarge!.color;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    TextStyle ts = const TextStyle(fontSize: 12, color: Colors.grey);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      physics: const BouncingScrollPhysics(),
      children: [
        // SECTION 1: Preferences
        _buildSectionHeader(AppLocalizations.of(context)!.generalTerms, theme),
        _buildCardContainer(
          theme: theme,
          isDark: isDark,
          children: [
            // Language Option
            InkWell(
              onTap: () {
                final langs = _languageOptions
                    .where((l) => l != 'One' && l != null)
                    .cast<String>()
                    .toList();
                showDialog(
                  context: context,
                  builder: (context) => LanguagePickerDialog(
                    currentLanguage: _languagePreference,
                    languageOptions: langs.isEmpty
                        ? ["አማርኛ", "Oromiffa", "ትግርኛ", "English"]
                        : langs,
                    onLanguageSelected: _onLanguageSelected,
                  ),
                );
              },
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.language, color: pc, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.language,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text("$_languagePreference", style: ts),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: theme.dividerColor.withOpacity(0.12), indent: 44),

            // Theme Option
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.brightness_medium_sharp, color: pc, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.theme,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _theme == "Dark"
                              ? AppLocalizations.of(context)!.dark
                              : AppLocalizations.of(context)!.light,
                          style: ts,
                        ),
                      ],
                    ),
                  ),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(8),
                    isSelected: _themeSelections,
                    fillColor: pc.withOpacity(0.12),
                    selectedColor: pc,
                    color: tc?.withOpacity(0.6),
                    borderColor: theme.dividerColor.withOpacity(0.15),
                    selectedBorderColor: pc.withOpacity(0.4),
                    constraints: const BoxConstraints(minHeight: 28, minWidth: 55),
                    onPressed: (int index) {
                      _onPressTheme(index);
                    },
                    children: <Widget>[
                      Text(AppLocalizations.of(context)!.light, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      Text(AppLocalizations.of(context)!.dark, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor.withOpacity(0.12), indent: 44),

            // Number Format Option
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    alignment: Alignment.center,
                    child: Text(
                      "፩/1",
                      style: TextStyle(color: pc, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.numberFormat,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text("$_numberFormat", style: ts),
                      ],
                    ),
                  ),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(8),
                    isSelected: _numberFormatSelections,
                    fillColor: pc.withOpacity(0.12),
                    selectedColor: pc,
                    color: tc?.withOpacity(0.6),
                    borderColor: theme.dividerColor.withOpacity(0.15),
                    selectedBorderColor: pc.withOpacity(0.4),
                    constraints: const BoxConstraints(minHeight: 28, minWidth: 55),
                    onPressed: (int index) {
                      _onPressNumberFormat(index);
                    },
                    children: const <Widget>[
                      Text('፩,፪,...', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      Text('1,2,...', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor.withOpacity(0.12), indent: 44),

            // Week Start Day Option
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.today, color: pc, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.weekStartDay,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _weekStartDay == "Mon"
                              ? AppLocalizations.of(context)!.mon
                              : AppLocalizations.of(context)!.sun,
                          style: ts,
                        ),
                      ],
                    ),
                  ),
                  ToggleButtons(
                    borderRadius: BorderRadius.circular(8),
                    isSelected: _weekDayStartSelections,
                    fillColor: pc.withOpacity(0.12),
                    selectedColor: pc,
                    color: tc?.withOpacity(0.6),
                    borderColor: theme.dividerColor.withOpacity(0.15),
                    selectedBorderColor: pc.withOpacity(0.4),
                    constraints: const BoxConstraints(minHeight: 28, minWidth: 55),
                    onPressed: (int index) {
                      _onPressWeekStartDay(index);
                      Globals.todayIsInitialized = false;
                    },
                    children: <Widget>[
                      Text(AppLocalizations.of(context)!.mon, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      Text(AppLocalizations.of(context)!.sun, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        // SECTION 2: Notifications
        _buildSectionHeader(AppLocalizations.of(context)!.notifications, theme),
        _buildCardContainer(
          theme: theme,
          isDark: isDark,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: pc),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.restartIsRequired,
                      style: ts.copyWith(fontSize: 11.5, color: theme.colorScheme.secondary),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor.withOpacity(0.12)),

            // Company Channel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Row(
                children: [
                  Icon(Icons.business_rounded, color: pc, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.companyChannel,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _companyNotificationChannel!
                              ? AppLocalizations.of(context)!.enabled
                              : AppLocalizations.of(context)!.disabled,
                          style: ts,
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _companyNotificationChannel ?? true,
                    activeColor: pc,
                    onChanged: (bool value) {
                      setState(() {
                        isSelected = value;
                        Globals.prefs!.setString(Constants.CompanyNotificationChannel, "$value");
                        _initCompanyNotificationChannel();
                        debugPrint("------ Company Notification Channel: $value");
                      });
                    },
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.dividerColor.withOpacity(0.12), indent: 44),

            // Interests Channel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Row(
                children: [
                  Icon(Icons.notifications_active_rounded, color: pc, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.interestChannel,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _interestsNotificationChannel!
                              ? AppLocalizations.of(context)!.enabled
                              : AppLocalizations.of(context)!.disabled,
                          style: ts,
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _interestsNotificationChannel ?? true,
                    activeColor: pc,
                    onChanged: (bool value) {
                      setState(() {
                        Globals.prefs!.setString(Constants.InterestsNotificationChannel, "$value");
                        _initInterestsNotificationChannel();
                        debugPrint("------ Interests Notification Channel: $value");
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),

        // SECTION 3: Service Provider & Interests
        _buildSectionHeader(AppLocalizations.of(context)!.serviceProvider, theme),
        _buildCardContainer(
          theme: theme,
          isDark: isDark,
          children: [
            // Service Provider Selection
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => CompanyPickerDialog(
                    companyChangedListenerCallback: _companyChangeUpdateCallback,
                  ),
                );
              },
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.business_center, color: pc, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.serviceProvider,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text("$_companyFollowing", style: ts),
                        ],
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: pc,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => CompanyPickerDialog(
                            companyChangedListenerCallback: _companyChangeUpdateCallback,
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.select,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: theme.dividerColor.withOpacity(0.12), indent: 44),

            // Interests/Topics Selection
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => TopicPickerDialog(
                    callBack: _topicChangeUpdateCallback,
                  ),
                );
              },
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Icon(Icons.topic, color: pc, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.interests,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          _buildTopicsWrap("$_topicsOfInterest", theme),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: pc,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => TopicPickerDialog(
                            callBack: _topicChangeUpdateCallback,
                          ),
                        );
                      },
                      child: Text(
                        AppLocalizations.of(context)!.update,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
    Globals.prefs!.setBool(Constants.UserThemeOverride, true);
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
    Globals.prefs!.setBool(Constants.UserNumberFormatOverride, true);
    setState(() {
      _numberFormat = Utility.getNumberFormat();
      for (int i = 0; i < _numberFormatSelections.length; i++) {
        _numberFormatSelections[i] = i == index;
      }
    });
    // Keep the home-screen date widget in sync with the new numeral format.
    HomeWidgetService.refreshNow();
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

  /// Maps ISO language codes and alternate names (as stored by Remote Config
  /// company onboarding) to the display names used by the dropdown items.
  static const Map<String, String> _langCodeToDisplayName = {
    'am': 'አማርኛ',
    'Amharic': 'አማርኛ',
    'amharic': 'አማርኛ',
    'or': 'Oromiffa',
    'Oromiffa': 'Oromiffa',
    'oromiffa': 'Oromiffa',
    'te': 'ትግርኛ',
    'Tigrinya': 'ትግርኛ',
    'tigrinya': 'ትግርኛ',
    'en': 'English',
    'English': 'English',
    'english': 'English',
    'አማርኛ': 'አማርኛ',
    'ትግርኛ': 'ትግርኛ',
  };

  _initLanguageOptions() {
    for (var element in Globals.languagesNameValue) {
      debugPrint("------ Language Option: $element");
    }

    try {
      _languagePreference = _getLanguage();

      // Normalise: stored value may be an ISO code ("am") or an alternate
      // name ("Amharic") from Remote Config — map it to the dropdown display name.
      final String normalised =
          _langCodeToDisplayName[_languagePreference] ?? _languagePreference ?? 'One';

      // If normalised differs from what was stored, persist the corrected value
      // so subsequent launches don't hit the same mismatch.
      if (normalised != _languagePreference && normalised != 'One') {
        Globals.prefs!.setString(Constants.LanguagePreference, normalised);
        _languagePreference = normalised;
      }

      _languageDropdownValue = _languageOptions.contains(normalised) ? normalised : 'One';

      if (Globals.languagesNameValue.isNotEmpty) {
        _languageOptions.clear();
        _languageOptions.add("One");
        for (var element in Globals.languagesNameValue) {
          _languageOptions.add(element["name"]);
        }
        // Re-validate after list is built
        _languageDropdownValue =
            _languageOptions.contains(normalised) ? normalised : 'One';
      } else {
        ///TODO: Get available language options from json file that comes from firebase remote config
        _languageOptions = ["አማርኛ", "Oromiffa", "ትግርኛ", "English"];
        _languageDropdownValue =
            _languageOptions.contains(normalised) ? normalised : _languageOptions.first;
      }
    } catch (e) {
      debugPrint(e.toString());
      _languageOptions = ["አማርኛ", "Oromiffa", "ትግርኛ", "English"];
      _languageDropdownValue = _languageOptions.first;
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

class LanguagePickerDialog extends StatelessWidget {
  final String? currentLanguage;
  final List<String> languageOptions;
  final ValueChanged<String> onLanguageSelected;

  const LanguagePickerDialog({
    super.key,
    required this.currentLanguage,
    required this.languageOptions,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor.withOpacity(isDark ? 0.95 : 0.98),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.primaryColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.language_rounded, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.language,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 18,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: theme.dividerColor.withOpacity(0.12)),
            const SizedBox(height: 12),
            ...languageOptions.map((lang) {
              final isSelected = lang == currentLanguage;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () {
                    onLanguageSelected(lang);
                    Navigator.of(context).pop();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primaryColor.withOpacity(0.08)
                          : theme.primaryColor.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? theme.primaryColor.withOpacity(0.4)
                            : theme.dividerColor.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          lang,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14.5,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: theme.colorScheme.primary,
                            size: 18,
                          )
                        else
                          Icon(
                            Icons.circle_outlined,
                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.2),
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

