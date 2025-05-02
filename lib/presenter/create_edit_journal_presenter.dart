import 'package:intl/intl.dart';
import 'package:special_characters/model/journal_model.dart';

class CreateEditJournalPresenter {
  final JournalFirebaseService _journalService = JournalFirebaseService();

  Future<void> addEntry(String title, String text) async {
    final String currentDate =
        DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now());
    JournalEntry newEntry = JournalEntry(
        id: "", entryName: title, entryDate: currentDate, entryText: text);
    await _journalService.addJournalEntry(newEntry);
  }

  Future<void> editEntry(JournalEntry entry, String newText) async {
    final String currentDate =
        DateFormat('MM/dd/yyyy HH:mm:ss').format(DateTime.now());
    JournalEntry editedEntry = JournalEntry(
        id: entry.id,
        entryName: entry.entryName,
        entryDate: currentDate,
        entryText: newText);
    await _journalService.editJournalEntry(editedEntry);
  }

  Future<void> deleteEntry(entryId) async {
    await _journalService.deleteJournalEntry(entryId);
  }
}
