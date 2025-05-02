import 'package:special_characters/model/planner_model.dart';

abstract class AbstractCreateEditEventPage{
  void updateIcon(String newIconString);
}


class PlannerDayEventViewPresenter{
  final PlannerFirebaseService _firebaseService = PlannerFirebaseService();

  PlannerDayEventViewPresenter();

  Future<void> addOrEditPlannerEntryEvent(String currentPlannerEntryID, String eventID, String name, String time, String icon) async{
    if (eventID == ""){
      eventID = await generateID();
    }
    PlannerEntryEvent newEvent = PlannerEntryEvent(id: eventID, icon: icon, name: name, time: time);
    await _firebaseService.addOrEditPlannerEntryEvent(currentPlannerEntryID, newEvent);

  }
  Future<String> generateID() async {
    return await _firebaseService.generateID();
  }

  Future<void> deletePlannerEntryEvent(String currentPlannerEntryID, PlannerEntryEvent event) async{
    await _firebaseService.deletePlannerEntryEvent(currentPlannerEntryID, event.id);
  }
}