import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:special_characters/model/theme.dart';
import 'package:special_characters/presenter/plannerdayview_presenter.dart';
import 'package:special_characters/model/planner_model.dart';
import 'package:special_characters/view/plannerdayeventview.dart';


class PlannerDayView extends StatefulWidget {
  final String selectedDateID;

  const PlannerDayView({super.key, required this.selectedDateID});

  @override
  State<PlannerDayView> createState() => _PlannerDayViewState();
}

class _PlannerDayViewState extends State<PlannerDayView> implements AbstractPlannerDayView{
  late PlannerDayViewPresenter _presenter;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _presenter = PlannerDayViewPresenter(this);
    _presenter.loadDayViewData(widget.selectedDateID);
  }

  @override
  void refreshDayViewData(){
    setState(() {
      _presenter.loadDayViewData(widget.selectedDateID);
    });
  }

  @override
  void showDayViewData(){
    setState(() {
      _errorMessage = null;
    });
  }

  @override
  void showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return Scaffold(
        backgroundColor: isDarkMode ? Color.fromARGB(255, 21, 0, 73) : Color.fromARGB(255, 250, 218, 163),
        appBar: buildPlannerDayViewAppBar(context),
        body: Center(
          child: Column(
            children: [
              SizedBox(height: 40),
              buildDateText(),
              SizedBox(height: 20),
              buildMoodDisplay(),
              SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black, side: BorderSide(color: Colors.black12),//  color of border
                  backgroundColor: Colors.black12,
                ),
                onPressed: () async{
                  final result = await showMenu<String>(
                      context: context,
                      color: Colors.grey,
                      position: RelativeRect.fromLTRB(132,350,400,0),
                      items: [
                        PopupMenuItem(value: 'Happy', child: Text('Happy', style: TextStyle(color: isDarkMode ? Colors.black : Colors.white))),
                        PopupMenuItem(value: 'Okay', child: Text('Okay', style: TextStyle(color: isDarkMode ? Colors.black : Colors.white))),
                        PopupMenuItem(value: 'Sad', child: Text('Sad', style: TextStyle(color: isDarkMode ? Colors.black : Colors.white))),
                      ]
                  );
                  if (result != null) {
                    //save change in mood to firebase
                    _presenter.changePlannerEntryMood(result);
                  }
                },
                child: Text(
                  "Set Mood",
                  style: TextStyle(
                    fontSize: 20,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                  child: SingleChildScrollView(
                    child: _buildPlannerEntryEvents(),
                  )
              ),
              Divider(thickness: 5),
              SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black, side: BorderSide(color: Colors.black12),//  color of border
                  backgroundColor: Colors.black12,
                ),
                onPressed: () async {
                  //switch to create event view page
                  bool? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateEditEventPage(currentEntryID: _presenter.currentPlannerEntry!.id,),
                    ),
                  );
                  if (result == true){
                    refreshDayViewData();
                  }
                },
                child: Text(
                  "ADD EVENT",
                  style: TextStyle(
                    fontSize: 20,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        )
    );
  }

  Widget buildMoodDisplay() {
    if (_presenter.currentPlannerEntry == null){
      return CircularProgressIndicator();
    }
    String moodString = _presenter.currentPlannerEntry!.mood;
    Color moodColor = getMoodColor(moodString);

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white, side: BorderSide(color: moodColor), //  color of border
        backgroundColor: moodColor,
      ),
      onPressed: () {},

      child: Text(
        moodString,
        style: TextStyle(
          fontSize: 40,
          color: Colors.white,
        ),
      )
    );
  }

  Color getMoodColor(String mood) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    switch (mood.toLowerCase()) {
      case 'happy':
        return isDarkMode ? Color.fromARGB(255, 82, 128, 77) : Color.fromARGB(
            255, 122, 186, 116);
      case 'okay':
        return isDarkMode ? Color.fromARGB(255, 220, 174, 76) : Color.fromARGB(
            255, 248, 206, 22);
      case 'sad':
        return isDarkMode ? Color.fromARGB(255, 79, 101, 145) : Color.fromARGB(
            255, 110, 148, 221);
      default:
        return Colors.grey;
    }
  }

  Widget buildDateText() {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    if (_presenter.currentPlannerEntry == null){
      return CircularProgressIndicator();
    }
    return Text(
      _presenter.currentPlannerEntry!.date,
      style: TextStyle(
        fontSize: 40,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }

  //build list of firebase plannerEntryEvents for the day
  Widget _buildPlannerEntryEvents(){
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    if (_presenter.currentPlannerEntry == null){
      return CircularProgressIndicator();
    }
    //iterate through all planner events for the day & display them:
    if (_presenter.currentPlannerEntryEvents!.isEmpty){
      return Column(
        children: [
          Text(
            "No events today!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black,
            )
          ),
        ],
      );
    }
    return Column(
      children: [
        for (var event in _presenter.currentPlannerEntryEvents!) ...[
          Divider(thickness: 3,),
          _buildPlannerEntryEvent(event),
        ],
        Divider(thickness: 3,),
      ],
    );
  }

  //build individual planner entry
  ListTile _buildPlannerEntryEvent(PlannerEntryEvent event) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return ListTile(
        title: Row(
          children: [
            Icon(
              EventIconData.getIconFromString(event.icon),
              size: 34,
            ),
            Expanded(
              child: Text(
                "\t${event.name}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),

            Text(
              event.time,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                _presenter.deletePlannerEntryEvent(event);
                refreshDayViewData();
              },
            ),
          ],
        ),
        onTap: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEditEventPage(currentEntryID: _presenter.currentPlannerEntry!.id, event: event),
            ),
          );
          if (result == true){
            refreshDayViewData();
          }
        }
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
