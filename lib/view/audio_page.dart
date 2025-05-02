import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:special_characters/model/music_menu_model.dart';
import 'package:special_characters/presenter/audio_player_presenter.dart';
import 'package:provider/provider.dart';
import 'package:special_characters/model/theme.dart';
import 'package:special_characters/model/global_audio_state.dart';

class AudioPage extends StatefulWidget {
  final String song;
  final String filePath;
  final List<Map<String, String>> queue;
  final int currentIndex;
  final AudioPlayer? existingPlayer;
  const AudioPage({super.key, required this.song, required this.filePath, required this.queue, required this.currentIndex, this.existingPlayer});

  @override
  State<AudioPage> createState() => _AudioPageState();
}

class _AudioPageState extends State<AudioPage> implements AudioPlayBarView {
  late AudioPlayer player;
  late AudioPlayBarPresenter _presenter;
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;

  late int currentIndex;
  late List<Map<String, String>> queue;

  bool isFavorited = false;
  bool get _isPlaying => _playerState == PlayerState.playing;
  bool get _isPaused => _playerState == PlayerState.paused;
  String get _durationText => _duration?.toString().split('.').first ?? '';
  String get _positionText => _position?.toString().split('.').first ?? '';

  final FavoritesFireBaseService favService = FavoritesFireBaseService();

