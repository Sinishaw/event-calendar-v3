import 'package:event_calendar_v2/l10n/app_localizations.dart';import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/screens/company/widgets/company_picker_dialog.dart';
import 'package:flutter/material.dart';

class TermsOfServicesPage extends StatefulWidget {
  static const String routeName = '/terms_of_services';
  const TermsOfServicesPage({super.key, this.title, this.tabIndex});
  final String? title;
  final int? tabIndex;

  @override
  State<TermsOfServicesPage> createState() => _TermsOfServicesPageState();
}

class _TermsOfServicesPageState extends State<TermsOfServicesPage> {
  int? _tabIndex = 0;

  @override
  void initState() {
    if (widget.tabIndex != null) _tabIndex = widget.tabIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: _tabIndex!,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(tabs: [
            Text(AppLocalizations.of(context)!.generalTerms),
            Text(AppLocalizations.of(context)!.serviceProviderTerms)
          ]),
          title: Center(child: Text(AppLocalizations.of(context)!.termsAndConditions!)),
          automaticallyImplyLeading: false,
          actions: <Widget>[
            Container(),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: TabBarView(
            children: [
              Globals.generalSetting.termsAndPolicies != null
                  ? SingleChildScrollView(child: Text("${Globals.generalSetting.termsAndPolicies!.terms}"))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.thisContentIsNotDownloadedYet),
                      ],
                    ),
              Globals.setting.profile != null
                  ? SingleChildScrollView(child: Text("${Globals.setting.termsAndPolicies!.terms}"))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppLocalizations.of(context)!.noServiceProviderIsAvailable),
                        TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => const CompanyPickerDialog(dismissPopupIfEmpty: true),
                              );
                            },
                            child: Text(AppLocalizations.of(context)!.findServiceProvider))
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
