import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:homp3/mycontroller.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:url_launcher/url_launcher.dart';

class ScreenPlayer extends GetView<MyController> {
  const ScreenPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return (controller.LastShownSongmodels.isEmpty)
        ? Center(child: Text("play music first"))
        : Column(
            children: [
              Container(
                height: 20,
              ),
              // 썸네일과 곡 정보를 가로로 배치
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                height: 150,
                child: Row(
                  children: [
                    // 왼쪽: 썸네일 (크기 절반으로 축소)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: Obx(() => controller.LastShownSongmodels.isEmpty
                            ? Container(
                                color: Colors.grey[800],
                                child: Icon(Icons.music_note, size: 50),
                              )
                            : QueryArtworkWidget(
                                id: controller
                                    .LastShownSongmodels[controller.LastSongIndex.value].id,
                                type: ArtworkType.AUDIO,
                                quality: 100,
                                size: 500,
                                artworkBorder: BorderRadius.zero,
                                artworkWidth: 150,
                                artworkHeight: 150,
                                artworkFit: BoxFit.cover,
                                artworkQuality: FilterQuality.high,
                                nullArtworkWidget: Container(
                                  color: Colors.grey[800],
                                  child: Icon(Icons.music_note, size: 50),
                                ))),
                      ),
                    ),
                    SizedBox(width: 20),
                    // 오른쪽: 곡 정보 (세로 배치)
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 아티스트 (터치 가능)
                          Obx(() => GestureDetector(
                                onTap: () => _showEditArtistDialog(context),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: controller.LastShownSongmodels.isEmpty
                                      ? Text("No song selected", style: TextStyle(fontSize: 16))
                                      : Text(
                                          controller
                                                  .LastShownSongmodels[controller
                                                      .LastSongIndex.value]
                                                  .artist ??
                                              "Unknown",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ),
                              )),
                          // 제목 (터치 가능)
                          Obx(() => GestureDetector(
                                onTap: () => _showEditTitleDialog(context),
                                child: Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: controller.LastShownSongmodels.isEmpty
                                      ? Text("No song selected", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                                      : Text(
                                          controller
                                              .LastShownSongmodels[
                                                  controller.LastSongIndex.value]
                                              .title,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // 하단: Seek 바
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                const SizedBox(height: 10, width: 20),
                Obx(() => Text(_formatDuration(controller.position.value))),
                Obx(() => Expanded(
                      child: Slider(
                        value: controller.position.value.inSeconds.toDouble(),
                        max: controller.duration.value.inSeconds.toDouble(),
                        onChanged: (value) {
                          controller.player
                              .seek(Duration(seconds: value.toInt()));
                        },
                      ),
                    )),
                Obx(() => Text(_formatDuration(controller.duration.value))),
                const SizedBox(height: 10, width: 20),
              ]),
              Expanded(child: Center()),
              UtilityRow(controller: controller),
              UserControlRow(controller: controller),
            ],
          );
  }

  String _formatDuration(Duration duration) {
    return [duration.inMinutes, duration.inSeconds % 60]
        .map((seg) => seg.toString().padLeft(2, '0'))
        .join(':');
  }

