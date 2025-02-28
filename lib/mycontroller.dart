import 'dart:io';
import 'dart:typed_data';
import 'dart:math'; // 랜덤 함수를 위해 필요한 패키지

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

  String currentdir = "";

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
  // 플레이리스트를 랜덤으로 섞는 함수
  void shufflePlaylist() {
    if (LastShownSongmodels.isNotEmpty) {
      LastShownSongmodels.shuffle();
      playlist = ConcatenatingAudioSource(
        children: LastShownSongmodels.map((e) => AudioSource.uri(Uri.parse(e.data))).toList(),
      );
      player.setAudioSource(playlist);
      LastSongIndex.value = 0; // 인덱스를 0으로 초기화
      print('플레이리스트를 랜덤으로 섞었습니다.');
    } else {
      print('플레이리스트가 비어 있습니다.');
    }
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
  Future<void> createDirectoryIfNotExists(String path) async {
  final directory = Directory(path);
  if (!await directory.exists()) {
    try {
      await directory.create(recursive: true);
      print('디렉토리 생성 완료: $path');
    } catch (e) {
      print('디렉토리 생성 실패: $e');
    }
  }
}
  void moveSong(String destination) async {
    // 현재 재생 중인 파일의 경로 가져오기
    stop();
    File file = File(LastShownSongmodels[LastSongIndex.value].data);
    String currentPath = file.path;
    String newPath;

    // 목적지 경로 설정
    if (destination == 's') {
      newPath = '/storage/emulated/0/Nerv/mp3/sorted/${currentPath.split('/').last}';
    } else if (destination == 'u') {
      newPath = '/storage/emulated/0/Nerv/mp3/unsorted/${currentPath.split('/').last}';
    } else if (destination == 'a') {
      newPath = '/storage/emulated/0/Nerv/mp3/archive/${currentPath.split('/').last}';
    } else if (destination == 'envT') {
      newPath = '/storage/emulated/0/Nerv/mp3/envT/${currentPath.split('/').last}';
    } else if (destination == 'envX') {
      newPath = '/storage/emulated/0/Nerv/mp3/envX/${currentPath.split('/').last}';
    } else if (destination == 'envD') {
      newPath = '/storage/emulated/0/Nerv/mp3/envD/${currentPath.split('/').last}';
    } else if (destination == 'envC') {
      newPath = '/storage/emulated/0/Nerv/mp3/envC/${currentPath.split('/').last}';
    } else {
      return;
    }
    await createDirectoryIfNotExists(newPath);

    try {
      stop();
      File file = File(LastShownSongmodels[LastSongIndex.value].data);
      LastShownSongmodels.removeAt(LastSongIndex.value);
      playlist = ConcatenatingAudioSource(
        children: LastShownSongmodels.map((e) => AudioSource.uri(Uri.parse(e.data))).toList(),
      );
      var index = LastSongIndex.value;
      player.setAudioSource(playlist);
      if (LastShownSongmodels.length == 0) {
        return;
      }
      else if (index >= LastShownSongmodels.length) {
        index = LastShownSongmodels.length - 1;
      }
      else {
        LastSongIndex.value = index;
      }
      player.seek(Duration.zero, index: LastSongIndex.value);
      play();
      file.renameSync(newPath); // 파일 이동
      // LastShownSongmodels.removeAt(LastSongIndex.value);
      // player.seek(Duration.zero, index: LastSongIndex.value);
      // player.seekToNext();
      // LastSongIndex.value = player.currentIndex!;
    } catch (e) {
      print('파일 이동 중 오류 발생: $e');
    }
  }
}
