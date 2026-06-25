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
    return Drawer(
      backgroundColor: Theme.of(context).dialogBackgroundColor.withOpacity(menuOpacity),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: widget.isLeftMenu! ? const Radius.circular(24) : Radius.zero,
          bottomRight: widget.isLeftMenu! ? const Radius.circular(24) : Radius.zero,
          topLeft: widget.isLeftMenu! ? Radius.zero : const Radius.circular(24),
          bottomLeft: widget.isLeftMenu! ? Radius.zero : const Radius.circular(24),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          SideMenuHeader(opacity: menuOpacity),
          const SizedBox(height: 8),
          SideMenuItem(
            text: AppLocalizations.of(context)!.home,
            icon: Icons.today_rounded,
            isSelected: Globals.displayingIndex == 0,
            onTap: () => {Globals.selectedIndex = Globals.displayingIndex = 0, widget.callback(0)},
          ),
          SideMenuItem(
            text: AppLocalizations.of(context)!.year,
            icon: Icons.grid_view_rounded,
            isSelected: Globals.displayingIndex == 1,
            onTap: () => {Globals.selectedIndex = Globals.displayingIndex = 1, widget.callback(1)},
          ),
          SideMenuItem(
            text: AppLocalizations.of(context)!.dateConverter,
            icon: Icons.change_circle_rounded,
            isSelected: Globals.displayingIndex == 2,
            onTap: () => {Globals.selectedIndex = Globals.displayingIndex = 2, widget.callback(2)},
          ),
          SideMenuItem(
            text: AppLocalizations.of(context)!.archives,
            icon: Icons.feed_rounded,
            isSelected: Globals.displayingIndex == 3,
            onTap: () => {Globals.selectedIndex = Globals.displayingIndex = 3, widget.callback(3)},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Divider(
              color: Theme.of(context).dividerColor.withOpacity(0.4),
              thickness: 1,
            ),
          ),
          SideMenuItem(
            text: AppLocalizations.of(context)!.plans,
            icon: Icons.edit_calendar_rounded,
            isSelected: Globals.displayingIndex == 5,
            onTap: () => {Globals.selectedIndex = Globals.displayingIndex = 4, widget.callback(5)},
          ),
          SideMenuItem(
            text: AppLocalizations.of(context)!.nationalDays,
            icon: Icons.celebration_rounded,
            isSelected: Globals.displayingIndex == 6,
            onTap: () => {Globals.selectedIndex = 5, Globals.displayingIndex = 4, widget.callback(6)},
          ),
          SideMenuItem(
            text: AppLocalizations.of(context)!.aboutApp,
            icon: Icons.info_rounded,
            isSelected: Globals.displayingIndex == 7,
            onTap: () => {Globals.selectedIndex = 6, Globals.displayingIndex = 4, widget.callback(7)},
          ),
          SideMenuItem(
            text: AppLocalizations.of(context)!.setting,
            icon: Icons.settings_rounded,
            isSelected: Globals.displayingIndex == 8,
            onTap: () => {Globals.selectedIndex = 7, Globals.displayingIndex = 4, widget.callback(8)},
          ),
          SideMenuItem(
            text: AppLocalizations.of(context)!.termsAndConditions,
            icon: Icons.description_rounded,
            isSelected: Globals.displayingIndex == 9,
            onTap: () => {Globals.selectedIndex = 8, Globals.displayingIndex = 4, widget.callback(9)},
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Divider(
              color: Theme.of(context).dividerColor.withOpacity(0.4),
              thickness: 1,
            ),
          ),
          CopyRightMenuItem(
            text: Globals.generalSetting.termsAndPolicies != null
                ? ' version - ${Globals.generalSetting.termsAndPolicies!.appVersionNumber} ('
                    '${Globals.generalSetting.termsAndPolicies!.appVersionName})\n $cb'
                : 'version - 0.0.1 \n$cb ',
          )
        ],
      ),
    );
  }
}

