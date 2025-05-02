import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:special_characters/model/journal_model.dart';
import 'package:special_characters/model/theme.dart';
import 'package:special_characters/presenter/create_edit_journal_presenter.dart';
import 'package:special_characters/presenter/journal_presenter.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> implements JournalView {
  late JournalPresenter _presenter;
  List<JournalEntry> _journalEntries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _presenter = JournalPresenter(this);
    _presenter.loadJournalEntries();
  }

  @override
  void showJournalEntries(List<JournalEntry> entries) {
    setState(() {
      _journalEntries = entries;
      _isLoading = false;
      _errorMessage = null;
    });
  }

  @override
  void showError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  //calls load journal entries whenever called to update ui with new data information
  void _refreshJournalEntries() {
    setState(() {
      _presenter.loadJournalEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return Scaffold(
      backgroundColor:
          isDarkMode ? Color.fromARGB(255, 21, 0, 73) : Color(0xFFFFF8E1),
      body: Center(
        child: Column(children: [
          SizedBox(
            height: 10,
          ),
          Text(
            "My Journal",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          TextButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(isDarkMode
                    ? Color.fromARGB(255, 21, 0, 73)
                    : Color.fromARGB(255, 250, 218, 163))),
            child: Text(
              "Create New Entry",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () async {
              bool? result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateJournalEntryPage(),
                ),
              );
              if (result == true) {
                //refresh since true from navigator.pop indicates a change in database
                _refreshJournalEntries();
              }
            },
          ),
          Expanded(
            child: SingleChildScrollView(child: _buildJournalEntries()),
          ),
          Container(
            color:
                isDarkMode ? Colors.black : Color.fromARGB(255, 250, 218, 163),
            height: 50,
          ),
        ]),
      ),
    );
  }

  Widget _buildJournalEntries() {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Column(children: [
        Text(
          "Error: $_errorMessage",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ]);
    }
    if (_journalEntries.isEmpty) {
      return Column(children: [
        Text("No entries yet, try creating one!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black,
            ))
      ]);
    }
    //if not any of the cases above:
    //sort by recent edits
    _journalEntries.sort();
    return Column(
      children: [
        for (JournalEntry entry in _journalEntries) ...[
          _buildJournalEntry(entry),
          const Divider(thickness: 2),
        ],
      ],
    );
  }

  //individual journal entry builder
  ListTile _buildJournalEntry(JournalEntry entry) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.entryName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            Text(
              DateFormat('MM/dd/yyyy')
                  .format(DateFormat('MM/dd/yyyy').parse(entry.entryDate)),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                //delete from database (no UI needed)
                await _presenter.deleteJournalEntry(entry.id);
              },
            ),
          ],
        ),
        onTap: () async {
          //go to journal entry page
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditJournalEntryPage(entry: entry),
            ),
          );
          if (result == true) {
            //refresh since true from navigator.pop indicates a change in database
            _refreshJournalEntries();
          }
        });
  }
}

class EditJournalEntryPage extends StatefulWidget {
  final JournalEntry entry;

  const EditJournalEntryPage({required this.entry, super.key});

  @override
  State<EditJournalEntryPage> createState() => _EditJournalEntryPageState();
}

class _EditJournalEntryPageState extends State<EditJournalEntryPage> {
  final CreateEditJournalPresenter _presenter = CreateEditJournalPresenter();
  late String _entryName;
  late String _entryDate;
  late TextEditingController _textField;

  @override
  void initState() {
    super.initState();
    _entryName = widget.entry.entryName;
    _entryDate = DateFormat('MM/dd/yyyy')
        .format(DateFormat('MM/dd/yyyy').parse(widget.entry.entryDate));
    _textField = TextEditingController(text: widget.entry.entryText);
  }

  @override
  void dispose() {
    _textField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return Scaffold(
      backgroundColor:
          isDarkMode ? Color.fromARGB(255, 21, 0, 73) : Color(0xFFFFF8E1),
      resizeToAvoidBottomInset: false,
      appBar: buildJournalEntryAppBar(context),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          const SizedBox(height: 10),
          Text(
            _entryName,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const Divider(thickness: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  "\t Last Edit: $_entryDate",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.save_alt),
                onPressed: () async {
                  await _presenter.editEntry(widget.entry, _textField.text);
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await _presenter.deleteEntry(widget.entry.id);
                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
            ],
          ),
          const Divider(thickness: 4),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _textField,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                hintText:
                'Write your entry here;\nDon\'t forget to save your changes!',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 20,
            ),
          )
        ],
      ),
    );
  }

  AppBar buildJournalEntryAppBar(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return AppBar(
      backgroundColor: isDarkMode
          ? const Color.fromARGB(255, 21, 0, 73)
          : const Color(0xFFFFF8E1),
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(isDarkMode
                ? 'assets/images/stars.png'
                : 'assets/images/clouds.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        iconSize: 30,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

class CreateJournalEntryPage extends StatelessWidget {
  final CreateEditJournalPresenter _presenter = CreateEditJournalPresenter();
  CreateJournalEntryPage({super.key});

  final TextEditingController _titleField = TextEditingController();
  final TextEditingController _textField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildJournalEntryAppBar(context),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(left: 40, right: 40),
              child: TextField(
                controller: _titleField,
                decoration: InputDecoration(
                  hintText: 'Enter Title',
                ),
                textAlign: TextAlign.center, // Center the hint and input text
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Divider(thickness: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.save_alt),
                onPressed: () {
                  //save to database
                  _presenter.addEntry(_titleField.text, _textField.text);
                  //close window:
                  Navigator.pop(context, true);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  //Don't save, just leave the page so it is deleted
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          Divider(thickness: 4),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _textField,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText:
                    'Write your entry here;\nDon\'t forget to save your changes!',
              ),
              keyboardType: TextInputType.multiline,
              maxLines: 10,
            ),
          )
        ],
      ),
    );
  }

  AppBar buildJournalEntryAppBar(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(isDarkMode
                  ? 'assets/images/stars.png'
                  : 'assets/images/clouds.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 30,
            onPressed: () {
              Navigator.pop(context);
            }));
  }
}
