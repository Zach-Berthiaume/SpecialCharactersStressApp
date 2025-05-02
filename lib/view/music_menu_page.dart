import 'package:flutter/material.dart';
import 'package:special_characters/view/audio_page.dart';
import 'package:special_characters/view/favorite_audio_page.dart';
import 'package:provider/provider.dart';
import 'package:special_characters/model/theme.dart';
import 'package:special_characters/model/music_menu_model.dart';
import 'package:special_characters/model/global_audio_state.dart';

class MusicMenuPage extends StatefulWidget {
  const MusicMenuPage({super.key});

  @override
  State<MusicMenuPage> createState() => _MusicMenuPageState();
}

class _MusicMenuPageState extends State<MusicMenuPage> {
  final List<Map<String, String>> songs = [
    {"title": "Study Time Tune", "path": "audio/studyTime.mp3"},
  ];

  List<Playlist> _playlists = [];
  List<Map<String, String>> browseSongs = [
              {"title": "Stress Relief Song", "path": "audio/musicForStress.mp3"},
              {"title": "Anxiety Relief Song", "path": "audio/anxietyRelief.mp3"},
              {"title": "Discovering Oasis of Inner Calm", "path": "audio/innerCalm.mp3"},
            ];

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    List<Playlist> fetchedPlaylists = await service.getPlaylists();
    setState(() {
      _playlists = fetchedPlaylists;
    });
  }

  PlaylistFirebaseService service = PlaylistFirebaseService();

  int _selectedIndex = 0;

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        showDialog(
          context: context,
          builder: (context) {
            final isDarkMode = Provider.of<ThemeModel>(context, listen: false).isDarkMode;
            return AlertDialog(
              backgroundColor: isDarkMode ? Color.fromARGB(255, 10, 0, 36) : Color.fromARGB(255, 249, 194, 99),
              titleTextStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              title: const Text("Browse Music"),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: browseSongs.length,
                  itemBuilder: (context, index) {
                    final song = browseSongs[index];
                    return ListTile(
                      title: Text(song["title"]!, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),),
                      trailing: TextButton(
                        onPressed: () {
                          setState(() {
                            songs.add(song);
                            browseSongs.removeAt(index);
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${song["title"]} added to library'))
                          );
                        },
                        child: const Text("Add"),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const FavoriteAudioPage(),
          ),
        );
        break;
      case 2:
        showDialog(
          context: context,
          builder: (context) {
            TextEditingController playlistController = TextEditingController();
            final isDarkMode = Provider.of<ThemeModel>(context, listen: false).isDarkMode;
            return AlertDialog(
              backgroundColor: isDarkMode ? Color.fromARGB(255, 10, 0, 36) : Color.fromARGB(255, 249, 194, 99),
              titleTextStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              contentTextStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              title: const Text("Create Playlist"),
              content: TextField(
                controller: playlistController,
                decoration: const InputDecoration(hintText: "Playlist Name"),
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    String newPlaylistName = playlistController.text;
                    Playlist newPlaylist = Playlist(id: '', playlistName: newPlaylistName, songs: []);

                    await service.addPlaylist(newPlaylist);
                    await _loadPlaylists();
                    if(context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Create"),
                ),
              ],
            );
          },
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDarkMode ? Color.fromARGB(255, 21, 0, 73): Color(0xFFFFF8E1),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            "Music Library",
            style: TextStyle(
              fontSize: 28,
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Container(
                    color: isDarkMode ? Color.fromARGB(255, 21, 0, 73) : Color.fromARGB(255, 250, 218, 163),
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Playlists",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black,)
                    ),
                  ),
                ),
                ..._playlists.map((playlist) {
                  return ExpansionTile(
                    backgroundColor: isDarkMode ? Color.fromARGB(255, 10, 0, 36) : Color.fromARGB(255, 249, 194, 99),
                    title: Text(playlist.playlistName, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                    children: playlist.songs
                        .map((song) => ListTile(
                            tileColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                              title: Text(song["title"]!, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    color: isDarkMode ? Colors.lightBlueAccent : Colors.blue,
                                    onPressed: () {
                                      final globalAudio = Provider.of<GlobalAudioState>(context, listen: false);
                                      globalAudio.setSong(song["title"]!, song["path"]!, songQueue: songs, index: songs.indexOf(song));
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => AudioPage(song: song["title"]!, filePath: song["path"]!, queue: playlist.songs, currentIndex: playlist.songs.indexOf(song),),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    color: Colors.redAccent,
                                    onPressed: () async {
                                      Playlist selectedPlaylist = _playlists.firstWhere((p) => p.playlistName == playlist.playlistName); 
                                      selectedPlaylist.songs.remove(song);
                                      
                                      await service.editPlaylist(selectedPlaylist);
                                      await _loadPlaylists();
                                      if(context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(
                                              '${song["title"]} removed from $playlist.playlistName')),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  );
                }),
                Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    color: isDarkMode ? Color.fromARGB(255, 21, 0, 73) : Color.fromARGB(255, 250, 218, 163),
                    child: Text(
                      "All Songs",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black,),
                    ),
                  ),
                ),
                ...songs.map((song) {
                  return ListTile(
                    tileColor: isDarkMode ? Color.fromARGB(255, 14, 0, 51) : Color(0xFFFFF8E1),
                    title: Text(song["title"]!, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                    trailing: PopupMenuButton<String>(
                      onSelected: (playlistName) async {
                        Playlist selectedPlaylist = _playlists.firstWhere((p) => p.playlistName == playlistName);
                        bool songExists = selectedPlaylist.songs.any((s) => s["title"] == song["title"] && s["path"] == song["path"]);
                        if (songExists) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${song["title"]} is already in $playlistName')));
                          return;
                        }

                        selectedPlaylist.songs.add(song);
                        await service.editPlaylist(selectedPlaylist);
                        await _loadPlaylists();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '${song["title"]} added to $playlistName')),
                          );
                        }
                        },
                      itemBuilder: (context) {
                        return _playlists.map((playlist) {
                          return PopupMenuItem(
                            value: playlist.playlistName,
                            child: Text('Add to ${playlist.playlistName}'),
                          );
                        }).toList();
                      },
                    ), 
                    onTap: () {
                      final globalAudio = Provider.of<GlobalAudioState>(context, listen: false);
                      globalAudio.setSong(song["title"]!, song["path"]!, songQueue: songs, index: songs.indexOf(song));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AudioPage(
                              song: song["title"]!, filePath: song["path"]!, queue: songs, currentIndex: songs.indexOf(song),),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDarkMode ? Colors.black : Color.fromARGB(255, 250, 218, 163),
        selectedItemColor: isDarkMode ? Colors.grey : Colors.black,
        unselectedItemColor: isDarkMode ? Colors.grey : Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: "Browse Music",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add),
            label: "Create",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}
