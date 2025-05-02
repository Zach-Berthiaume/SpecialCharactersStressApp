import 'package:special_characters/model/planner_model.dart';

abstract class PlannerView {
  void showPlannerEntries(List<PlannerEntry> entries, Map<String, List<PlannerEntryEvent>> entryEvents);
  void showError(String message);
}

class PlannerPresenter {
  final PlannerView view;
  final PlannerFirebaseService _plannerService = PlannerFirebaseService();

  PlannerPresenter(this.view);

  void loadPlannerEntries() async{
    try {
      List<PlannerEntry> entries = await _plannerService.getPlannerEntries();
      Map<String, List<PlannerEntryEvent>> entryEvents = await loadPlannerEntryEvents(entries);

      view.showPlannerEntries(entries, entryEvents);
    } catch (e) {
      view.showError("Failed to load planner entries");
    }
  }

  Future<Map<String,List<PlannerEntryEvent>>> loadPlannerEntryEvents(List<PlannerEntry> entries) async{
    Map<String, List<PlannerEntryEvent>> entryEvents = {};

    for (PlannerEntry entry in entries) {
      entryEvents[entry.id] = await _plannerService.getPlannerEntryEvents(entry.id);
    }

    return entryEvents;
  }



  Future<void> deletePlannerEntry(String entryId) async {
    await _plannerService.deletePlannerEntry(entryId);
    loadPlannerEntries();
  }

}

