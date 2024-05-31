import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homp3/mycontroller.dart';
import 'package:on_audio_query/on_audio_query.dart';

class ScreenPlaylist extends GetView<MyController> {
  const ScreenPlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
                key: const PageStorageKey('playlist'),
                itemCount: controller.LastShownSongmodels.length,
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
                      title: Text(controller.LastShownSongmodels[index].title,
                          style: const TextStyle(
                            color: Colors.white,
                          )),
                      subtitle: Text(
                        controller.LastShownSongmodels[index].artist ?? "Unknown",
                      ),
                      leading: QueryArtworkWidget(
                        id: controller.LastShownSongmodels[index].id,
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
                      onTap: () {},
                    ),
                  );
                }));
  }
}
