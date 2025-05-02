import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:special_characters/model/theme.dart';
import 'package:special_characters/model/planner_model.dart';
import 'package:special_characters/presenter/plannerdayeventview_presenter.dart';

class CreateEditEventPage extends StatefulWidget {
  //event can be null if it's create event page, otherwise event being edited is passed in.
  final PlannerEntryEvent? event;
  final String currentEntryID;

  const CreateEditEventPage({super.key, this.event, required this.currentEntryID});

  @override
  State<CreateEditEventPage> createState() => _CreateEditEventPageState();
}

class _CreateEditEventPageState extends State<CreateEditEventPage> implements AbstractCreateEditEventPage {
  late PlannerDayEventViewPresenter _presenter;
  bool isEditMode = false;
  PlannerEntryEvent? event;

  TextEditingController _eventNameField = TextEditingController();
  String iconString = "circle_outlined"; //default icon for making events
  TimeOfDay? selectedTime = TimeOfDay(hour: 0, minute: 0); //default time selection
  late String selectedTimeString = '12:00 AM';

  @override initState(){
    super.initState();
    _presenter = PlannerDayEventViewPresenter();

    if (widget.event != null) {
      event = widget.event;
      _eventNameField = TextEditingController(text: event!.name);
      iconString = event!.icon;
      isEditMode = true;
      selectedTimeString = event!.time;
    }
  }

  //change the display when the user changes their desired icon in icon selector
  @override
  void updateIcon(String newIconString) {
    setState(() {
      iconString = newIconString;
    });
  }

  void _showIconOptions() async {
    List<String> iconStringList = EventIconData.iconStringList;
    
    String? iconString = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            "Choose an Icon",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: iconStringList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              IconData icon = EventIconData.getIconFromString(iconStringList[index]);
              return InkWell(
                onTap: () => Navigator.pop(context, iconStringList[index]),
                child: Icon(
                  icon,
                  size: 30,
                  color: Colors.black,
                ),
              );},
          ),
        ),
      ),
    );
    if (iconString != null) {
      updateIcon(iconString);
    }
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (time != null) {
      setState((){
        selectedTime = time;
        selectedTimeString = selectedTime!.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: buildPlannerDayViewAppBar(context),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                isDarkMode ? 'assets/images/stars.png' : 'assets/images/clouds.png',
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                color: Colors.white,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(thickness: 8),
                    Padding(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: Row(
                        children: [
                          Text(
                            "Event: ",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _eventNameField,
                              decoration: InputDecoration(
                                hintText: 'Enter Event Name',
                              ),
                              textAlign: TextAlign.center, // Center the hint and input text
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(thickness: 8,),
                    SizedBox(height: 10,),
                    Text(
                      selectedTimeString,
                      textAlign: TextAlign.center, // Center the hint and input text
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _selectTime(context);
                      },
                      child: Text(
                        "Change Time ▼",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),

                    Icon(
                      EventIconData.getIconFromString(iconString),
                      size: 80,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showIconOptions();
                      },
                      child: Text(
                        "Change Icon ▼",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Divider(thickness: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.save_alt,size: 30,),
                          onPressed: () {
                            if (isEditMode){
                              _presenter.addOrEditPlannerEntryEvent(
                                  widget.currentEntryID, event!.id, _eventNameField.text, selectedTime!.format(context), iconString);
                            }
                            else{
                              _presenter.addOrEditPlannerEntryEvent(
                                  widget.currentEntryID, "", _eventNameField.text, selectedTime!.format(context), iconString);

                            }
                            Navigator.pop(context, true);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,size: 30),
                          onPressed: () {
                            if (isEditMode){
                              _presenter.deletePlannerEntryEvent(widget.currentEntryID, event!);
                              Navigator.pop(context, true);
                            }
                            else{
                              //Entry doesn't exist, so don't save, just leave the page so it is deleted
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                    Divider(thickness: 8),
                  ]),
              ),
            )],
        ),
    );
  }


  AppBar buildPlannerDayViewAppBar(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                isDarkMode ? 'assets/images/stars.png' : 'assets/images/clouds.png'
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () {
            Navigator.pop(context);
          }
      ),
    );
  }
}