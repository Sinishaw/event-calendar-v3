import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/firebase/cloudMessaging/FcmHandler.dart';
import 'package:event_calendar_v2/firebase/firestore/firestore.dart';
import 'package:event_calendar_v2/firebase/remoteConfig/firebase_remote_config.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Topic {
  Topic({this.name, this.isActive, this.syncStatus});

  String? name;
  bool? isActive;
  TopicSyncStatusOption? syncStatus;

  Topic.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        isActive = json["isActive"],
        syncStatus = TopicSyncStatusOption.values[json['syncStatus']];

  Map<String, dynamic> toJson() => {
        'name': name,
        'isActive': isActive,
        'syncStatus': syncStatus!.index,
      };

  ///Initializes TopicsUserSubscribedLocal from TopicsUserSubscribed if it exists,
  ///If TopicsUserSubscribed does not exist, then loads it from RC and initialize.
  ///Mainly loads on first time use.
  static initializeLocalTopics() {
    String? localTopics = Globals.prefs!.getString(Constants.TopicsUserSubscribed);

    if (localTopics != null) {
      if (Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal) == null) {
        List<Topic> modelTopicList = [];
        Map<String, dynamic> topicsJson = jsonDecode(localTopics);
        topicsJson.forEach((key, value) {
          modelTopicList.add(Topic(name: value, syncStatus: TopicSyncStatusOption.created, isActive: true));
        });
        String jsonTopicsLocal = jsonEncode(modelTopicList);

        Globals.prefs!.setString(Constants.TopicsUserSubscribedLocal, jsonTopicsLocal);
        debugPrint("*********************TOPICS LOCALLY REGISTERED************************");
        debugPrint(Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal));
      }
    } else {
      FirebaseRC().getRemoteConfig(Constants.TopicsForSubscription).then((value) {
        if (value.isNotEmpty) {
          Globals.prefs!.setString(Constants.TopicsUserSubscribed, value);
          debugPrint("Initialized remote topics successfully.");
          debugPrint(value);

          ///Reset if only connection is available
          initializeLocalTopics();
        }
      }).onError((dynamic error, stackTrace) {
        debugPrint("Something went wrong");
        debugPrint(error);
      });
    }
  }

  static refreshLocalTopicsFromRemoteConfig() {
    ///TODO: Pick remote config periodically and avoid calling it everytime the user wants to change topics
    FirebaseRC().getRemoteConfig(Constants.TopicsForSubscription).then((value) {
      List<Topic> oldTopicList = [];
      if (Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal) != null) {
        ///Load existing topics with user preference added
        Iterable iterable = json.decode(Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal)!);
        oldTopicList = List<Topic>.from(iterable.map((model) => Topic.fromJson(model)), growable: true);

        ///Load a new remote config in case there are addition or removal
        if (value.isNotEmpty) {
          Map<String, dynamic> topicsJson = jsonDecode(value);
          List<Topic> newList = [];
          bool isRemoved = false;
          bool isAdded = false;

          ///Check new additions
          topicsJson.forEach((key, newTopicName) {
            if (oldTopicList.any((oldTopic) => oldTopic.name == newTopicName) == false) {
              newList.add(Topic(name: newTopicName, syncStatus: TopicSyncStatusOption.created, isActive: true));
              debugPrint("ADDED TOPICS: $newTopicName");
              isAdded = true;
            }
          });

          ///Check removals
          for (var element in oldTopicList) {
            var data = element.name!.split("~");

            if (topicsJson.containsKey(data[0]) == false) {
              debugPrint("REMOVED TOPICS: ${data[0]}");
              isRemoved = true;
            } else {
              newList.add(element);
            }
          }
          if (isAdded || isRemoved) {
            String jsonTopicsLocalNew = jsonEncode(newList);
            Globals.prefs!.setString(Constants.TopicsUserSubscribedLocal, jsonTopicsLocalNew);
            debugPrint(Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal));
          }
        }
      }
    });
  }

  static syncUserWithLatestTopics() async {
    List<Topic> currentTopicList = [];
    if (Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal) != null) {
      Iterable iterable = json.decode(Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal)!);
      currentTopicList = List<Topic>.from(iterable.map((model) => Topic.fromJson(model)));
      debugPrint(Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal));

      String tokenNoneNull = "";

      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        tokenNoneNull = token;
      } else {
        return;
      }
      var tokens = tokenNoneNull.split(":");
      debugPrint("Attempting following new user preference topics..............");
      FieldValue timestamp = FieldValue.serverTimestamp();
      for (var element in currentTopicList) {
        var data = element.name!.split("~");
        if (element.syncStatus == TopicSyncStatusOption.selected) {
          FirebaseFirestore.instance
              .collection("Topics")
              .doc(data[0])
              .collection("Users")
              .doc(tokens[0])
              .set({"id": tokens[0], "token": token, "createdTimestamp": timestamp}).then((value) {
            debugPrint("------ User is now following: ${data[0]} .................");
            element.syncStatus = TopicSyncStatusOption.followed;
            String updatedLocalTopics = jsonEncode(currentTopicList);
            Globals.prefs!.setString(Constants.TopicsUserSubscribedLocal, updatedLocalTopics);
            debugPrint("------ Subscribing to Topic: ${data[0]}");
            FcmHandler.subscribeUserToTopic(data[0]);

            ///TODO: If multiple user try to update, then the number will significantly wrong
            ///Find better implementation!
            debugPrint("------ Increasing Subscription Count by one ...");
            CloudFireStore().registerTopicCount(topic: data[0], increaseBy: 1);
          }).onError((dynamic error, stackTrace) {
            ///TODO: Catch the error appropriately
          });
          debugPrint(
              "------ Topic Name & Status : ${data[0]} ${TopicSyncStatusOption.values[element.syncStatus!.index]}");
        } else if (element.syncStatus == TopicSyncStatusOption.removed) {
          FirebaseFirestore.instance
              .collection("Topics")
              .doc(data[0])
              .collection("Users")
              .doc(tokens[0])
              .delete()
              .then((value) {
            debugPrint("------ User is now deleted from ${data[0]} .................");
            element.syncStatus = TopicSyncStatusOption.created;
            String updatedLocalTopics = jsonEncode(currentTopicList);
            Globals.prefs!.setString(Constants.TopicsUserSubscribedLocal, updatedLocalTopics);
            FcmHandler.unSubscribeUserFromTopic(data[0]);
            debugPrint("------ Decreasing Subscription by 1 ...");
            CloudFireStore().registerTopicCount(topic: data[0], increaseBy: -1);
          }).onError((dynamic error, stackTrace) {
            ///TODO: Catch the error appropriately
          });
          debugPrint(
              "------ Topic Name & Status : ${data[0]} ${TopicSyncStatusOption.values[element.syncStatus!.index]}");
        }
      }
    }
  }

  ///Gets and return topics that are followed on server / Synced from local subscription to server
  static getUserSubscribedTopics() {
    try {
      debugPrint(Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal));
      Iterable iterable = json.decode(Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal)!);
      List<Topic> allTopicList = List<Topic>.from(iterable
          .map((model) => Topic.fromJson(model))
          .where((element) => element.syncStatus == TopicSyncStatusOption.followed));

      ///TODO: Based on company subscription, add public topic subscription to all users
      // if(CompanySubscription!=Premium){
      //   Add public subscription
      // }
      allTopicList.add(Topic(name: "public", isActive: true, syncStatus: TopicSyncStatusOption.followed));
      return allTopicList;
    } catch (e) {
      return List<Topic>.generate(
          0, (index) => Topic(name: "public", isActive: true, syncStatus: TopicSyncStatusOption.followed));
    }
  }

  static getUserSubscribedTopicsInCSV() {
    try {
      String? localTopics = Globals.prefs!.getString(Constants.TopicsUserSubscribedLocal);
      if (localTopics == null) return;
      Iterable iterable = json.decode(localTopics);
      List<Topic> allTopicList = List<Topic>.from(iterable.map((model) => Topic.fromJson(model)).where((element) =>
          element.syncStatus == TopicSyncStatusOption.followed ||
          element.syncStatus == TopicSyncStatusOption.selected));
      String csvTopics = "";
      for (int i = 0; i < allTopicList.length; i++) {
        var data = allTopicList[i].name!.split("~");

        if (i < allTopicList.length - 1) {
          csvTopics += "${data[0]},";
        } else {
          csvTopics += data[0];
        }
      }
      return csvTopics;
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
