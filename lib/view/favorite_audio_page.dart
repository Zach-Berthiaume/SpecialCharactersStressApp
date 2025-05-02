import 'package:flutter/material.dart';
import 'package:special_characters/model/music_menu_model.dart';
import 'package:special_characters/view/audio_page.dart';
import 'package:provider/provider.dart';
import 'package:special_characters/model/theme.dart';
import 'package:special_characters/model/global_audio_state.dart';

class FavoriteAudioPage extends StatefulWidget {
  const FavoriteAudioPage({super.key});

  @override
  State<FavoriteAudioPage> createState() => _FavoriteAudioPageState();
}

class _FavoriteAudioPageState extends State<FavoriteAudioPage> {
  List<Favorites> _favorites = [];
  bool _isLoading = false;
  String? _error;
  final FavoritesFireBaseService _favoritesService = FavoritesFireBaseService();

@override
void initState() {
  super.initState();
  _loadFavorites();
}

Future<void> _loadFavorites() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });
  try {
    List<Favorites> favorites = await _favoritesService.getFavorites();
    setState(() {
      _favorites = favorites;
    });
  } catch (e) {
    setState(() {
      _error = e.toString();
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    final globalAudio = Provider.of<GlobalAudioState>(context, listen: false);
    return Scaffold(
      backgroundColor: isDarkMode ? Color.fromARGB(255, 21, 0, 73): Color(0xFFFFF8E1),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Favorite Audio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorites,
          ),
        ],
        backgroundColor: isDarkMode ? Colors.white : Color.fromARGB(255, 250, 218, 163),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(child: Text('Error: $_error'))
        : _favorites.isEmpty
          ? const Center(child: Text('No favorites found.'))
          : ListView.builder(
            itemCount: _favorites.length,
            itemBuilder: (context, index) {
              final favorite = _favorites[index];
              return ListTile(
                title: Text(favorite.songName, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Delete Favorite"),
                        content: const Text("Are youre sure you want to delete this favorite?"),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              await _favoritesService.deleteFavorite(favorite.id);
                              await _loadFavorites();
                              if(context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            child: const Text("Delete"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                onTap: () {
                  globalAudio.setSong(favorite.songName, favorite.songPath);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudioPage(
                        song: favorite.songName,
                        filePath: favorite.songPath,
                        queue: _favorites.map((f) => {"title": f.songName, "path": f.songPath}).toList(),
                        currentIndex: _favorites.indexOf(favorite),
                      ),
                    ),
                  );
                }
              );
            },
          ),
    );
  }
}