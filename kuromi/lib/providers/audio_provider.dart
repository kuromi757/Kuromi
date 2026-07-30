import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

enum RepeatMode { off, one, all }

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _shuffle = false;
  RepeatMode _repeat = RepeatMode.off;
  Timer? _sleepTimer;
  int _sleepTimerRemaining = 0;
  Timer? _sleepCountdown;

  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  Song? get currentSong =>
      _currentIndex >= 0 && _currentIndex < _queue.length
          ? _queue[_currentIndex]
          : null;
  bool get shuffle => _shuffle;
  RepeatMode get repeat => _repeat;
  AudioPlayer get player => _player;
  bool get isPlaying => _player.playing;
  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  int get sleepTimerRemaining => _sleepTimerRemaining;
  bool get hasSleepTimer => _sleepTimer != null;

  AudioProvider() {
    _player.playerStateStream.listen((_) => notifyListeners());
    _player.positionStream.listen((_) => notifyListeners());
    _player.durationStream.listen((_) => notifyListeners());
    _player.currentIndexStream.listen((index) {
      if (index != null && index != _currentIndex) {
        _currentIndex = index;
        notifyListeners();
      }
    });
    _player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _onSongComplete();
      }
    });
  }

  Future<void> playSong(Song song, {List<Song>? queue, int? index}) async {
    if (queue != null) {
      _queue = List.from(queue);
      _currentIndex = index ?? queue.indexOf(song);
    } else if (!_queue.contains(song)) {
      _queue = [song];
      _currentIndex = 0;
    } else {
      _currentIndex = _queue.indexOf(song);
    }
    await _loadAndPlay();
  }

  Future<void> _loadAndPlay() async {
    if (_currentIndex < 0 || _currentIndex >= _queue.length) return;
    final song = _queue[_currentIndex];
    try {
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(song.uri)),
      );
      await _player.play();
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing song: $e');
    }
  }

  void _onSongComplete() {
    switch (_repeat) {
      case RepeatMode.one:
        _player.seek(Duration.zero);
        _player.play();
        break;
      case RepeatMode.all:
        if (_currentIndex < _queue.length - 1) {
          skipNext();
        } else {
          _currentIndex = 0;
          _loadAndPlay();
        }
        break;
      case RepeatMode.off:
        if (_currentIndex < _queue.length - 1) {
          skipNext();
        }
        break;
    }
  }

  Future<void> togglePlay() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    notifyListeners();
  }

  Future<void> skipNext() async {
    if (_queue.isEmpty) return;
    if (_shuffle) {
      _currentIndex =
          (DateTime.now().millisecondsSinceEpoch % _queue.length).abs();
    } else {
      _currentIndex = (_currentIndex + 1) % _queue.length;
    }
    await _loadAndPlay();
  }

  Future<void> skipPrevious() async {
    if (_queue.isEmpty) return;
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    await _loadAndPlay();
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  void cycleRepeat() {
    switch (_repeat) {
      case RepeatMode.off:
        _repeat = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeat = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeat = RepeatMode.off;
        break;
    }
    notifyListeners();
  }

  Future<void> addToQueue(Song song) async {
    _queue.add(song);
    notifyListeners();
  }

  void setSleepTimer(int minutes) {
    _cancelSleepTimer();
    _sleepTimerRemaining = minutes * 60;
    _sleepTimer = Timer(Duration(minutes: minutes), () {
      _player.pause();
      _cancelSleepTimer();
      notifyListeners();
    });
    _sleepCountdown = Timer.periodic(const Duration(seconds: 1), (_) {
      _sleepTimerRemaining--;
      notifyListeners();
      if (_sleepTimerRemaining <= 0) _cancelSleepTimer();
    });
    notifyListeners();
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepCountdown?.cancel();
    _sleepTimer = null;
    _sleepCountdown = null;
    _sleepTimerRemaining = 0;
    notifyListeners();
  }

  void cancelSleepTimer() => _cancelSleepTimer();

  @override
  void dispose() {
    _player.dispose();
    _cancelSleepTimer();
    super.dispose();
  }
}
