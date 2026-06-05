// ignore_for_file: avoid_unnecessary_containers

import 'dart:convert';

import 'package:event_calendar_v2/l10n/app_localizations.dart';import 'package:cached_network_image/cached_network_image.dart';
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
    double width = MediaQuery.of(context).size.width / 4.3;
    double height = MediaQuery.of(context).size.height / 8.5;
    int index = 0;
    Widget gridViewSelection = GridView.count(
      childAspectRatio: width / height,
      crossAxisCount: 3,
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      children: _topicsPref.map((subscriptionTopic) {
        return InkWell(
          onTap: () {
            debugPrint("------ Tapped: ${subscriptionTopic.preference}");
            setState(() {
              _resetUserSelectionLocally(subscriptionTopic);
              if (widget.callBack != null) widget.callBack!();
            });
          },
          child: AnimationConfiguration.staggeredGrid(
            position: index++,
            duration: const Duration(milliseconds: 500),
            columnCount: 3,
            child: FlipAnimation(
              flipAxis: FlipAxis.y,
              child: TopicGridItem(
                  iconData: subscriptionTopic.container, isSelected: _selectedTopicsList.contains(subscriptionTopic)),
            ),
          ),
        );
      }).toList(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.interests),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Text(
                AppLocalizations.of(context)!.topicNotice,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            const Divider(),
            Expanded(
              child: _topicsPref.isNotEmpty
                  ? gridViewSelection
                  : Center(
                      child: Text(AppLocalizations.of(context)!.thisContentIsNotDownloadedYet),
                    ),
            ),
            InkWell(
              child: Icon(
                _topicsPref.isEmpty || _selectedTopicsList.length < 3 ? Icons.close : Icons.done,
                color: _topicsPref.isEmpty || _selectedTopicsList.length < 3 ? Colors.blueGrey : Colors.green,
                size: 40,
              ),
              onTap: () => Navigator.of(context).pop(true),
            )
          ],
        ),
      ),
    );
  }

  List<Topic> allTopicList = [];

  ///Initialize all Topics for local manipulation. Store all to allTopicList/_topicPref
  ///And store selected to _selectedTopicsList. Selected list will check and sync locally everytime user
  ///changes their choice
  _initAllTopics() {
    if (Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal) != null) {
      debugPrint("------ Decoding.... ${Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal)}");
      Iterable iterable = json.decode(Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal)!);
      allTopicList = List<Topic>.from(iterable.map((model) => Topic.fromJson(model)));
      String? companyCategory = Globals.prefs!.getString(Constants.CompanyCategory);

      for (var element in allTopicList) {
        var data = element.name!.split("~");
        TopicTemplate cellTemplate = TopicTemplate(data[0], _getTopicGridCell(element));
        if (element.isActive!) {
          var contain = _topicsPref.where((element) => element.preference == cellTemplate.preference);

          ///Do not include a topic that is with the same category as the company. (Conflict of interest)
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
            _selectedTopicsList.remove(cellTemplate);
          }
        }
        debugPrint("------ Name: ${data[1]} SyncStatus: ${element.syncStatus!.index}");
      }
    }
  }

  ///Structure and decorate each topic selection in the grid.
  _getTopicGridCell(Topic element) {
    if (!element.name!.contains("~")) return;
    var data = element.name!.split("~");
    Widget container = Container(
      child: Column(
        children: [
          Expanded(
            child: Container(
              child: data[1].isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: data[1],
                      height: 50,
                      width: 50,
                      // fit: BoxFit.contain,
                      placeholder: (context, url) => ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 50),
                        child: Container(
                          child: const Center(child: Text("...")),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                    )
                  : Container(),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              data[0],
            ),
          )
        ],
      ),
    );
    return container;
  }

  ///Maintain user topic interest everytime user select or unselect a topic
  ///These choices will then sync on app restarts if there is a connection
  ///where status 1 and 3 will only sync as follow/unfollow status on the cloud
  ///and update local topics to 2 and 0 respectively
  _resetUserSelectionLocally(TopicTemplate subscriptionTopic) {
    for (var element in allTopicList) {
      var data = element.name!.split("~");
      debugPrint("------ Element name: ${data[0]}");
      if (data[0] == subscriptionTopic.preference) {
        if (element.syncStatus == TopicSyncStatusOption.created) {
          element.syncStatus = TopicSyncStatusOption.selected;
          _selectedTopicsList.add(subscriptionTopic);
          debugPrint("------ 1: ${subscriptionTopic.preference}");
          FcmHandler.subscribeUserToTopic(subscriptionTopic.preference);
        } else if (element.syncStatus == TopicSyncStatusOption.selected) {
          _selectedTopicsList.remove(subscriptionTopic);
          element.syncStatus = TopicSyncStatusOption.created;
          debugPrint("------ 2: ");
          FcmHandler.unSubscribeUserFromTopic(subscriptionTopic.preference);
        } else if (element.syncStatus == TopicSyncStatusOption.followed) {
          _selectedTopicsList.remove(subscriptionTopic);
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
