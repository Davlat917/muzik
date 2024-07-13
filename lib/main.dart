import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muzikapp/ctr_main.dart';
import 'package:muzikapp/playurl.dart';
import 'package:on_audio_query/on_audio_query.dart';

void main() {
  runApp(const ProviderScope(child: MaterialApp(home: Songs())));
}

class Songs extends ConsumerWidget {
  const Songs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctr = ref.read(mainControllerProvider);
    ref.watch(mainControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("OnAudioQuery Example"),
        elevation: 2,
      ),
      body: Center(
        child: !ctr.hasPermission
            ? noAccessToLibraryWidget(context, ref)
            : FutureBuilder<void>(
                future: ctr.querySongs(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // return const CircularProgressIndicator();
                  }

                  if (ctr.songs.isEmpty) {
                    return const Text("Nothing found!");
                  }

                  return ListView.builder(
                    itemCount: ctr.songs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: QueryArtworkWidget(
                          id: ctr.songs[index].id,
                          type: ArtworkType.AUDIO,
                          nullArtworkWidget: const Icon(Icons.music_note),
                        ),
                        title: Text(ctr.songs[index].title),
                        subtitle: Text(ctr.songs[index].artist == '<unknown>'
                            ? ''
                            : "${ctr.songs[index].artist}"),
                        trailing: const Icon(Icons.play_arrow),
                        onTap: () => ctr.playSong(index),
                      );
                    },
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 150,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Slider(
              min: 0,
              max: ctr.songDuration.inSeconds.toDouble(),
              value: ctr.currentPosition.inSeconds.toDouble(),
              onChanged: (value) async {
                await ctr.audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ctr.formatDuration(ctr.currentPosition)),
                  Text(ctr.formatDuration(ctr.songDuration)),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  onPressed: ctr.previousSong,
                ),
                IconButton(
                  icon: ctr.isPlaying ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
                  onPressed: ctr.isPlaying ? ctr.pauseSong : ctr.resumeSong,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  onPressed: ctr.nextSong,
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayFromUrlPage()));
      }),
    );
  }

  Widget noAccessToLibraryWidget(BuildContext context, WidgetRef ref) {
    final ctr = ref.read(mainControllerProvider);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.redAccent.withOpacity(0.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Application doesn't have access to the library"),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await ctr.requestPermission();
              if (!ctr.hasPermission) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Permission Denied'),
                    content: const Text('Storage permission is required to access songs.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
            child: const Text("Allow"),
          ),
        ],
      ),
    );
  }
}
