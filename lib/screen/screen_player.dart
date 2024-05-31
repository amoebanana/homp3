import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homp3/mycontroller.dart';

class ScreenPlayer extends GetView<MyController> {
  const ScreenPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => Slider(
              value: controller.position.value.inSeconds.toDouble(),
              max: controller.duration.value.inSeconds.toDouble(),
              onChanged: (value) {
                controller.player.seek(Duration(seconds: value.toInt()));
              },
            )),
        Obx(() => Text(_formatDuration(controller.position.value))),
        Obx(() => Text(_formatDuration(controller.duration.value))),
        Obx(() => Center(
              child: Text(controller.LastShownSongmodels[controller.LastSongIndex.value].title),
            )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () async {
                    controller.deleteSong();
                },
                icon: const Icon(Icons.delete, color: Colors.white)),
          ]
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: controller.backward,
                icon: const Icon(Icons.fast_rewind)),
            IconButton(
                onPressed: controller.skipbackward,
                icon: const Icon(Icons.skip_previous)),
            Obx(() => IconButton(
                  onPressed: controller.isPlaying.value
                      ? controller.player.pause
                      : controller.player.play,
                  icon: Icon(
                      controller.isPlaying.value ? Icons.pause : Icons.play_arrow),
                )),
            IconButton(
                onPressed: controller.skipforward,
                icon: const Icon(Icons.skip_next)),
            IconButton(
                onPressed: controller.forward,
                icon: const Icon(Icons.fast_forward)),
          ],
        )
      ],
    );
  }

  String _formatDuration(Duration duration) {
    return [duration.inMinutes, duration.inSeconds % 60]
        .map((seg) => seg.toString().padLeft(2, '0'))
        .join(':');
  }
}
