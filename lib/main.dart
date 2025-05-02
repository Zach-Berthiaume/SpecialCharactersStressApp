import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:special_characters/model/global_audio_state.dart';
import 'package:special_characters/model/theme.dart';
import 'package:special_characters/view/home_page.dart';
import 'package:special_characters/view/journal_page.dart';
import 'package:special_characters/view/planner_page.dart';
import 'package:special_characters/view/settings_page.dart';
import 'package:special_characters/view/alarm_page.dart';
import 'package:special_characters/view/music_menu_page.dart';
import 'package:special_characters/view/destress_tech_page.dart';
import 'package:special_characters/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:alarm/alarm.dart';
import 'package:special_characters/view/login_page.dart';
import 'package:special_characters/view/audio_page.dart';
import 'package:special_characters/view/edit_account_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is ready
  await Future.delayed(const Duration(seconds: 1));
  await Firebase.initializeApp(); // Initialize Firebase
  await Alarm.init(); // Initialize Alarms
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeModel()),
        ChangeNotifierProvider(create: (context) => GlobalAudioState()),
      ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Special Characters',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      home: const SplashWrapper(),
      routes: {
        '/home': (context) => const MyHomePage(),
        '/login': (context) => const LoginPage(),
        '/editAccount': (context) => const EditAccountPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _currentScreen = 'Home';

  Widget _getScreen(String screen) {
    switch (screen) {
      case 'Home':
        return HomePage();
      case 'Alarm':
        return AlarmPage();
      case 'Journal':
        return JournalPage();
      case 'Settings':
        return SettingsPage();
      case 'Music':
        return MusicMenuPage();
      case 'Destress':
        return DestressTechPage();
      case 'Planner':
        return PlannerPage();
      default:
        return HomePage();
    }
  }

  Widget _buildDrawerItem(IconData icon, String title) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return ListTile(
      leading: Icon(icon , color: isDarkMode ? Colors.purpleAccent : Colors.deepOrange),
      title: Text(
        title,
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black87,
        )
      ),
      onTap: () {
        setState(() {
          _currentScreen = title;
        });
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: isDarkMode ? Color.fromARGB(255, 21, 0, 73) : Color.fromARGB(255, 0, 235, 255),
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color.fromARGB(255, 80, 80 ,80)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: isDarkMode ? const Color(0xFF1E1E2C) : const Color(0xFFFFF8E1),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.deepPurple : Colors.amber,
                ),
                child: const Text(
                  'Navigation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              _buildDrawerItem(Icons.home, 'Home'),
              _buildDrawerItem(Icons.alarm, 'Alarm'),
              _buildDrawerItem(Icons.music_note, 'Music'),
              _buildDrawerItem(Icons.book, 'Journal'),
              _buildDrawerItem(Icons.calendar_today, 'Planner'),
              _buildDrawerItem(Icons.self_improvement, "Destress"),
              _buildDrawerItem(Icons.settings, 'Settings'),
             ],
            ),
          ),
        ),
      body: _getScreen(_currentScreen),
      floatingActionButton: Consumer<GlobalAudioState>(
        builder: (context, audioState, child) {
          if (!audioState.isPlaying || audioState.songTitle == null) return SizedBox.shrink();
          return Stack(
            children: [
              Positioned(
                bottom: 16,
                right: 16,
                child: FloatingActionButton.extended(
                heroTag: 'nowPlayingFab',
                onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AudioPage(
                          song: audioState.songTitle!,
                          filePath: audioState.filePath!,
                          queue: audioState.queue ?? [],
                          currentIndex: audioState.currentIndex ?? 0,
                          existingPlayer: audioState.player,
                        ),
                      ),
                    );
                  },
                  label: Text("Now Playing: ${audioState.songTitle}"),
                  icon: Icon(Icons.music_note),
                  backgroundColor: isDarkMode ? Color.fromARGB(255, 10, 0, 36) : Color.fromARGB(255, 249, 194, 99),
                ),
              ),
              Positioned(
                bottom: 90,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'nowPlayingFabClose',
                  mini: true,
                  onPressed: () {
                    Provider.of<GlobalAudioState>(context, listen: false).stop();
                  },
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.close),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
