// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/firebase/firestore/firestore.dart';
import 'package:event_calendar_v2/shared/enums.dart';
import 'package:flutter/material.dart';

class CompanyContentModel {
  CompanyContentModel(
      {this.id,
      this.title,
      this.body,
      this.category,
      this.company,
      this.ageRestriction,
      this.logoUrl,
      this.imageUrl,
      this.webUrl,
      this.videoUrl,
      this.frD,
      this.toD,
      this.markOnCalendar,
      this.markDate,
      this.topic,
      this.source,
      this.tagColor,
      this.companyName,
      this.status}) {
    _fireStore = CloudFireStore();
  }

  String? id;
  String? title;
  String? body;
  String? category;
  String? company;
  String? ageRestriction;
  String? logoUrl;
  String? imageUrl;
  String? webUrl;
  String? videoUrl;

  String? frD;
  String? toD;
  bool? markOnCalendar;
  String? markDate;
  String? topic;
  String? source;
  String? tagColor;
  String? companyName;
  int? status;

  late CloudFireStore _fireStore;
  static const String ROOT_COLLECTION = "Companies";
  static const String CONTENT_COLLECTION = "Contents";

  Future<List<CompanyContentModel>> getCompanyContents(String company) async {
    List<QueryDocumentSnapshot> snapShotList = await _fireStore.getNestedRecords(
      ROOT_COLLECTION,
      company,
      CONTENT_COLLECTION,
    );
    debugPrint("------ Company Content List: $company");
    List<CompanyContentModel> list = toModelList(snapShotList);
    return list;
  }

  void cacheUserRelatedContents(String company, var topics) async {
    _fireStore.cacheGroupedRecords("Contents", topics);
  }

  Future<List<CompanyContentModel>> getUserRelatedContents(String? company, var topics) async {
    List<QueryDocumentSnapshot> snapShotList = await _fireStore.getGroupedRecords("Contents", topics);
    debugPrint("------- Get User Related Contents of: $company");
    debugPrint("------- Get User Related Content Topics: $topics");

    List<CompanyContentModel> list = toModelList(snapShotList);

    List<CompanyContentModel> listActive = [];
    for (var element in list) {
      if (element.status == RecordStatus.Published.index) {
        String? deletedIds = Globals.prefs!.getString(Constants.DeletedContentsId);
        debugPrint("------ Deleted Item IDs: $deletedIds");
        if (deletedIds == null) {
          listActive.add(element);
        } else {
          if (deletedIds.contains(element.id!) == false) listActive.add(element);
        }
      }
    }
    debugPrint("------ Active records Length: ${list.length}");
    return listActive;
  }

  Future<List<CompanyContentModel>> getCompanyNationalDaysArticle(var company, var nationalDay) async {
    List<QuerySnapshot?> snapShotList = await _fireStore.getCompanyNationalDayArticleRecords(
        "Companies", company, "Contents", "nationalDay", nationalDay);
    debugPrint("------ Get Company National Days of: $company");
    debugPrint("------ Company National Day Article Report: $nationalDay");

    List<CompanyContentModel> list = toModelList(snapShotList.first!.docs);
    list.addAll(toModelList(snapShotList.last!.docs));
    return list;
  }

  List<CompanyContentModel> toModelList(List<QueryDocumentSnapshot> snapShotList) {
    List<CompanyContentModel> list = List.empty(growable: true);
    try {
      for (var doc in snapShotList) {
        DateTime frD = (doc['frD'] as Timestamp).toDate();
        DateTime toD = (doc['toD'] as Timestamp).toDate();
        debugPrint("------ Company To-Model-List Title: ${doc["title"]}: wUrl: ${doc["wUrl"]}");
        list.add(CompanyContentModel(
            id: doc["id"],
            title: doc["title"],
            body: doc["body"],
            logoUrl: doc["logoUrl"],
            imageUrl: doc["iUrl"],
            webUrl: doc["wUrl"],
            companyName: doc["companyName"],
            frD: frD.toString(),
            toD: toD.toString(),
            topic: doc["topic"],
            status: doc["st"]));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return list;
  }
}
