import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayFromUrlPage extends StatefulWidget {
  const PlayFromUrlPage({Key? key}) : super(key: key);

  @override
  _PlayFromUrlPageState createState() => _PlayFromUrlPageState();
}

class _PlayFromUrlPageState extends State<PlayFromUrlPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String _currentUrl = '';

  void _playPause(String url) async {
    try {
      if (_isPlaying && _currentUrl == url) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.setSourceUrl(url);
        await _audioPlayer.resume();
      }
      setState(() {
        _isPlaying = !_isPlaying;
        _currentUrl = url;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    const List<String> urls = [
      'http://muz.uz/uploads/mservice/3a40b8cc3c84a9e4607bd2173318f28d.mp3',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Play MP3 from URL"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Press the button to play/pause the audio from URL',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            for (var url in urls)
              ElevatedButton(
                onPressed: () => _playPause(url),
                child: Text(
                  _isPlaying && _currentUrl == url ? 'Pause' : 'Play ${urls.indexOf(url) + 1}',
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
