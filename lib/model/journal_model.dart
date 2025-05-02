import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

//stores firebase entries.
class JournalEntry implements Comparable<JournalEntry> {
  final String id;
  String entryName;
  String entryDate;
  String entryText;

  JournalEntry(
      {required this.id,
      required this.entryName,
      required this.entryDate,
      required this.entryText});

  //conversion to firestore Map
  Map<String, dynamic> toMap() {
    return {
      'entryName': entryName,
      'entryDate': entryDate,
      'entryText': entryText,
    };
  }

  //conversion from firestore map to journalEntry
  factory JournalEntry.fromMap(String id, Map<String, dynamic> data) {
    return JournalEntry(
      id: id,
      entryName: data['entryName'] ??
          '', //use empty string as default if entryname null
      entryDate: data['entryDate'] ?? '',
      entryText: data['entryText'] ?? '',
    );
  }

  //Comparing for sorting entries by last edit date
  @override
  int compareTo(JournalEntry other) {
    final String dateFormat = 'MM/dd/yyyy HH:mm:ss';
    if (DateFormat(dateFormat)
        .parse(entryDate)
        .isBefore(DateFormat(dateFormat).parse(other.entryDate))) {
      return 1;
    } else if (DateFormat(dateFormat)
        .parse(entryDate)
        .isAfter(DateFormat(dateFormat).parse(other.entryDate))) {
      return -1;
    } else {
      return 0;
    }
  }
}

class JournalFirebaseService {
  //accesses JournalEntries collection on firestore
  final CollectionReference journalCollection =
      FirebaseFirestore.instance.collection('journal');
  //retrieve journal entries (Future to wait for journal entires to come in from database:
  Future<List<JournalEntry>> getJournalEntries() async {
    //returns list of documentsnapshot objects within journalEntry collection
    QuerySnapshot snapshot = await journalCollection.get();
    //creates iterable of journal entry objects:
    return snapshot.docs
        .map((doc) =>
            JournalEntry.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addJournalEntry(JournalEntry entry) async {
    await journalCollection.add(entry.toMap());
  }

  Future<void> editJournalEntry(JournalEntry entry) async {
    await journalCollection.doc(entry.id).update(entry.toMap());
  }

  Future<void> deleteJournalEntry(String entryId) async {
    await journalCollection.doc(entryId).delete();
  }
}
