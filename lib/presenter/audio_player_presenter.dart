import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

abstract class AudioPlayBarView {
  void updatePlayerState(PlayerState state);
  void updateDuration(Duration duration);
  void updatePosition(Duration position);
}

class AudioPlayBarPresenter {
  final AudioPlayer player;
  final AudioPlayBarView view;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  AudioPlayBarPresenter({required this.player, required this.view}) {
    _initStreams();
    _fetchInitialData();
  }

  void _fetchInitialData() async {
    view.updatePlayerState(player.state);
    final duration = await player.getDuration();
    final position = await player.getCurrentPosition();
    if (duration != null) view.updateDuration(duration);
    if (position != null) view.updatePosition(position);
  }

  void _initStreams() {
    _durationSubscription =
        player.onDurationChanged.listen(view.updateDuration);
    _positionSubscription =
        player.onPositionChanged.listen(view.updatePosition);
    _playerCompleteSubscription = player.onPlayerComplete.listen((_) {
      view.updatePlayerState(PlayerState.stopped);
      view.updatePosition(Duration.zero);
    });
    _playerStateChangeSubscription =
        player.onPlayerStateChanged.listen(view.updatePlayerState);
  }

  Future<void> play() async {
    await player.resume();
    view.updatePlayerState(PlayerState.playing);
  }

  Future<void> pause() async {
    await player.pause();
    view.updatePlayerState(PlayerState.paused);
  }

  Future<void> stop() async {
    await player.stop();
    view.updatePlayerState(PlayerState.stopped);
    view.updatePosition(Duration.zero);
  }

  void seek(double value, Duration duration) {
    final position = (value * duration.inMilliseconds).round();
    player.seek(Duration(milliseconds: position));
  }

  Future<void> playSong(String songPath) async {
    await player.setSource(AssetSource(songPath));
    await player.resume();
    view.updatePlayerState(PlayerState.playing);
  }

  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
  }
}
