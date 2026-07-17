// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/firebase/firestore/firestore.dart';
import 'package:event_calendar_v2/services/notifications/notification_service.dart';
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

  Future<CompanyContentModel?> getCompanyContentById(String company, String id) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(ROOT_COLLECTION)
          .doc(company)
          .collection(CONTENT_COLLECTION)
          .where('id', isEqualTo: id)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      final list = toModelList(snap.docs);
      return list.isEmpty ? null : list.first;
    } catch (_) {
      return null;
    }
  }

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

  Future<List<CompanyContentModel>> getUserRelatedContents(String? company, var topics, {bool forceRefresh = false}) async {
    if (forceRefresh) {
      await _fireStore.syncGroupedRecordsFromServer("Contents", topics);
    }
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

    // Keep calendar marks in sync with the published state of content:
    // published + markOnCalendar + future markDate -> ensure a mark exists;
    // unpublished / unmarked / past -> cancel any lingering mark. Uses the full
    // list (all statuses), not just the published subset, so decisions are made
    // per-document rather than by absence. Fire-and-forget; self-guarded.
    reconcileCalendarMarks(list);

    return listActive;
  }

  /// Reconciles scheduled calendar-mark notifications against content state.
  /// Both the FCM path and this method key marks off [NotificationService.calendarMarkId],
  /// so they converge on the same entry (no duplicates). Only cancels marks that
  /// belong to content (never user tasks / national days).
  Future<void> reconcileCalendarMarks(List<CompanyContentModel> all) async {
    try {
      final NotificationService service = NotificationService();
      final pending = await service.getAllNotificationsList();
      final DateTime now = DateTime.now();

      for (final c in all) {
        if (c.id == null) continue;
        final int notifId = NotificationService.calendarMarkId(c.id);
        final DateTime? markDate = c.markDate == null ? null : DateTime.tryParse(c.markDate!);
        final bool published = c.status == RecordStatus.Published.index;
        final bool shouldMark =
            published && c.markOnCalendar == true && markDate != null && markDate.isAfter(now);

        if (shouldMark) {
          await service.scheduleCalendarMark(
            id: c.id!,
            markDate: markDate,
            title: c.title,
            body: c.body,
            tagColor: c.tagColor,
            ageRestriction: c.ageRestriction,
            topic: c.topic,
            icon: c.logoUrl,
          );
        } else {
          final bool hasManagedMark = pending.any((p) =>
              p.id == notifId &&
              (p.contentSource == ContentSource.CompanyEvent ||
                  p.contentSource == ContentSource.TopicEvent ||
                  p.contentSource == ContentSource.GeneralEvent));
          if (hasManagedMark) await service.cancelNotification(notifId);
        }
      }
    } catch (e) {
      debugPrint("------ Calendar mark reconciliation error: $e");
    }
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
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime frD = (doc['frD'] as Timestamp).toDate();
        DateTime toD = (doc['toD'] as Timestamp).toDate();
        // markDate/markOnCalendar may be absent on older content docs, so read them null-safely.
        final markDateField = data['markDate'];
        final String? markDate = markDateField is Timestamp ? markDateField.toDate().toString() : null;
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
            status: doc["st"],
            markOnCalendar: data['markOnCalendar'] == true,
            markDate: markDate,
            tagColor: data['tagColor'] as String?,
            ageRestriction: data['ageRestriction']?.toString(),
            source: data['source'] as String?,
            category: data['category'] as String?));
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return list;
  }
}
