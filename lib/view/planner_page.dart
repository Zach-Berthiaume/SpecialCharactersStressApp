import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:special_characters/model/planner_model.dart';
import 'package:special_characters/model/theme.dart';
import 'package:special_characters/presenter/planner_presenter.dart';
import 'package:special_characters/view/plannerdayview.dart';

class PlannerPage extends StatefulWidget {
  const PlannerPage({super.key});

  @override
  State<PlannerPage> createState() => _PlannerPageState();
}

class _PlannerPageState extends State<PlannerPage> implements PlannerView {
  late PlannerPresenter _presenter;
  List<PlannerEntry> _plannerEntries = [];
  Map<String, List<PlannerEntryEvent>> _plannerEntryEvents = {};
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  DateTime get _startOfWeek =>
      _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));

  void _refreshPlannerEntries() {
    _presenter.loadPlannerEntries();
  }

  @override
  void initState() {
    super.initState();
    _presenter = PlannerPresenter(this);
    _presenter.loadPlannerEntries();
  }

  @override
  void showPlannerEntries(List<PlannerEntry> entries, Map<String, List<PlannerEntryEvent>> entryEvents) {
    setState(() {
      _plannerEntries = entries;
      _plannerEntryEvents = entryEvents;
      _errorMessage = null;
    });
  }

  @override
  void showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _changeWeek(int deltaDays) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: deltaDays));
    });
  }

  Color darkenColor(Color originalColor) {
    var hslColor = HSLColor.fromColor(originalColor);
    double newLightness = 0.0;

    switch (originalColor){
      case Colors.white:
        newLightness = min(max(hslColor.lightness - .2, 0.0), 1.0);
        break;
      default:
        newLightness = min(max(hslColor.lightness - .09, 0.0), 1.0);
        break;
    }
    return HSLColor.fromColor(originalColor).withLightness(newLightness).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;

    Color getMoodColor(String mood) {
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
          return Colors.white;
      }
    }


    return Center(
      child: Container(
        color: isDarkMode ? Colors.grey[300] : Colors.white,
        child: Column(
          children: [
            Container(
              color: isDarkMode ? Color.fromARGB(255, 10, 0, 36) : Color.fromARGB(255, 249, 194, 99),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => _changeWeek(-7),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                    child: Column(
                      children: [
                        Text(
                          '${DateFormat('MMM d').format(_startOfWeek)} - ${DateFormat('MMM d').format(_startOfWeek.add(const Duration(days: 6)))}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => _changeWeek(7),
                  ),
                ],
              ),
            ),
            Table(
              border: TableBorder.all(),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: List.generate(7, (i) {
                final currentDate = _startOfWeek.add(Duration(days: i));

                return TableRow(
                  children: [
                    TableCell(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        color: Colors.grey[350],
                        child: Text(
                          DateFormat('EEEE').format(currentDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    TableCell(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlannerDayView(
                                selectedDateID: DateFormat('yyyy-MM-dd').format((_startOfWeek.add(Duration(days: i)))),
                              ),
                            ),
                          ).then((_) => _refreshPlannerEntries());
                        },
                        child: Stack(
                          children: [
                            Container(
                              height: 85,
                              decoration: BoxDecoration(
                                color: getMoodColor(
                                  _plannerEntries.firstWhere(
                                        (entry) => entry.id == DateFormat('yyyy-MM-dd').format(currentDate),
                                    orElse: () => PlannerEntry(id: '', date: '', mood: '',),
                                  ).mood,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),

                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: (_plannerEntryEvents[DateFormat('yyyy-MM-dd').format(currentDate)] ?? []).take(3).map((event) => Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4),
                                    child: Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        color: darkenColor(getMoodColor(
                                          _plannerEntries.firstWhere(
                                                (entry) => entry.id == DateFormat('yyyy-MM-dd').format(currentDate),
                                            orElse: () => PlannerEntry(id: '', date: '', mood: '',),
                                          ).mood,
                                        ),),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Icon(
                                        EventIconData.getIconFromString(event.icon),
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                  )).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            Expanded(
                child: Container(
                  color: isDarkMode ? Color.fromARGB(255, 21, 0, 73) : Color.fromARGB(255, 250, 218, 163),
              ),
            )
          ],
        ),
      ),
    );
  }
}
