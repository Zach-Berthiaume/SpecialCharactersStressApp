import 'package:flutter/material.dart';
import '../presenter/alarmpage_presenter.dart';
import 'package:provider/provider.dart';
import 'package:special_characters/model/theme.dart';
import '../model/single_alarm.dart';


const Color darkModeBackground = Color.fromARGB(255, 21, 0, 73);
const Color lightModeBackground = Color.fromARGB(255, 0, 235, 255);

class AlarmPage extends StatefulWidget {

  const AlarmPage({super.key});
  @override
  AlarmPageState createState() => AlarmPageState();
}

class AlarmPageState extends State<AlarmPage> {

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? darkModeBackground : lightModeBackground,
      body: Container(
        padding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(30),
            color: isDarkMode ? Colors.grey[900] : Color(0xFFFFF8E1)),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              buildAlarmWidgetsAsync(context),
              SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? darkModeBackground
                          : Color.fromARGB(255, 250, 218, 163),
                      shadowColor: Colors.indigo
                  ),
                  child: Text('New Alarm', style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black)),
                  onPressed:
                      () =>
                      showDialog<String>(
                          context: context,
                          builder:
                              (BuildContext context) =>
                              NewAlarmDialog(refresh: refresh)
                      ),
                ),
              )],
          ),
        ),
      ),
    );
  }

  void refresh() {
    setState(() {
      loadAlarmList();
    });
  }

  void loadAlarmList() async {
    AlarmPresenter.presenterAlarms =
    await AlarmPresenter.updateAlarmListIfNeeded();
  }

  @override
  void initState() {
    super.initState();
    loadAlarmList();
  }

  void toggleAlarm(int i) {
    AlarmPresenter.presenterAlarms.elementAt(i).alarmSwitch();
  }

  FutureBuilder<List<SingleAlarm>> buildAlarmWidgetsAsync(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;

    return FutureBuilder(
        future: AlarmPresenter.updateAlarmListIfNeeded(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty || !snapshot.hasData) {
            return Column(
                children: [
                  Text(
                      "No alarms yet, try creating one!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                      )
                  )
                ]
            );
          }
          else if (snapshot.hasError) {
            return ListView(
                children: [
                  Text(
                      "Error; Unable to fetch alarms",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                      )
                  )
                ]
            );
          }
          else {
            List<SingleAlarm> alarmList = snapshot.data!;
            return Column(
                children: [
                  for (int i = 0; i < alarmList.length; i++) ...[
                    buildAlarmWidget(alarmList[i], context, i),
                    const Divider(thickness: 2,)
                  ]
                ]
            );
          }
        }
    );
  }


  Widget buildAlarmWidget(SingleAlarm alarm, BuildContext context, int i) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              alarm.title,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              alarm.cleanTime(),
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: AlarmSwitch(
              index: i,
              initialAlarmState: alarm.turnedOn,
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: textColor),
            onPressed: () {
              showDialog<String>(
                context: context,
                builder: (BuildContext context) =>
                    EditAlarmDialog(index: i, refresh: refresh),
              );
            },
          ),
        ],
      ),
    );
  }
}

class NewAlarmDialog extends StatefulWidget {
  final Function refresh;
  const NewAlarmDialog({super.key, required this.refresh});

  @override
  State<NewAlarmDialog> createState() => _NewAlarmDialogState();
}

class _NewAlarmDialogState extends State<NewAlarmDialog> {
  
  TimeOfDay? selectedTime;
  String? title;

