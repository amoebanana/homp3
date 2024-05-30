import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homp3/mycontroller.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MyFileList extends GetView<MyController> {
  const MyFileList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SongModel>>(
        future: OnAudioQuery().querySongs(
          ignoreCase: true,
          orderType: OrderType.ASC_OR_SMALLER,
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
                        controller.LastFileList.value = snapshot.data!.map( (e) => e.data, ) .toList();
                        controller.LastFileIndex.value = index;
                      },
                    ),
                  );
                });
          }
        });
  }
}
