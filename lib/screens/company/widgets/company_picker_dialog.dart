// ignore_for_file: avoid_unnecessary_containers

import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/firebase/remoteConfig/firebase_remote_config.dart';
import 'package:event_calendar_v2/screens/company/widgets/selectable_company_grid.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

class CompanyPickerDialog extends StatefulWidget {
  const CompanyPickerDialog({super.key, this.companyChangedListenerCallback, this.dismissPopupIfEmpty = false});

  final Function? companyChangedListenerCallback;
  final bool dismissPopupIfEmpty;

  @override
  State<CompanyPickerDialog> createState() => _CompanyPickerDialogState();
}

class _CompanyPickerDialogState extends State<CompanyPickerDialog> {
  late AnimationController controller;
  Animation<double>? scaleAnimation;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

    String? companiesToFollow = remoteConfig.getString(Constants.CompaniesToFollow);
    debugPrint("------ Companies to follow RC: ${companiesToFollow.isEmpty}");
    if (companiesToFollow.isEmpty && widget.dismissPopupIfEmpty) Navigator.of(context).pop();
    // String? companiesToFollowLocal = Globals.prefs!.getString(Constants.CompaniesToFollow);
    return (companiesToFollow.isEmpty)
        ? Container(
            child: SelectableCompanyGrid(
              companyChangedListenerCallback: widget.companyChangedListenerCallback,
            ),
          )
        : FutureBuilder<String>(
            future: FirebaseRC().getRemoteConfig(Constants.CompaniesToFollow),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                ///TODO: Validate if the json file is valid here.
                Globals.prefs!.setString(Constants.CompaniesToFollow, snapshot.data!);
                return Container(
                  child: SelectableCompanyGrid(
                    companyChangedListenerCallback: widget.companyChangedListenerCallback,
                  ),
                );
              } else if (snapshot.hasError) {
                ///TODO: Handle any error that may occur
                debugPrint('------- ERROR!');
                return Container(
                  child: SelectableCompanyGrid(
                    companyChangedListenerCallback: widget.companyChangedListenerCallback,
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