  // 아티스트 편집 다이얼로그
  Future<void> _showEditArtistDialog(BuildContext context) async {
    if (controller.LastShownSongmodels.isEmpty) return;

    final currentArtist =
        controller.LastShownSongmodels[controller.LastSongIndex.value].artist ??
            "Unknown";
    final textController = TextEditingController(text: currentArtist);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('아티스트 정보 수정'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: '아티스트',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final newArtist = textController.text.trim();
              if (newArtist.isNotEmpty && newArtist != currentArtist) {
                Navigator.pop(context);
                await controller.updateSongArtist(newArtist);
              } else {
                Navigator.pop(context);
              }
            },
            child: Text('저장'),
          ),
        ],
      ),
    );
  }

  // 제목 편집 다이얼로그
  Future<void> _showEditTitleDialog(BuildContext context) async {
    if (controller.LastShownSongmodels.isEmpty) return;

    final currentTitle =
        controller.LastShownSongmodels[controller.LastSongIndex.value].title;
    final textController = TextEditingController(text: currentTitle);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('노래 제목 수정'),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: '제목',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final newTitle = textController.text.trim();
              if (newTitle.isNotEmpty && newTitle != currentTitle) {
                Navigator.pop(context);
                await controller.updateSongTitle(newTitle);
              } else {
                Navigator.pop(context);
              }
            },
            child: Text('저장'),
          ),
        ],
      ),
    );
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
        height: 300,
        child: Obx(() => controller.LastShownSongmodels.isEmpty
            ? Text("No song selected")
            : QueryArtworkWidget(
                id: controller
                    .LastShownSongmodels[controller.LastSongIndex.value].id,
                type: ArtworkType.AUDIO,
                quality: 100,
                size: 1000,
                artworkBorder: BorderRadius.zero,
                artworkWidth: 300,
                artworkHeight: 300,
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

class TagButtonRow extends GetView<MyController> {
  const TagButtonRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Column(
        children: [
          Obx(() => Wrap(
                spacing: 8, // 가로 간격
                runSpacing: 2, // 세로 간격
                alignment: WrapAlignment.center, // 가운데 정렬
                children: [
                  _buildTagButton('브금'),
                  _buildTagButton('주류'),
                  _buildTagButton('비주류'),
                  _buildTagButton('노동'),
                  _buildTagButton('평온'),
                  _buildTagButton('축축'),
                  _buildTagButton('달달'),
                  _buildTagButton('발랄'),
                  _buildTagButton('강력'),
                  _buildTagButton('노래방'),
                  _buildTagButton('2026.1'),
                  _buildTagButton('2026.2'),
                  _buildTagButton('2026.3'),
                  _buildTagButton('2026.4'),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildTagButton(String tag) {
    final isSelected = controller.currentTags.contains(tag);

    return FilterChip(
      label: Text(tag),
      selected: isSelected,
      selectedColor: Colors.blue.withOpacity(0.7),
      backgroundColor: Colors.grey.withOpacity(0.3),
      checkmarkColor: Colors.white,
      showCheckmark: false,
      onSelected: (bool selected) async {
        await controller.toggleTag(tag);
      },
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
    // 플레이리스트가 비어 있을 경우
    if (controller.LastShownSongmodels.isEmpty) {
      return Center(child: Text("더 이상 재생할 곡이 없습니다."));
    }
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(
              onPressed: () async {
                controller.deleteSong();
              },
              icon: const Icon(Icons.delete, color: Colors.white)),
          IconButton(
            icon: const Icon(Icons.play_circle_rounded,
                color: Color.fromARGB(255, 255, 0, 0)),
            onPressed: () async {
              String url =
                  'vnd.youtube://${controller.LastShownSongmodels[controller.LastSongIndex.value].composer}';
              // run youtube
              // if (await canLaunchUrl(Uri(path: url))) {
              //   await launchUrl(Uri(path: url));
              // }
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                // run webbrowser
                String webUrl =
                    'https://www.youtube.com/watch?v=${controller.LastShownSongmodels[controller.LastSongIndex.value].composer}';
                if (await canLaunchUrl(Uri(path: webUrl))) {
                  await launchUrl(Uri(path: webUrl));
                } else {
                  throw 'Could not launch $webUrl';
                }
              }
            },
          ),
          ElevatedButton(
            onPressed: () {
              controller.shufflePlaylist(); // 플레이리스트 섞기 버튼
            },
            child: Text("R"),
          ),
          ElevatedButton(
            onPressed: () {
              controller.moveSong('s'); // "toS" 버튼
            },
            child: Text("toS"),
          ),
          ElevatedButton(
            onPressed: () {
              controller.moveSong('u'); // "toU" 버튼
            },
            child: Text("toU"),
          ),
          ElevatedButton(
            onPressed: () {
              controller.moveSong('a'); // "toA" 버튼
            },
            child: Text("toA"),
          ),
        ]),
        TagButtonRow(),
      ],
    );
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
            icon: MyUserControlIcon(Icons.skip_previous)),
        IconButton(
            onPressed: controller.skipbackward,
            icon: MyUserControlIcon(Icons.fast_rewind)),
        Obx(() => IconButton(
              onPressed: controller.isPlaying.value
                  ? controller.player.pause
                  : controller.player.play,
              icon: MyUserControlIcon(
                  controller.isPlaying.value ? Icons.pause : Icons.play_arrow),
            )),
        IconButton(
            onPressed: controller.skipforward,
            icon: MyUserControlIcon(Icons.fast_forward)),
        IconButton(
            onPressed: controller.forward,
            icon: MyUserControlIcon(Icons.skip_next)),
      ],
    );
  }

  Widget MyUserControlIcon(IconData icon) {
    return Icon(icon, color: Colors.white, size: 32);
  }
}
