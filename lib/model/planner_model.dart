import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class EventIconData {
  //map holding all available icons to be chosen from for events
  static Map<String, IconData> iconMap = {
    'circle_outlined': Icons.circle_outlined,
    'access_alarm': Icons.access_alarm,
    'ac_unit': Icons.ac_unit,
    'account_balance': Icons.account_balance,
    'add_location': Icons.add_location,
    'air_outlined': Icons.air_outlined,
    'airplanemode_active': Icons.airplanemode_active,
    'bed': Icons.bed,
    'local_bar': Icons.local_bar,
    'add' : Icons.add,
    'add_call' : Icons.add_call,
    'directions_boat' : Icons.directions_boat,
    'snowshoeing' : Icons.snowshoeing,
    'sports_baseball_rounded' : Icons.sports_baseball_rounded,
    'skateboarding' : Icons.skateboarding,
    'shopping_bag_outlined' : Icons.shopping_bag_outlined,
  };

  static IconData getIconFromString(String iconName) {
    IconData iconData = iconMap[iconName] ?? Icons.question_mark;
    return iconData;
  }

  static List<String> iconStringList = iconMap.keys.toList();
}


class PlannerEntryEvent implements Comparable<PlannerEntryEvent>{
  String id;
  String icon;
  String name;
  String time;

  PlannerEntryEvent({required this.id, required this.icon, required this.name, required this.time});

  //conversion to firestore Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'icon': icon,
      'name': name,
      'time': time,
    };
  }

  factory PlannerEntryEvent.fromMap(String id, Map<String, dynamic> data) {
    return PlannerEntryEvent(
      id: id,
      icon: data['icon'] ?? '',
      name: data['name'] ?? '',
      time: data['time'] ?? '',
      //use empty string as default (if entry name null)
    );
  }


  @override
  int compareTo(PlannerEntryEvent other) {
    final String dateFormat = 'HH:mm';
    if (DateFormat(dateFormat).parse(time).isBefore(DateFormat(dateFormat).parse(other.time))) {
      return -1;
    } else if (DateFormat(dateFormat).parse(time).isAfter(DateFormat(dateFormat).parse(other.time))) {
      return 1;
    } else {
      return 0;
    }
  }
}

//stores firebase entries.
class PlannerEntry implements Comparable<PlannerEntry>{
  final String id;
  final String date;
  String mood;

  PlannerEntry({required this.id, required this.date, required this.mood});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'mood': mood,
    };
  }
  //conversion from firestore map to plannerEntry
  factory PlannerEntry.fromMap(String id, Map<String, dynamic> data) {
    return PlannerEntry(
      id: id,
      date: data['date'] ?? '',
      mood: data['mood'] ?? '',
    );
  }

  @override
  int compareTo(PlannerEntry other) {
    final String dateFormat = 'HH:mm:ss';
    if (DateFormat(dateFormat).parse(date).isBefore(DateFormat(dateFormat).parse(other.date))) {
      return 1;
    } else if (DateFormat(dateFormat).parse(date).isAfter(DateFormat(dateFormat).parse(other.date))) {
      return -1;
    } else {
      return 0;
    }
  }
}

class PlannerFirebaseService {
  //accesses plannerEntries collection on firestore
  final CollectionReference plannerCollection = FirebaseFirestore.instance
      .collection('dayMoodEvents');

  Future<List<PlannerEntry>> getPlannerEntries() async {
    //returns list of document snapshot objects within plannerEntry collection
    QuerySnapshot snapshot = await plannerCollection.get();
    //creates iterable of planner entry objects:
    return snapshot.docs.map((doc) =>
        PlannerEntry.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addOrEditPlannerEntry(PlannerEntry entry) async {
    try{
      //if entry id doesn't exist, creates and makes entry, if doc exists, updates entry.
      await plannerCollection.doc(entry.id).set(entry.toMap());

    } catch (e) {
      log('failed to create entry: $e');
    }
  }

  //retrieve a specific planner entry instance by it's ID (it's date in yyyy-MM-dd format)
  Future<PlannerEntry> getPlannerEntry(String entryID) async {
    DocumentSnapshot snapshot = await plannerCollection.doc(entryID).get();

    //if no existing instance for the date:
    if (snapshot.exists == false){
      DateTime date = DateFormat('yyyy-MM-dd').parse(entryID);
      String formattedDate = DateFormat('MM/dd/yyyy').format(date);

      return PlannerEntry(id: entryID, date: formattedDate, mood: "Set Mood Below!");
    }
    return PlannerEntry.fromMap(snapshot.id, snapshot.data() as Map<String, dynamic>);
  }

  Future<void> deletePlannerEntry(String entryID) async {
    await plannerCollection.doc(entryID).delete();
  }


  Future<List<PlannerEntryEvent>> getPlannerEntryEvents(String entryID) async {
    final CollectionReference plannerEntryEventCollection = plannerCollection.doc(entryID).collection('events');

    QuerySnapshot snapshot = await plannerEntryEventCollection.get();
    return snapshot.docs.map((doc) =>
        PlannerEntryEvent.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addOrEditPlannerEntryEvent(String entryID, PlannerEntryEvent event) async{
    //if firebase entry for given date of entryID does not exist yet, create one
    DocumentSnapshot snapshot = await plannerCollection.doc(entryID).get();
    if (snapshot.exists == false){
      DateTime date = DateFormat('yyyy-MM-dd').parse(entryID);
      String formattedDate = DateFormat('MM/dd/yyyy').format(date);

      PlannerEntry newEntry = PlannerEntry(id: entryID, date: formattedDate, mood: "Set Mood Below!");
      addOrEditPlannerEntry(newEntry);
    }
    await plannerCollection.doc(entryID).collection('events').doc(event.id).set(event.toMap());
  }

  Future<String> generateID() async{
    return FirebaseFirestore.instance.collection('events').doc().id; // Generates a random ID
  }

  Future<void> deletePlannerEntryEvent(String entryID, String eventID) async{
    await plannerCollection.doc(entryID).collection('events').doc(eventID).delete();
  }
}