  @override
  void initState() {
    super.initState();
    player = widget.existingPlayer ?? AudioPlayer();
    _presenter = AudioPlayBarPresenter(player: player, view: this);
    currentIndex = widget.currentIndex;
    queue = widget.queue;
    _presenter.playSong(widget.filePath);
    _checkIfFavorited();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final globalAudio = Provider.of<GlobalAudioState>(context, listen: false);
      globalAudio.setSong(widget.song, widget.filePath, songQueue: widget.queue, index: widget.currentIndex);
    });
    player.onPlayerComplete.listen((event) {
      if (currentIndex + 1 < queue.length) {
        setState(() {
          currentIndex++;
        _presenter.playSong(queue[currentIndex]["path"]!);
        });
      }
    });
  }

  Future<void> _checkIfFavorited() async {
    final favorites = await favService.getFavorites();
    setState(() {
      isFavorited = favorites.any((fav) => fav.songName == widget.song && fav.songPath == widget.filePath);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final globalAudio = Provider.of<GlobalAudioState>(context, listen: false);
        globalAudio.setSong(widget.song, widget.filePath, songQueue: widget.queue, index: widget.currentIndex);
        globalAudio.stop();
      }
    });
    _presenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    final color = isDarkMode ? Colors.white : Color.fromARGB(255, 249, 194, 99);
    return Scaffold(
      backgroundColor: isDarkMode ? Color.fromARGB(255, 21, 0, 73): Color(0xFFFFF8E1),
      appBar: AppBar(title: Text(queue[currentIndex]["title"]!), backgroundColor: isDarkMode ? Colors.white : Color.fromARGB(255, 250, 218, 163),),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: Colors.redAccent,
                ),
                onPressed: () async {
                  if (isFavorited) {
                    final favorites = await favService.getFavorites();
                    final match = favorites.firstWhere((fav) => fav.songName == widget.song && fav.songPath == widget.filePath,
                    orElse: () => Favorites(id: '', songName: '', songPath: '')
                    );
                    if (match.id.isNotEmpty) {
                      await favService.deleteFavorite(match.id);
                      if(context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${widget
                                .song} removed from favorites')));
                      }
                    }
                  } else {
                    Favorites newFavorite = Favorites(id: '', songName: widget.song, songPath: widget.filePath);
                    await favService.addFavorite(newFavorite);
                    if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${widget
                              .song} added to favorites')));
                    }
                  }
                  setState(() {
                    isFavorited = !isFavorited;
                  });
                  if(context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('${widget.song} added to favorites'))
                    );
                  }
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset(
            'assets/images/albumCover.png',
            height: 200,
            fit: BoxFit.cover,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous),
                color: isDarkMode ? Colors.white : Color.fromARGB(255, 249, 194, 99),
                iconSize: 48.0,
                onPressed: currentIndex > 0 ? () {
                  setState(() {
                    currentIndex--;
                    _presenter.playSong(queue[currentIndex]["path"]!);
                  });
                } : null,
              ),
              playButton(color),
              pauseButton(color),
              stopButton(color),
              IconButton(
                icon: Icon(Icons.skip_next),
                color: isDarkMode ? Colors.white : Color.fromARGB(255, 249, 194, 99),
                iconSize: 48.0,
                onPressed: currentIndex + 1 < queue.length ? () {
                  setState(() {
                    currentIndex++;
                    _presenter.playSong(queue[currentIndex]["path"]!);
                  });
                } : null,
              ),
            ],
          ),
          buildSlider(), 
          Text(
            _position != null
                ? '$_positionText / $_durationText'
                : _duration != null
                    ? _durationText
                    : '',
            style: const TextStyle(fontSize: 16.0),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final PlaylistFirebaseService playlistService = PlaylistFirebaseService();
          final playlists = await playlistService.getPlaylists();
          if (playlists.isEmpty) {
            if(context.mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No playlists available. Please create one in Music Menu.")),
            );
            }
            return;
          }
          showDialog(
            context: context.mounted ? context : context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Add to Playlist"),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    shrinkWrap: true,
                    children: playlists.map((playlist) {
                      return ListTile(
                        title: Text(playlist.playlistName),
                        onTap: () async {
                          final songExists = playlist.songs.any((song) =>
                          song["title"] == widget.song && song["path"] == widget.filePath);
                          if (songExists) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.song} is already in ${playlist.playlistName}')));
                            return;
                          }
                          playlist.songs.add({
                            "title": widget.song,
                            "path": widget.filePath,
                          });
                          await playlistService.editPlaylist(playlist);
                          if(context.mounted) {
                            Navigator.pop(context);
                          }
                          if(context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(
                                  '${widget.song} added to ${playlist
                                      .playlistName}')),
                            );
                          }
                        },
                      ); 
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.playlist_add),
      ),
    );
  }

  Slider buildSlider() {
    final isDarkMode = Provider.of<ThemeModel>(context).isDarkMode;
    return Slider(
      thumbColor: isDarkMode ? Color.fromARGB(255, 10, 0, 36) : Color.fromARGB(255, 249, 194, 99),
      onChanged: (value) {
        if (_duration != null) {
          _presenter.seek(value, _duration!);
        }
      },
      value: (_position != null && _duration != null)
          ? _position!.inMilliseconds / _duration!.inMilliseconds
          : 0.0,
    );
  }

  IconButton stopButton(Color color) {
    return IconButton(
      key: const Key('stop_button'),
      onPressed: _isPlaying || _isPaused ? _presenter.stop : null,
      iconSize: 48.0,
      icon: const Icon(Icons.stop),
      color: color,
    );
  }

  IconButton pauseButton(Color color) {
    return IconButton(
      key: const Key('pause_button'),
      onPressed: _isPlaying ? _presenter.pause : null,
      iconSize: 48.0,
      icon: const Icon(Icons.pause),
      color: color,
    );
  }

  IconButton playButton(Color color) {
    return IconButton(
      key: const Key('play_button'),
      onPressed: _isPlaying ? null : _presenter.play,
      iconSize: 48.0,
      icon: const Icon(Icons.play_arrow),
      color: color,
    );
  }

  // Implementing the View interface methods
  @override
  void updatePlayerState(PlayerState state) {
    if (mounted) setState(() => _playerState = state);
  }

  @override
  void updateDuration(Duration duration) {
    if (mounted) setState(() => _duration = duration);
  }

  @override
  void updatePosition(Duration position) {
    if (mounted) setState(() => _position = position);
  }
}
