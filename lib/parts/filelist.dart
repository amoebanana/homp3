import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homp3/mycontroller.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MyFileList extends GetView<MyController> {
  MyFileList(this.switchTab, {super.key});
  final Function(int index) switchTab;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SongModel>>(
        future: OnAudioQuery().querySongs(
          ignoreCase: true,
          orderType: OrderType.DESC_OR_GREATER,
          sortType: SongSortType.DATE_ADDED,
          path: "/storage/emulated/0/mp3/unsorted",
        ),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No music found"),
            );
          } else {
            return ListView.builder(
                key: const PageStorageKey('filelist'),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 3),
                    child: ListTile(
                      // visualDensity: VisualDensity(horizontal: -4, vertical: VisualDensity.minimumDensity),
                      contentPadding: const EdgeInsets.all(0),
                      minLeadingWidth: 0,
                      minTileHeight: 0,
                      minVerticalPadding: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      title: Text(snapshot.data![index].title,
                          style: const TextStyle(
                            color: Colors.white,
                          )),
                      subtitle: Text(
                        snapshot.data![index].artist ?? "Unknown",
                      ),
                      leading: QueryArtworkWidget(
                        id: snapshot.data![index].id,
                        type: ArtworkType.AUDIO,
                        artworkBorder: BorderRadius.zero,
                        artworkWidth: 100,
                        artworkHeight: 200,
                        artworkFit: BoxFit.fitHeight,
                        nullArtworkWidget: const Icon(
                          Icons.music_note,
                          size: 20,
                        ),
                      ),
                      // trailing: const Icon(
                      //   Icons.play_arrow,
                      //   size: 32,
                      // ),
                      onTap: () {
                        controller.stop();
                        // update playlistscreen
                        controller.LastShownSongmodels.value = snapshot.data!.toList();
                        // update actual conc playlist
                        controller.playlist = ConcatenatingAudioSource(
                          children: controller.LastShownSongmodels.map((e) => AudioSource.uri(Uri.parse(e.data))).toList(),
                        );
                        controller.player.setAudioSource(controller.playlist);
                        controller.LastSongIndex.value = index;
                        // play music
                        controller.player.seek(Duration.zero, index: index);
                        controller.play();
                        switchTab(2);
                      },
                    ),
                  );
                });
          }
        });
  }
}
