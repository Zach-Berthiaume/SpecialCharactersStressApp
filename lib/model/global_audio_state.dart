import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class GlobalAudioState extends ChangeNotifier {
  String? songTitle;
  String? filePath;
  bool isPlaying = false;
  List<Map<String, String>>? queue;
  int? currentIndex;
  AudioPlayer? player;

  void setSong(String title, String path, {List<Map<String, String>>? songQueue, int? index, AudioPlayer? existingPlayer}) {
    songTitle = title;
    filePath = path;
    queue = songQueue;
    currentIndex = index;
    player = existingPlayer ?? AudioPlayer();
    isPlaying = true;
    notifyListeners();
  }

  void pause() {
    isPlaying = false;
    notifyListeners();
  }

  void resume() {
    isPlaying = true;
    notifyListeners();
  }

  void stop() async {
    if (player != null) {
      await player!.stop();
    }
  songTitle = null;
  filePath = null;
  queue = null;
  currentIndex = null;
  isPlaying = false;
  notifyListeners();
}
}
List<Map<String, String>>? queue;
int? currentIndex;