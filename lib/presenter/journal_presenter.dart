import 'package:special_characters/model/journal_model.dart';

abstract class JournalView {
  void showJournalEntries(List<JournalEntry> entries);
  void showError(String message);
}

class JournalPresenter {
  final JournalView view;
  final JournalFirebaseService _journalService = JournalFirebaseService();

  JournalPresenter(this.view);

  void loadJournalEntries() async {
    try {
      List<JournalEntry> entries = await _journalService.getJournalEntries();
      view.showJournalEntries(entries);
    } catch (e) {
      view.showError("Failed to load journal entries");
    }
  }

  Future<void> deleteJournalEntry(String entryId) async {
    await _journalService.deleteJournalEntry(entryId);
    loadJournalEntries(); //refresh page to show deleted entry is gone
  }
}
