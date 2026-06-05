import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/menu/copy_right_menu_item.dart';
import 'package:event_calendar_v2/menu/side_menu_header.dart';
import 'package:event_calendar_v2/menu/side_menu_item.dart';
import 'package:flutter/material.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key, this.isLeftMenu = true, required this.scaffoldKey, required this.callback});
  final bool? isLeftMenu;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function callback;
  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    double menuOpacity;
    String cb = "developed by - eLexicon tech solutions\n©2017-2023 All rights reserved";
    try {
      menuOpacity = Globals.setting.menuBackgroundOpacity != 0 ? Globals.setting.menuBackgroundOpacity : 1.0;
    } catch (e) {
      menuOpacity = Globals.setting.menuBackgroundOpacity;
    }
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Theme.of(context).dialogBackgroundColor.withOpacity(menuOpacity),
      ),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            SideMenuHeader(opacity: menuOpacity),
            SideMenuItem(
              text: AppLocalizations.of(context)!.home,
              icon: Icons.home,
              onTap: () => {Globals.selectedIndex = Globals.displayingIndex = 0, widget.callback(0)},
            ),
            SideMenuItem(
              text: AppLocalizations.of(context)!.year,
              icon: Icons.grid_on,
              onTap: () => {Globals.selectedIndex = Globals.displayingIndex = 1, widget.callback(1)},
            ),
            SideMenuItem(
              text: AppLocalizations.of(context)!.dateConverter,
              icon: Icons.swap_horizontal_circle,
              onTap: () => {Globals.selectedIndex = Globals.displayingIndex = 2, widget.callback(2)},
            ),
            SideMenuItem(
              text: AppLocalizations.of(context)!.archives,
              icon: Icons.note,
              onTap: () => {Globals.selectedIndex = Globals.displayingIndex = 3, widget.callback(3)},
            ),
            const Divider(
              thickness: 2,
            ),
            SideMenuItem(
              text: AppLocalizations.of(context)!.plans,
              icon: Icons.event_note,
              onTap: () => {Globals.selectedIndex = Globals.displayingIndex = 4, widget.callback(5)},
            ),
            SideMenuItem(
              text: AppLocalizations.of(context)!.nationalDays,
              icon: Icons.celebration,
              onTap: () => {Globals.selectedIndex = 5, Globals.displayingIndex = 4, widget.callback(6)},
            ),
            SideMenuItem(
              text: AppLocalizations.of(context)!.aboutApp,
              icon: Icons.info_sharp,
              onTap: () => {Globals.selectedIndex = 6, Globals.displayingIndex = 4, widget.callback(7)},
            ),
            SideMenuItem(
              text: AppLocalizations.of(context)!.setting,
              icon: Icons.settings,
              onTap: () => {Globals.selectedIndex = 7, Globals.displayingIndex = 4, widget.callback(8)},
            ),
            SideMenuItem(
              text: AppLocalizations.of(context)!.termsAndConditions,
              icon: Icons.text_snippet,
              onTap: () => {Globals.selectedIndex = 8, Globals.displayingIndex = 4, widget.callback(9)},
            ),
            const Divider(),
            CopyRightMenuItem(
              text: Globals.generalSetting.termsAndPolicies != null
                  ? ' version - ${Globals.generalSetting.termsAndPolicies!.appVersionNumber} ('
                      '${Globals.generalSetting.termsAndPolicies!.appVersionName})\n $cb'
                  : 'version - 0.0.1 \n$cb ',
            )
          ],
        ),
      ),
    );
  }
}
