// ignore_for_file: avoid_unnecessary_containers

import 'dart:convert';
import 'package:event_calendar_v2/configs/theme/theme_model.dart';
import 'package:event_calendar_v2/language/language_change_provider.dart';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/firebase/remoteConfig/firebase_remote_config.dart';
import 'package:event_calendar_v2/utils/utilities.dart';
import 'package:event_calendar_v2/screens/company/models/company_preference_model.dart';
import 'package:event_calendar_v2/configs/theme/theme_initializer.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import 'company_grid_view_item.dart';

class SelectableCompanyGrid extends StatefulWidget {
  const SelectableCompanyGrid({super.key, this.companyChangedListenerCallback});
  final Function? companyChangedListenerCallback;

  @override
  State<SelectableCompanyGrid> createState() => _SelectableCompanyGridState();
}

class _SelectableCompanyGridState extends State<SelectableCompanyGrid> {
  String? _selectedCompanyKey;
  final List<CompanyPreferenceTemplate> _companiesPrefs = [];

  _constructCompanyGridNew() async {
    String? companiesToFollowLocal = Globals.prefs!.getString(Constants.CompaniesToFollow);

    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    String companiesToFollow = remoteConfig.getString(Constants.CompaniesToFollow);

    debugPrint("------ CompaniesToFollow Local: $companiesToFollowLocal");
    debugPrint("------ CompaniesToFollow Remote $companiesToFollow");

    if (companiesToFollow.isNotEmpty) {
      Map<String, dynamic> companies = jsonDecode(companiesToFollow);
      companies.forEach((key, value) {
        debugPrint("------ Reference: $key Company: ${value["name"]}");
        _companiesPrefs.add(CompanyPreferenceTemplate(
          key,
          value["name"] ?? "",
          value["logoUrl"] ?? "",
        ));
      });
    } else {
      FirebaseRemoteConfigV2.fetchRemoteConfig().then((value) async {
        debugPrint("------ This fetch will be used next time user");
      });
    }
  }

  _initPageState() {
    _selectedCompanyKey = Globals.prefs!.getString(Constants.CompanyPreference);
    debugPrint('------ Company User Following: $_selectedCompanyKey');
    debugPrint("------ Following company value: ${Globals.prefs!.getString(Constants.CompanyUserFollowing)}");
  }

  @override
  void initState() {
    super.initState();
    _constructCompanyGridNew();
    _initPageState();
  }