  void pickTime() async {
    TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.now(),);
    setState(() {
      selectedTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return Dialog(
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 15,),
            TextField(
              obscureText: false,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : Colors.black),
              cursorColor: isDarkMode? Colors.white : Colors.black,
              decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)), hintText: 'Alarm Title', focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: isDarkMode? Colors.white : Colors.black)), hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color:Colors.grey[400])),
              onChanged: (String value) {
                title = value;
              },
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? darkModeBackground : Color.fromARGB(255, 250, 218, 163),
                    shadowColor: Colors.indigo
                ),
                child: Text('Select Time', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : Colors.black),),
                onPressed: () => pickTime()
            ),
            if(selectedTime != null) Text(selectedTime!.format(context), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : Colors.black)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? darkModeBackground : Color.fromARGB(255, 250, 218, 163),
                shadowColor: Colors.indigo
              ),
              onPressed: () {
                if(selectedTime != null && title == null){
                  AlarmPresenter.addAlarmTimeOnly(selectedTime!);
                  widget.refresh();
                  Navigator.pop(context);
                }
                else if(selectedTime != null && title != null) {
                  AlarmPresenter.addAlarmNoPath(selectedTime!, title!);
                  widget.refresh();
                  Navigator.pop(context);
                }},
              child: Text("Set Alarm", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : Colors.black),)
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () async{
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : Colors.black),),
            ),
          ],
        ),
      ),
    );
  }
}

class AlarmSwitch extends StatefulWidget {
  final int index;
  final bool initialAlarmState;

  const AlarmSwitch({super.key, required this.index, required this.initialAlarmState});

  @override
  State<AlarmSwitch> createState() => _AlarmSwitchState();
}

class _AlarmSwitchState extends State<AlarmSwitch> {
  late bool alarmState;

  @override
  void initState() {
    super.initState();
    alarmState = widget.initialAlarmState;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return Switch(
      value: alarmState,
      activeColor: isDarkMode ? Colors.blue[900] : Color.fromARGB(255, 249, 194, 99),
      onChanged: (bool value) {
        setState(() {
          alarmState = value;
        });
        AlarmPresenter.presenterAlarms.elementAt(widget.index).alarmSwitch();
      },
    );
  }
}


class EditAlarmDialog extends StatefulWidget {
  final Function refresh;
  final int index;

  const EditAlarmDialog({super.key, required this.refresh, required this.index});

  @override
  State<EditAlarmDialog> createState() => _EditAlarmDialogState();
}

class _EditAlarmDialogState extends State<EditAlarmDialog> {
  TimeOfDay? selectedTime;
  String? title;
  late int id;

  @override
  void initState() {
    super.initState();
    final alarm = AlarmPresenter.presenterAlarms[widget.index];
    title = alarm.title;
    selectedTime = TimeOfDay.fromDateTime(alarm.alarmTime);
    id = alarm.id;
  }

  void pickTime() async {
    TimeOfDay? time = await showTimePicker(context: context, initialTime: (selectedTime!));
    setState(() {
      selectedTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return Dialog(
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              obscureText: false,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : Colors.black),
              cursorColor: isDarkMode? Colors.white : Colors.black,
              decoration: InputDecoration(border: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)), hintText: 'Alarm Title', focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: isDarkMode? Colors.white : Colors.black)), hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color:Colors.grey[400])),
              onChanged: (String value) {
                title = value;
              },
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? darkModeBackground : lightModeBackground,
                    shadowColor: Colors.indigo),
                child: Text('Select Time', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : Colors.black),),
                onPressed: () => pickTime()
            ),
            if(selectedTime != null) Text(selectedTime!.format(context), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : Colors.black)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? darkModeBackground : lightModeBackground,
                  shadowColor: Colors.indigo
                ),
                onPressed: () {
                  AlarmPresenter.presenterAlarms.removeAt(widget.index);
                  if(selectedTime != null && title == null){
                    AlarmPresenter.addAlarmWithIdNoTitle(selectedTime!, id);
                    widget.refresh();
                    Navigator.pop(context);
                  }
                  else if(selectedTime != null && title != null) {
                    AlarmPresenter.addAlarmWithIdAndTitle(selectedTime!, title!, id);
                    widget.refresh();
                    Navigator.pop(context);
                  }
                  }, 
                child: Text("Confirm Alarm", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : Colors.black),)
              ),
            const SizedBox(height: 15),

            TextButton(
              onPressed: () async{
                Navigator.pop(context);
              },
              child: Text('Cancel',style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDarkMode ? Colors.white : Colors.black),),
            ),
          ],
        ),
      ),
    );
  }
}