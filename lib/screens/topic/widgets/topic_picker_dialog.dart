// ignore_for_file: avoid_unnecessary_containers

import 'dart:convert';
import 'package:event_calendar_v2/l10n/app_localizations.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/firebase/cloudMessaging/FcmHandler.dart';
import 'package:event_calendar_v2/screens/topic/model/topic_model.dart';
import 'package:event_calendar_v2/screens/topic/model/topic_template.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'topic_grid_item.dart';

class TopicPickerDialog extends StatefulWidget {
  const TopicPickerDialog({super.key, this.callBack});
  final Function? callBack;

  @override
  State<TopicPickerDialog> createState() => _TopicPickerDialogState();
}

class _TopicPickerDialogState extends State<TopicPickerDialog> {
  final List<TopicTemplate> _selectedTopicsList = [];
  final List<TopicTemplate> _topicsPref = [];
  bool isFirstTimeSetup = false;

  @override
  void initState() {
    _initAllTopics();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    int index = 0;

    final isSelectionValid = _topicsPref.isEmpty || _selectedTopicsList.length >= 3;

    Widget gridViewSelection = GridView.count(
      childAspectRatio: 0.9,
      crossAxisCount: 3,
      mainAxisSpacing: 10.0,
      crossAxisSpacing: 10.0,
      children: _topicsPref.map((subscriptionTopic) {
        final isSelected = _selectedTopicsList.any((t) => t.preference == subscriptionTopic.preference);
        return InkWell(
          onTap: () {
            debugPrint("------ Tapped: ${subscriptionTopic.preference}");
            setState(() {
              _resetUserSelectionLocally(subscriptionTopic);
              if (widget.callBack != null) widget.callBack!();
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimationConfiguration.staggeredGrid(
            position: index++,
            duration: const Duration(milliseconds: 400),
            columnCount: 3,
            child: FlipAnimation(
              flipAxis: FlipAxis.y,
              child: TopicGridItem(
                name: subscriptionTopic.preference,
                imageUrl: subscriptionTopic.imageUrl,
                isSelected: isSelected,
              ),
            ),
          ),
        );
      }).toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.interests),
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
                  AppLocalizations.of(context)!.topicNotice,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    fontSize: 12.5,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _topicsPref.isNotEmpty
                  ? gridViewSelection
                  : Center(
                      child: Text(
                        AppLocalizations.of(context)!.thisContentIsNotDownloadedYet,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: isSelectionValid ? theme.colorScheme.primary : Colors.grey.withOpacity(0.3),
                  foregroundColor: isSelectionValid ? Colors.white : Colors.grey,
                  elevation: isSelectionValid ? 2 : 0,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  isSelectionValid
                      ? "Done"
                      : "Done (${_selectedTopicsList.length}/3 selected)",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Topic> allTopicList = [];

  _initAllTopics() {
    if (Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal) != null) {
      debugPrint("------ Decoding.... ${Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal)}");
      Iterable iterable = json.decode(Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal)!);
      allTopicList = List<Topic>.from(iterable.map((model) => Topic.fromJson(model)));
      String? companyCategory = Globals.prefs!.getString(Constants.CompanyCategory);

      for (var element in allTopicList) {
        if (!element.name!.contains("~")) continue;
        var data = element.name!.split("~");
        TopicTemplate cellTemplate = TopicTemplate(data[0], data[1]);
        if (element.isActive!) {
          var contain = _topicsPref.where((element) => element.preference == cellTemplate.preference);

          if (contain.isEmpty && cellTemplate.preference != companyCategory) {
            _topicsPref.add(cellTemplate);
          }

          var selContains = _selectedTopicsList.where((sel) => sel.preference == cellTemplate.preference);
          if (element.syncStatus == TopicSyncStatusOption.selected ||
              element.syncStatus == TopicSyncStatusOption.followed) {
            if (selContains.isEmpty) {
              _selectedTopicsList.add(cellTemplate);
            }
          } else {
            _selectedTopicsList.removeWhere((sel) => sel.preference == cellTemplate.preference);
          }
        }
        debugPrint("------ Name: ${data[0]} SyncStatus: ${element.syncStatus!.index}");
      }
    }
  }

  _resetUserSelectionLocally(TopicTemplate subscriptionTopic) {
    for (var element in allTopicList) {
      if (!element.name!.contains("~")) continue;
      var data = element.name!.split("~");
      debugPrint("------ Element name: ${data[0]}");
      if (data[0] == subscriptionTopic.preference) {
        if (element.syncStatus == TopicSyncStatusOption.created) {
          element.syncStatus = TopicSyncStatusOption.selected;
          _selectedTopicsList.add(subscriptionTopic);
          debugPrint("------ 1: ${subscriptionTopic.preference}");
          FcmHandler.subscribeUserToTopic(subscriptionTopic.preference);
        } else if (element.syncStatus == TopicSyncStatusOption.selected) {
          _selectedTopicsList.removeWhere((sel) => sel.preference == subscriptionTopic.preference);
          element.syncStatus = TopicSyncStatusOption.created;
          debugPrint("------ 2: ");
          FcmHandler.unSubscribeUserFromTopic(subscriptionTopic.preference);
        } else if (element.syncStatus == TopicSyncStatusOption.followed) {
          _selectedTopicsList.removeWhere((sel) => sel.preference == subscriptionTopic.preference);
          element.syncStatus = TopicSyncStatusOption.removed;
          debugPrint("------ 3:");
          FcmHandler.unSubscribeUserFromTopic(subscriptionTopic.preference);
        } else if (element.syncStatus == TopicSyncStatusOption.removed) {
          _selectedTopicsList.add(subscriptionTopic);
          element.syncStatus = TopicSyncStatusOption.followed;
          debugPrint("------ 4:");
          FcmHandler.subscribeUserToTopic(subscriptionTopic.preference);
        }
      }
      debugPrint("------ Name: ${element.name} SyncStatus: ${element.syncStatus}");
    }

    String newJsonList = jsonEncode(allTopicList);
    Globals.prefs!.setString(Constants.TopicsUserSubscribedLocal, newJsonList);
  }
}