  _setLocalConfig() async {
    String? company = Globals.prefs!.getString(Constants.CompanyPreference);
    String? companyF = Globals.prefs!.getString(Constants.CompanyUserFollowing);
    debugPrint("------ Company Pref: $company");
    debugPrint("------ Company Following $companyF");
    if (company != null) {
      await setupRemoteConfigThemeNew(company).then((value) {
        final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
        String companyConfig = remoteConfig.getString(company);
        debugPrint("------ Local $companyConfig");

        if (companyConfig.isNotEmpty) {
          Map<String, dynamic> companySettings = jsonDecode(companyConfig);
          debugPrint("------ Company Default Theme");
          debugPrint(companySettings[Constants.CompanyDefaultTheme]);
          String companyDefaultTheme = companySettings[Constants.CompanyDefaultTheme];
          String monthImages = jsonEncode(companySettings[Constants.MonthImages]);

          String defaultLanguage = companySettings[Constants.CompanyDefaultLanguage];
          String companyPref = companySettings[Constants.CompanyPreference];
          String companyLogo = companySettings[Constants.CompanyLogo];

          Globals.prefs!.setString(Constants.CompanyPreference, companyPref);
          Globals.prefs!.setString(Constants.CompanyLogo, companyLogo);
          debugPrint("------ Company Logo: $companyLogo");

          if (Globals.prefs!.getBool(Constants.UserThemeOverride) != true) {
            Globals.prefs!.setString(Constants.ThemePreference, Utility.normalizeTheme(companyDefaultTheme));
          }

          if (Globals.prefs!.getBool(Constants.UserLanguageOverride) != true) {
            Globals.prefs!.setString(Constants.LanguagePreference, defaultLanguage);
          }
          Globals.prefs!.setString(Constants.CompanyDefaultLanguage, defaultLanguage);
          Globals.prefs!.setString(Constants.CompanyDefaultTheme, companyDefaultTheme);
          Globals.prefs!.setString(Constants.MonthImages, monthImages);

          if (Globals.prefs!.getBool(Constants.UserNumberFormatOverride) != true) {
            try {
              String numberFormat = companySettings[Constants.NumberFormat];
              Globals.prefs!.setString(Constants.NumberFormat, Utility.normalizeNumberFormat(numberFormat));
            } catch (e) {
              debugPrint(e.toString());
              Globals.prefs!.setString(Constants.NumberFormat, "ግዕዝ");
            }
          }

          Globals.prefs!.setString(Constants.MonthImages, monthImages);

          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();

          if (Globals.prefs!.getBool(Constants.UserLanguageOverride) != true) {
            Provider.of<LanguageChangeProvider>(context, listen: false)
                .changeLocal(LanguageChangeProvider().getCurrentLocaleCode());
          }

          Globals.initMonthsImage();
          Globals.initCompanySettingIfAny();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    int index = 0;

    Widget gridViewSelection = GridView.count(
      childAspectRatio: 0.85,
      crossAxisCount: 3,
      mainAxisSpacing: 10.0,
      crossAxisSpacing: 10.0,
      children: _companiesPrefs.map((company) {
        final isSelected = company.preference == _selectedCompanyKey;
        return AnimationConfiguration.staggeredGrid(
            position: index++,
            duration: const Duration(milliseconds: 400),
            columnCount: 3,
            child: FlipAnimation(
                flipAxis: FlipAxis.y,
                child: InkWell(
                  onTap: () async {
                    debugPrint('++++++++++++++++++++ USER SELECTING COMPANY ++++++++++++++++++++');
                    debugPrint(company.preference);
                    Globals.prefs!.setString(Constants.CompanyPreference, company.preference);

                    setState(() {
                      _selectedCompanyKey = company.preference;
                    });
                    Navigator.of(context).pop();

                    await _setLocalConfig();
                    Globals.prefs!.remove(Constants.ServiceProviderTermsAndPoliciesVersion);
                    widget.companyChangedListenerCallback!();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: CompanyGridViewItem(
                    name: company.name,
                    logoUrl: company.logoUrl,
                    isSelected: isSelected,
                  ),
                )));
      }).toList(),
    );

    Widget staggeredGrid = AnimationConfiguration.staggeredGrid(
        position: 0,
        duration: const Duration(milliseconds: 375),
        columnCount: 3,
        child: FlipAnimation(
            flipAxis: FlipAxis.y,
            child: _companiesPrefs.isNotEmpty
                ? gridViewSelection
                : Center(child: Text(AppLocalizations.of(context)!.noCompany))));

    bool showUseDefaultButton = false;
    try {
      String? dateString = Globals.prefs!.getString(Constants.DefaultSettingAskMeLatterTime);
      DateTime showTimeSchedule = DateTime.parse(dateString!);
      if (showTimeSchedule.isBefore(DateTime.now())) {
        String? company = Globals.prefs!.getString(Constants.CompanyPreference);
        if (company == Constants.DefaultCompany) showUseDefaultButton = true;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.applicationServiceProvider),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: theme.cardColor.withOpacity(isDark ? 0.25 : 0.45),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.applicationServiceProviderNotice,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    fontSize: 12.5,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: staggeredGrid),
            if (showUseDefaultButton)
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    "Continue with DEFAULT",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  onPressed: () {
                    setState(() {
                      Globals.prefs!.setString(Constants.DefaultSettingAskMeLatterTime,
                          DateTime.now().add(const Duration(days: 7)).toIso8601String());
                      Globals.prefs!.setString(Constants.CompanyPreference, Constants.DefaultCompany);
                      Navigator.of(context).pop(true);
                      debugPrint("Using default...");
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

