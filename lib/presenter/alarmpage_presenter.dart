import 'package:shared_preferences/shared_preferences.dart';
import '../model/alarmpage_model.dart';
import '../model/single_alarm.dart';
import 'package:flutter/material.dart';


class AlarmPresenter {

  static AlarmpageModel model = AlarmpageModel();

  static List<SingleAlarm> presenterAlarms = [];
  
  AlarmPresenter();
  
  static void addAlarmTimeOnly(TimeOfDay time) {
    DateTime alarmTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, time.hour, time.minute);
    presenterAlarms.add(SingleAlarm.noStrings(alarmTime, presenterAlarms.length + 1));
    sortAlarmList();
    saveAlarmList();
  }

  static void addAlarmNoPath(TimeOfDay time, String title) {
    DateTime alarmTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, time.hour, time.minute);
    presenterAlarms.add(SingleAlarm.noPath(alarmTime, title, presenterAlarms.length + 1));
    sortAlarmList();
    saveAlarmList();
  }

  static void addAlarmWithIdAndTitle(TimeOfDay time, String title, int id) {
    DateTime alarmTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, time.hour, time.minute);
    presenterAlarms.add(SingleAlarm.noPath(alarmTime, title, id));
    sortAlarmList();
    saveAlarmList();
  }

  static void addAlarmWithIdNoTitle(TimeOfDay time, int id) {
    DateTime alarmTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, time.hour, time.minute);
    presenterAlarms.add(SingleAlarm.noStrings(alarmTime, id));
    sortAlarmList();
    saveAlarmList();
  }

  

  static Future<void> getAlarmList() async{
    presenterAlarms = await loadAlarmList();
  }

  static void editAlarm(int i, TimeOfDay time, String title) {
    presenterAlarms[i].title = title;
    presenterAlarms[i].alarmTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, time.hour, time.minute);
  }

  static final SharedPreferencesAsync storage = SharedPreferencesAsync();

  static Future<List<SingleAlarm>> loadAlarmList() async {
    List<SingleAlarm> localAlarms = [];
    for (int i = 0; i > -1; i++) {
      String enumurator = i.toString();
      int? id = await storage.getInt("id$enumurator");
      int? time = await storage.getInt("time$enumurator");
      String? soundPath = await storage.getString("soundPath$enumurator");
      String? title = await storage.getString("title$enumurator");
      if (id != null && time != null && soundPath != null && title != null) {
        localAlarms.add(SingleAlarm(DateTime.fromMillisecondsSinceEpoch(time), title, soundPath, id));
        continue;
      }else if (id != null && time != null && title != null) {
        localAlarms.add(SingleAlarm.noPath(DateTime.fromMillisecondsSinceEpoch(time), title, id));
        continue;
      }else if (id != null && time != null) {
        localAlarms.add(SingleAlarm.noStrings(DateTime.fromMillisecondsSinceEpoch(time), id));
        continue;
      }
      break;
    }
    return localAlarms;
  }

  static Future<List<SingleAlarm>> updateAlarmListIfNeeded() async{
    if (presenterAlarms.isEmpty) {
      return await loadAlarmList();
    }
    else {
      return presenterAlarms;
    }
  }
  
  static Future<void> saveAlarmList() async {
    List<SingleAlarm> tempAlarmList = presenterAlarms;
    for (int i = 0; i < presenterAlarms.length; i++) {
      String enumurator = i.toString();
      await storage.setInt("id$enumurator", tempAlarmList[i].id);
      await storage.setInt("time$enumurator", tempAlarmList[i].alarmTime.millisecondsSinceEpoch.abs());
      await storage.setString("soundPath$enumurator", tempAlarmList[i].alarmSoundPath);
      await storage.setString("title$enumurator", tempAlarmList[i].title);
    }
  }


  static void sortAlarmList() {
    for (int i = 1; i < presenterAlarms.length; i++){
      SingleAlarm key = presenterAlarms[i];
      int j = i-1;
      while (j >= 0 && presenterAlarms[j].alarmTimeInMinutes() > key.alarmTimeInMinutes()) {
          presenterAlarms[j+1] = presenterAlarms[j];
          j--;
      }
      presenterAlarms[j+1] = key;
    }
  }

}