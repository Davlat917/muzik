import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

final mainControllerProvider = ChangeNotifierProvider((ref) => MainController());

class MainController extends ChangeNotifier {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer audioPlayer = AudioPlayer();
  bool _hasPermission = false;
  int _currentIndex = 0;
  Duration _currentPosition = Duration.zero;
  Duration _songDuration = Duration.zero;
  List<SongModel> _songs = [];

  MainController() {
    requestPermission();
    audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });
    audioPlayer.durationStream.listen((duration) {
      _songDuration = duration ?? Duration.zero;
      notifyListeners();
    });
  }

  bool get hasPermission => _hasPermission;
  Duration get currentPosition => _currentPosition;
  Duration get songDuration => _songDuration;
  List<SongModel> get songs => _songs;
  bool get isPlaying => audioPlayer.playing;

  Future<void> requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      _hasPermission = true;
      notifyListeners();
    } else {
      _hasPermission = false;
      notifyListeners();
    }
  }

  Future<void> querySongs() async {
    _songs = await _audioQuery.querySongs(
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );
    notifyListeners();
  }

  Future<void> playSong(int index) async {
    try {
      await audioPlayer.setUrl(_songs[index].uri!);
      audioPlayer.play();
      _currentIndex = index;
      notifyListeners();
    } catch (e) {
      print('Error playing song: $e');
    }
  }

  Future<void> pauseSong() async {
    await audioPlayer.pause();
    notifyListeners();
  }

  Future<void> resumeSong() async {
    await audioPlayer.play();
    notifyListeners();
  }

  void nextSong() {
    if (_currentIndex < _songs.length - 1) {
      playSong(_currentIndex + 1);
    }
  }

  void previousSong() {
    if (_currentIndex > 0) {
      playSong(_currentIndex - 1);
    }
  }

  Future<void> seekSong(Duration position) async {
    await audioPlayer.seek(position);
    notifyListeners();
  }

  String formatDuration(Duration duration) {
    return duration.toString().split('.').first;
  }
}
