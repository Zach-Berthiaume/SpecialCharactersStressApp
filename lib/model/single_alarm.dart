import 'package:alarm/alarm.dart';
import 'package:alarm/model/volume_settings.dart';

class SingleAlarm {
  DateTime _alarmTime = DateTime.now();
  String _title = "";
  String _alarmSoundPath = "/assets/audio/alarmPage.mp3";
  bool _turnedOn = false;
  late int _id;

  SingleAlarm(DateTime givenTime, String givenTitle, String givenPath, int givenId) {
    _alarmTime = givenTime;
    _title = givenTitle;
    _alarmSoundPath = givenPath;
    _id = givenId;
  }

  SingleAlarm.noPath(DateTime givenTime, String givenTitle, int givenId) {
    _alarmTime = givenTime;
    _title = givenTitle;
    _id = givenId;
  }

  SingleAlarm.noStrings(DateTime givenTime, int givenId) {
    _alarmTime = givenTime;
    _id = givenId;
  }

  void alarmSwitch() async{
    if (_turnedOn == false) {
      _turnedOn = true;
      await Alarm.set(alarmSettings: AlarmSettings(
        id: id, 
        dateTime: soundOffTime(), 
        assetAudioPath: alarmSoundPath, 
        volumeSettings: VolumeSettings.fixed(
          volume: 1.0,
        ),
        notificationSettings: NotificationSettings(title: _title, body: 'Wake up, dumdum', stopButton: 'Stop Alarm'),
      ));
    } else {
      _turnedOn = false;
      await Alarm.stop(id);
    }
  }

  String cleanTime() {
    int hour = _alarmTime.hour;
    int minute = _alarmTime.minute;
    String hourString = hour.toString();
    String minuteString = minute.toString();
    if (minuteString.length == 1) {
      // ignore: prefer_interpolation_to_compose_strings
      minuteString = '0' + minuteString;
    }

    if (hour == 0) {
      hourString = (hour+12).toString();
      // ignore: prefer_interpolation_to_compose_strings
      return hourString + ':' + minuteString + ' AM';
    }
    else if (hour < 12 && hour > 0) {
      // ignore: prefer_interpolation_to_compose_strings
      return hourString + ':' + minuteString + ' AM';
    }
    else if (hour == 12) {
      // ignore: prefer_interpolation_to_compose_strings
      return hourString + ':' + minuteString + ' PM';
    }
    else{
      hourString = (hour-12).toString();
      // ignore: prefer_interpolation_to_compose_strings
      return hourString + ':' + minuteString + ' PM';
    }
    

  }

  bool laterToday() {
    if (alarmTimeInMinutes() > currentTimeInMinutes()) {
      return true;
    }else {
      return false;
    }
  }

  DateTime soundOffTime() {
    if(laterToday() == true) {
      return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, alarmTime.hour, alarmTime.minute);
    } else{
      return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day+1, alarmTime.hour, alarmTime.minute);
    }
  }

  int alarmTimeInMinutes() {
    return (_alarmTime.hour*60) + (_alarmTime.minute);
  }

  int currentTimeInMinutes(){
    return (DateTime.now().hour*60) + (DateTime.now().minute);
  }

  // ignore: unnecessary_getters_setters
  DateTime get alarmTime{return _alarmTime;}
  // ignore: unnecessary_getters_setters
  String get title{return _title;}
  // ignore: unnecessary_getters_setters
  String get alarmSoundPath{return _alarmSoundPath;}
  // ignore: unnecessary_getters_setters
  int get id{return _id;}
  bool get turnedOn{return _turnedOn;}

  set alarmTime(DateTime givenTime){_alarmTime = givenTime;}
  set title(String givenTitle){_title = givenTitle;}
  set alarmSoundPath(String givenPath){_alarmSoundPath = givenPath;}
  set id(int givenId){_id = givenId;}
}