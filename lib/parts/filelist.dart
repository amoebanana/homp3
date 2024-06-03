import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homp3/mycontroller.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MyFileList extends GetView<MyController> {
  MyFileList(this.switchTab, this.dirpath, {super.key});
  final String dirpath;
  final Function(int index) switchTab;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: FutureBuilder<List<SongModel>>(
          future: OnAudioQuery().querySongs(
            ignoreCase: true,
            orderType: OrderType.DESC_OR_GREATER,
            sortType: SongSortType.DATE_ADDED,
            path: dirpath,
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
              return lvFilelistUnsorted(snapshot);
            }
          }),
    );
  }

  ListView lvFilelistUnsorted(AsyncSnapshot<List<SongModel>> snapshot) {
    List<SongModel> filteredSnapshot = snapshot.data!.where((song)=>song.size != 0).toList();
    return ListView.builder(
              key: const PageStorageKey('filelist'),
              itemCount: filteredSnapshot.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 3),
                  child: ListTile(
                    // visualDensity: VisualDensity(horizontal: -4, vertical: VisualDensity.minimumDensity),
                    contentPadding: const EdgeInsets.all(8),
                    minLeadingWidth: 0,
                    minTileHeight: 0,
                    minVerticalPadding: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    title: Text(
                      filteredSnapshot[index].title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        )),
                    subtitle: Text(
                      filteredSnapshot[index].artist ?? "Unknown",
                    ),
                    leading: AspectRatio(
                      aspectRatio: 1,
                      child: QueryArtworkWidget(
                        id: filteredSnapshot[index].id,
                        type: ArtworkType.AUDIO,
                        artworkBorder: BorderRadius.zero,
                        quality: 100,
                        size: 1000,
                        artworkWidth: 100,
                        artworkHeight: 100,
                        artworkFit: BoxFit.fitHeight,
                        nullArtworkWidget: const Icon(
                          Icons.music_note,
                          size: 20,
                        ),
                      ),
                    ),
                    // trailing: const Icon(
                    //   Icons.play_arrow,
                    //   size: 32,
                    // ),
                    onTap: () {
                      controller.stop();
                      // update playlistscreen
                      controller.LastShownSongmodels.value = filteredSnapshot.toList();
                      // update actual conc playlist
                      controller.playlist = ConcatenatingAudioSource(
                        children: controller.LastShownSongmodels.map((e) => AudioSource.uri(Uri.parse(e.data))).toList(),
                      );
                      controller.player.setAudioSource(controller.playlist);
                      controller.LastSongIndex.value = index;
                      // play music
                      controller.player.seek(Duration.zero, index: index);
                      controller.play();
                      controller.currentdir = dirpath;
                      switchTab(3);
                    },
                  ),
                );
              });
  }
}
