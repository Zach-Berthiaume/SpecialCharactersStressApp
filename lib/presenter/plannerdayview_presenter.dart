import 'package:special_characters/model/planner_model.dart';

abstract class AbstractPlannerDayView {
  void refreshDayViewData();
  void showDayViewData();
  void showError(String message);
}

class PlannerDayViewPresenter {
  final PlannerFirebaseService _firebaseService = PlannerFirebaseService();
  final AbstractPlannerDayView _view;
  PlannerEntry? _currentPlannerEntry;
  List<PlannerEntryEvent>? _currentPlannerEntryEvents;


  PlannerEntry? get currentPlannerEntry => _currentPlannerEntry;
  List<PlannerEntryEvent>? get currentPlannerEntryEvents => _currentPlannerEntryEvents;


  PlannerDayViewPresenter(this._view);



  void changePlannerEntryMood(String newMood){
    PlannerEntry updatedEntry = PlannerEntry(id: _currentPlannerEntry!.id,
        date: _currentPlannerEntry!.date, mood: newMood);

    addOrEditPlannerEntry(updatedEntry);
    //refresh page
    loadDayViewData(_currentPlannerEntry!.id);
  }

  void addOrEditPlannerEntry(PlannerEntry entry){
    _firebaseService.addOrEditPlannerEntry(entry);
  }

  void loadDayViewData(String selectedDateID) async {
    try{
      _currentPlannerEntry = await _firebaseService.getPlannerEntry(selectedDateID);
      _currentPlannerEntryEvents = await _firebaseService.getPlannerEntryEvents(selectedDateID);
      _currentPlannerEntryEvents?.sort();
    } catch (e) {
      _view.showError("Failed to load dayViewData");
    }

    _view.showDayViewData();
  }

  Future<void> deletePlannerEntryEvent(PlannerEntryEvent event) async{
    await _firebaseService.deletePlannerEntryEvent(_currentPlannerEntry!.id, event.id);
  }
}
