// ignore_for_file: unnecessary_string_interpolations

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_calendar_v2/common/constants.dart';
import 'package:event_calendar_v2/common/globals.dart';
import 'package:event_calendar_v2/firebase/cloudMessaging/FcmHandler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class CloudFireStore {
  late FirebaseFirestore firestore;

  CloudFireStore() {
    firestore = FirebaseFirestore.instance;
  }

  Future<List<QueryDocumentSnapshot>> getAllRecords(String collection) async {
    CollectionReference ref = firestore.collection(collection);
    QuerySnapshot querySnapShot = await ref.get();
    return querySnapShot.docs;
  }

  ///Cache first approach. Update latest server documents based on last retrieve timestamp to local cache
  Future<List<QueryDocumentSnapshot>> getGroupedRecords(String collection, var filterArray) async {
    debugPrint("------ Firestore Collection: $collection");
    debugPrint("------ Firestore Filter Array: $filterArray");
    var cacheOption = const GetOptions(source: Source.cache);
    var querySnapshotCache = await firestore
        .collectionGroup(collection)
        .where('topic', whereIn: filterArray)
        .where('nationalDay', isEqualTo: "")
        .get(cacheOption);

    return querySnapshotCache.docs;
  }

  ///Cache first approach.
  void cacheGroupedRecords(String collection, var filterArray) async {
    debugPrint("------ Firestore Collection $collection");
    debugPrint("------ Firestore Filter Array: $filterArray");
    var cacheOption = const GetOptions(source: Source.cache);
    var serverOption = const GetOptions(source: Source.server);

    DateTime now = DateTime.now();
    DateTime lastContentUpdatedTimestamp;
    String? localSavedTimestamp = Globals.prefs!.getString(Constants.ContentLastUpdatedTimeStamp);

    if (localSavedTimestamp == null) {
      lastContentUpdatedTimestamp = now.subtract(const Duration(days: 15));
    } else {
      try {
        lastContentUpdatedTimestamp = DateTime.parse(localSavedTimestamp);
      } catch (e) {
        lastContentUpdatedTimestamp = now.subtract(const Duration(days: 15));
      }
    }

    var querySnapshotCache = await firestore
        .collectionGroup(collection)
        .where('topic', whereIn: filterArray)
        .where('nationalDay', isEqualTo: "")
        .get(cacheOption);

    if (localSavedTimestamp == null) {
      firestore
          .collectionGroup(collection)
          .where('topic', whereIn: filterArray)
          .where('nationalDay', isEqualTo: "")
          .where('fetchExpirationDate', isGreaterThanOrEqualTo: now)
          .get(serverOption)
          .then((value) {
        debugPrint("------ Firestore Length of updated documents: ${value.docs.length}");
        for (var element in value.docs) {
          querySnapshotCache.docs.add(element);
        }
        if (value.docs.isNotEmpty) Globals.prefs!.setString(Constants.ContentLastUpdatedTimeStamp, now.toString());
      });
    } else {
      firestore
          .collectionGroup(collection)
          .where('topic', whereIn: filterArray)
          .where('nationalDay', isEqualTo: "")
          .where('ud', isGreaterThanOrEqualTo: lastContentUpdatedTimestamp)
          .get(serverOption)
          .then((value) {
        debugPrint("------ Firestore Length of updated documents: ${value.docs.length}");
        for (var element in value.docs) {
          querySnapshotCache.docs.add(element);
        }
        if (value.docs.isNotEmpty) Globals.prefs!.setString(Constants.ContentLastUpdatedTimeStamp, now.toString());
      });
    }
  }

  Future<List<QueryDocumentSnapshot>> getNestedRecords(String root, String doc, String col) async {
    CollectionReference ref = firestore.collection(root).doc(doc).collection(col);
    QuerySnapshot querySnapShot = await ref.get();
    return querySnapShot.docs;
  }

  Future<List<QueryDocumentSnapshot>> getNationalDayArticleRecords(
      var company, String collection, var nationalDay) async {
    var querySnapshot = await firestore
        .collectionGroup(collection)
        .where('nationalDay', whereIn: nationalDay) /*.where('topic', whereIn: company)*/
        .get();

    return querySnapshot.docs;
  }

  Future<List<QuerySnapshot?>> getCompanyNationalDayArticleRecords(
      String root, String? doc, String col, String filterParam, String? key) async {
    List<QuerySnapshot?> qs = List.generate(0, (index) => null, growable: true);

    CollectionReference ref = firestore.collection(root).doc(doc).collection(col);
    QuerySnapshot querySnapShot = await ref.where("$filterParam", isEqualTo: "$key").get();

    qs.add(querySnapShot);

    ///TODO: Add public content if subscribed company is not premium
    CollectionReference publicContentRef = firestore.collection("Topics").doc("public").collection("Contents");
    QuerySnapshot querySnapShotPublic =
        await publicContentRef.where("$filterParam", isEqualTo: "$key") /*.where("st", isEqualTo: 1)*/ .get();
    qs.add(querySnapShotPublic);
    return qs;
  }

  Future<void> addUser(String token) async {
    List<String> x = token.split(":");
    firestore.collection("Users").add({
      "id": x[0],
      "token": x[1],
    }).then((value) => debugPrint("------ Firestore User Added"));
  }

  registerCompanyCount({String? company, int increaseBy = 0}) async {
    DocumentReference? doc;
    if (company == null) {
      doc = FirebaseFirestore.instance.collection('MetaData').doc("Installation");
    } else {
      doc = FirebaseFirestore.instance.collection('Companies').doc(company).collection("MetaData").doc("Installation");
    }

    doc.get().then((value) {
      FieldValue timestamp = FieldValue.serverTimestamp();
      int count;
      Map<String, dynamic> data;
      if (value.exists) {
        data = value.data() as Map<String, dynamic>;
        count = data['count'] + increaseBy;
        if (count < 0) count = 0;
      } else {
        count = 1;
      }
      doc!.set({"count": count, "createdTimestamp": timestamp}).then((value) {
        debugPrint("------ Firestore Successfully Register Company Count");
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
      });
    });
  }

  registerTopicCount({String? topic, int increaseBy = 0}) async {
    DocumentReference doc =
        FirebaseFirestore.instance.collection('Topics').doc(topic).collection("MetaData").doc("Subscription");
    doc.get().then((value) {
      FieldValue timestamp = FieldValue.serverTimestamp();
      int count;
      Map<String, dynamic> data;
      if (value.exists) {
        data = value.data() as Map<String, dynamic>;
        count = data['count'] + increaseBy;
        if (count < 0) count = 0;
      } else {
        count = increaseBy == 1 ? 1 : 0;
      }

      doc.set({"count": count, "lastUpdated": timestamp}).then((value) {
        debugPrint("------ Firestore Successfully Register Topic Count $count");
      }).onError((error, stackTrace) {
        debugPrint(error.toString());
      });
    });
  }

  ///Register user
  Future<void> registerUserIdInFirestore() async {
    String? token = Globals.prefs!.getString("fcm_token");
    FieldValue timestamp = FieldValue.serverTimestamp();
    if (token == null) {
      FirebaseMessaging.instance.getToken().timeout(const Duration(seconds: 5)).then((value) {
        var arr = value!.split(":");
        FirebaseFirestore.instance
            .collection("Users")
            .doc(arr[0])
            .set({"id": arr[0], "token": value, "createdTimestamp": timestamp}).then((value_) {
          debugPrint("------ User is created in firestore");
          Globals.prefs!.setString("fcm_token", value);
          debugPrint("------ fcm_token value: ${Globals.prefs!.getString("fcm_token")}");
          debugPrint("------ fcm_token SP: ${Globals.prefs!.getString("fcm_token")}");

          ///All users can be reached with this subscription topic channel for update notice and other messages
          FcmHandler.subscribeUserToTopic(Constants.PublicSubscriptionTopic);
          CloudFireStore().registerCompanyCount(increaseBy: 1);
        });
        return;
      });
    }
  }
}
