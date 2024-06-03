import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homp3/mycontroller.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenPlayer extends GetView<MyController> {
  const ScreenPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return (controller.currentdir == "")
    ? Center(child: Text("play music first"))
    : Column(
      children: [
        AlbumArt(controller: controller),
        Expanded(child: Center()),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Obx(() => Text(_formatDuration(controller.position.value))),
            Obx(() => Expanded(
              child: Slider(
                    value: controller.position.value.inSeconds.toDouble(),
                    max: controller.duration.value.inSeconds.toDouble(),
                    onChanged: (value) {
                      controller.player.seek(Duration(seconds: value.toInt()));
                    },
                  ),
            )),
            Obx(() => Text(_formatDuration(controller.duration.value))),
          ]),
        ),
        Obx(() => Center(
              child: Text(controller
                  .LastShownSongmodels[controller.LastSongIndex.value].artist ?? "Unknown"),
            )),
        Obx(() => Center(
              child: Text(controller
                  .LastShownSongmodels[controller.LastSongIndex.value].title),
            )),
        UtilityRow(controller: controller),
        UserControlRow(controller: controller),
        const SizedBox(height: 20),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    return [duration.inMinutes, duration.inSeconds % 60]
        .map((seg) => seg.toString().padLeft(2, '0'))
        .join(':');
  }
}

class AlbumArt extends StatelessWidget {
  const AlbumArt({
    super.key,
    required this.controller,
  });

  final MyController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 370,
        child: Obx(() => QueryArtworkWidget(
            id: controller
                .LastShownSongmodels[controller.LastSongIndex.value].id,
            type: ArtworkType.AUDIO,
            quality: 100,
            size: 1000,
            artworkBorder: BorderRadius.zero,
            artworkWidth: 370,
            artworkHeight: 370,
            artworkFit: BoxFit.fitHeight,
            artworkQuality: FilterQuality.high,
            nullArtworkWidget: const Icon(
              Icons.music_note,
              size: 20,
            ))),
      ),
    );
  }
}

class UtilityRow extends StatelessWidget {
  const UtilityRow({
    super.key,
    required this.controller,
  });

  final MyController controller;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      IconButton(
          onPressed: () async {
            controller.deleteSong();
          },
          icon: const Icon(Icons.delete, color: Colors.white)),
      IconButton(
        icon: const Icon(Icons.play_circle_rounded, color: Color.fromARGB(255, 255, 0, 0)),
        onPressed: () async {
          String url = 'vnd.youtube://${controller.LastShownSongmodels[controller.LastSongIndex.value].composer}';
          // run youtube
          // if (await canLaunchUrl(Uri(path: url))) {
          //   await launchUrl(Uri(path: url));
          // }
          if (await canLaunch(url)) {
            await launch(url);
          }
          else {
            // run webbrowser
            String webUrl = 'https://www.youtube.com/watch?v=${controller.LastShownSongmodels[controller.LastSongIndex.value].composer}';
            if (await canLaunchUrl(Uri(path: webUrl))) {
              await launchUrl(Uri(path: webUrl));
            }
            else {
              throw 'Could not launch $webUrl';
            }
          }
        },
      )
    ]);
  }
}

class UserControlRow extends StatelessWidget {
  const UserControlRow({
    super.key,
    required this.controller,
  });

  final MyController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
            onPressed: controller.backward,
            icon: MyUserControlIcon(Icons.fast_rewind)),
        IconButton(
            onPressed: controller.skipbackward,
            icon: MyUserControlIcon(Icons.skip_previous)),
        Obx(() => IconButton(
              onPressed: controller.isPlaying.value
                  ? controller.player.pause
                  : controller.player.play,
              icon: MyUserControlIcon(controller.isPlaying.value
                  ? Icons.pause
                  : Icons.play_arrow),
            )),
        IconButton(
            onPressed: controller.skipforward,
            icon: MyUserControlIcon(Icons.skip_next)),
        IconButton(
            onPressed: controller.forward,
            icon: MyUserControlIcon(Icons.fast_forward)),
      ],
    );
  }
  Widget MyUserControlIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 32);
  }
}
