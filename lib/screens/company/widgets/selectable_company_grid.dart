// ignore_for_file: avoid_unnecessary_containers

import 'dart:convert';
import 'package:event_calendar_v2/configs/theme/theme_model.dart';
import 'package:event_calendar_v2/language/language_change_provider.dart';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/firebase/remoteConfig/firebase_remote_config.dart';
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
  final List<Container> _selectedCompanies = [];
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
        Widget container = Container(
          decoration: BoxDecoration(
              color: Colors.white10,
              border: Border.all(color: Colors.blueGrey, width: 0.5),
              borderRadius: const BorderRadius.all(Radius.circular(5.0))),
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Positioned.fill(
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: value["logoUrl"] != null && value["logoUrl"].isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: value["logoUrl"],
                                    placeholder: (context, url) => ConstrainedBox(
                                      constraints: const BoxConstraints(minHeight: 200),
                                      child: Container(
                                        child: Center(child: Text(value["name"])),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                                  )
                                : Container(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                value["name"],
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.clip,
              )
            ],
          ),
        );
        _companiesPrefs.add(CompanyPreferenceTemplate(key, container as Container));
      });
    } else {
      FirebaseRemoteConfigV2.fetchRemoteConfig().then((value) async {
        debugPrint("------ This fetch will be used next time user");
      });
    }
  }

  _initPageState() {
    String? company = Globals.prefs!.getString(Constants.CompanyPreference);
    debugPrint('------ Company User Following: $company');
    debugPrint("------ Following company value: ${Globals.prefs!.getString(Constants.CompanyUserFollowing)}");
    if (company != null) {
      _selectedCompanies.clear();
      for (var element in _companiesPrefs) {
        if (element.preference == company) {
          _selectedCompanies.add(element.container);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _constructCompanyGridNew();
    _initPageState();
  }

  _setLocalConfig() async {
    ///TODO: Handle possible errors that might get raised here and avoid app crash or block
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
          String company = companySettings[Constants.CompanyPreference];
          String companyLogo = companySettings[Constants.CompanyLogo];

          Globals.prefs!.setString(Constants.CompanyPreference, company);
          Globals.prefs!.setString(Constants.CompanyLogo, companyLogo);
          debugPrint("------ Company Logo: $companyLogo");
          Globals.prefs!.setString(Constants.ThemePreference, companyDefaultTheme);
          Globals.prefs!.setString(Constants.LanguagePreference, defaultLanguage);
          Globals.prefs!.setString(Constants.CompanyDefaultLanguage, defaultLanguage);
          Globals.prefs!.setString(Constants.CompanyDefaultTheme, companyDefaultTheme);
          Globals.prefs!.setString(Constants.MonthImages, monthImages);

          try {
            ///SETTING IS ADDED AFTER FIRST RELEASE & MUST SKIP UNEXPECTED ERRORS
            String numberFormat = companySettings[Constants.NumberFormat];
            Globals.prefs!.setString(Constants.NumberFormat, numberFormat);
          } catch (e) {
            debugPrint(e.toString());
            Globals.prefs!.setString(Constants.NumberFormat, "ግዕዝ");
          }

          Globals.prefs!.setString(Constants.MonthImages, monthImages);

          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();

          ///TODO: This or theme provider may change both. Check and use only one provider
          Provider.of<LanguageChangeProvider>(context, listen: false)
              .changeLocal(LanguageChangeProvider().getCurrentLocaleCode());

          Globals.initMonthsImage();
          Globals.initCompanySettingIfAny();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double cardWidth = MediaQuery.of(context).size.width / 4.3;
    double cardHeight = MediaQuery.of(context).size.height / 8.5;
    int index = 0;
    Widget gridViewSelection = GridView.count(
      childAspectRatio: cardWidth / cardHeight,
      crossAxisCount: 3,
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5,
      children: _companiesPrefs.map((company) {
        return AnimationConfiguration.staggeredGrid(
            position: index++,
            duration: const Duration(milliseconds: 500),
            columnCount: 3,
            child: FlipAnimation(
                flipAxis: FlipAxis.y,
                child: InkWell(
                  onTap: () async {
                    ///Single choice logic
                    _selectedCompanies.clear();
                    debugPrint('++++++++++++++++++++ USER SELECTING COMPANY ++++++++++++++++++++');
                    debugPrint(company.preference);
                    Globals.prefs!.setString(Constants.CompanyPreference, company.preference);

                    setState(() {
                      _selectedCompanies.add(company.container);
                    });
                    Navigator.of(context).pop();

                    await _setLocalConfig();
                    Globals.prefs!.remove(Constants.ServiceProviderTermsAndPoliciesVersion);
                    widget.companyChangedListenerCallback!();
                  },
                  child: CompanyGridViewItem(
                      iconData: company.container, isSelected: _selectedCompanies.contains(company.container)),
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
        title: Center(child: Text(AppLocalizations.of(context)!.applicationServiceProvider)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                AppLocalizations.of(context)!.applicationServiceProviderNotice,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const Divider(),
            Expanded(child: staggeredGrid),
            showUseDefaultButton
                ? ElevatedButton(
                    child: const Text("Continue with DEFAULT"),
                    onPressed: () {
                      setState(() {
                        Globals.prefs!.setString(Constants.DefaultSettingAskMeLatterTime,
                            DateTime.now().add(const Duration(days: 7)).toIso8601String());
                        Globals.prefs!.setString(Constants.CompanyPreference, Constants.DefaultCompany);
                        Navigator.of(context).pop(true);
                        debugPrint("Using default...");
                      });
                    },
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
