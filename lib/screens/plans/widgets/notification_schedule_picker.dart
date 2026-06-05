import 'package:event_calendar_v2/l10n/app_localizations.dart';import 'package:event_calendar_v2/common/globals.dart';
import 'package:flutter/material.dart';

class NotificationSchedulePicker extends StatefulWidget {
  const NotificationSchedulePicker({super.key, this.selectedOption, this.callback});
  final int? selectedOption;
  final Function? callback;

  @override
  State<NotificationSchedulePicker> createState() => _NotificationSchedulePickerState();
}

class _NotificationSchedulePickerState extends State<NotificationSchedulePicker> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  double? width, height;

  int? _selectedItem;

  _init() {
    ///Init Animation
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 450));
    _scaleAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeOutSine);
    _animationController.forward();

    ///Default or previously selected category from entry form
    _selectedItem = widget.selectedOption;
  }

  @override
  void didChangeDependencies() {
    width = MediaQuery.of(context).size.width / 1.5;
    height = MediaQuery.of(context).size.height / 2;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  _getItemRow(index, isSelected, context) {
    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_box : Icons.check_box_outline_blank,
        size: 32,
      ),
      title: Text(Globals.notificationScheduleOptionList[index]),
      onTap: () {
        setState(() {
          _selectedItem = index;
          widget.callback!(_selectedItem);
          Navigator.of(context).pop();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          height: height,
          width: width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Scaffold(
              appBar: AppBar(
                title: Center(
                  child: FittedBox(
                      fit: BoxFit.scaleDown, child: Text(AppLocalizations.of(context)!.scheduleNotification!)),
                ),
                automaticallyImplyLeading: false,
              ),
              body: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ListView.builder(
                  itemCount: Globals.notificationScheduleOptionList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      color:
                          _selectedItem == index ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
                      child: _getItemRow(index, _selectedItem == index, context),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
