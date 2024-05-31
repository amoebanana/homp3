import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:homp3/main.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class MyController extends GetxController {
  final AudioPlayer player = AudioPlayer();
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;
  var isPlaying = false.obs;
  RxBool isLoadingDone = false.obs;
  RxList<Map<String, dynamic>> songs = <Map<String, dynamic>>[].obs;

  RxList<SongModel> LastShownSongmodels = <SongModel>[].obs;
  Rx<int> LastSongIndex = 0.obs;
  Rx<String> playback_title = "".obs;

  late ConcatenatingAudioSource playlist = ConcatenatingAudioSource(children:[]);

  void hitme() {
    playback_title.value = LastShownSongmodels[player.currentIndex!].title;
    print('hitme');
  }

  @override
  void onInit() {
    super.onInit();
    checkPermission();
    isLoadingDone.value = true;

    player.playerStateStream.listen((playerstate) {
      isPlaying.value = playerstate.playing;
      print(playerstate.processingState);
      // if (playerstate.processingState == ProcessingState.completed) {
      //   player.seekToNext();
      //   hitme();
      // }
    });
    player.durationStream.listen((d) {
      duration.value = d ?? Duration.zero;
    });
    player.positionStream.listen((p) {
      position.value = p;
    });
    player.currentIndexStream.listen((index) {
      if (index != null) {
        LastSongIndex.value = index;
        // playback_title.value = LastShownSongmodels[index].title;
        print('currentIndexStream: $index');
      }
    });
  }

  // Future<void> loadFiles() async {
  //   songs.clear();
  //   final Directory dir = Directory('/storage/emulated/0/mp3/unsorted');
  //   final List<FileSystemEntity> files = dir.listSync();
  //   for (var file in files) {
  //     Metadata metadata = await MetadataRetriever.fromFile(File(file.path));
  //     Uint8List? artwork = metadata.albumArt;
  //     songs.add({
  //       'path':file.path,
  //       'title':metadata.trackName ??  'unknown',
  //       'artist':metadata.trackArtistNames?[0] ?? 'unknown',
  //       'artwork':artwork,
  //     });
  //   }
  //   print('loadfiles done');
  // }

  Future<void> checkPermission() async {
    if (await Permission.audio.isGranted == false) {
      await Permission.audio.request();
    }
    if (await Permission.manageExternalStorage.isGranted == false) {
      await Permission.manageExternalStorage.request();
    }
  }


  void play() {
    player.play();
  }
  void stop() {
    player.stop();
  }
  void forward() {
    player.seekToNext();
    LastSongIndex.value = player.currentIndex!;
  }
  void backward() {
    player.seekToPrevious();
    LastSongIndex.value = player.currentIndex!;
  }
  void skipforward() {
    player.seek(player.position + const Duration(seconds: 10));
  }
  void skipbackward() {
    player.seek(player.position - const Duration(seconds: 10));
  }

  void deleteSong() {
    stop();
    File file = File(LastShownSongmodels[LastSongIndex.value].data);
    LastShownSongmodels.removeAt(LastSongIndex.value);
    playlist = ConcatenatingAudioSource(
      children: LastShownSongmodels.map((e) => AudioSource.uri(Uri.parse(e.data))).toList(),
    );
    var index = LastSongIndex.value;
    player.setAudioSource(playlist);
    LastSongIndex.value = index;
    player.seek(Duration.zero, index: LastSongIndex.value);
    play();
    file.delete();
  }
}
