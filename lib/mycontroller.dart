import 'dart:io';
import 'dart:typed_data';
import 'dart:math'; // 랜덤 함수를 위해 필요한 패키지

import 'package:get/get.dart';
import 'package:homp3/main.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

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

  late ConcatenatingAudioSource playlist =
      ConcatenatingAudioSource(children: []);

  String currentdir = "";

  void hitme() {
    playback_title.value = LastShownSongmodels[player.currentIndex!].title;
    print('hitme');
  }

  // 토스트 메시지 표시 함수
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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
        loadTags(); // 새 노래로 변경될 때 태그 로드
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
        children:
            LastShownSongmodels.map((e) => AudioSource.uri(Uri.parse(e.data)))
                .toList(),
      );
      player.setAudioSource(playlist);
      LastSongIndex.value = 0; // 인덱스를 0으로 초기화
      loadTags(); // 셔플 후 현재 곡의 태그 로드
      showToast('플레이리스트를 랜덤으로 섞었습니다 🎵');
      print('플레이리스트를 랜덤으로 섞었습니다.');
    } else {
      showToast('플레이리스트가 비어 있습니다');
      print('플레이리스트가 비어 있습니다.');
    }
  }

  void deleteSong() {
    stop();
    File file = File(LastShownSongmodels[LastSongIndex.value].data);
    LastShownSongmodels.removeAt(LastSongIndex.value);
    playlist = ConcatenatingAudioSource(
      children:
          LastShownSongmodels.map((e) => AudioSource.uri(Uri.parse(e.data)))
              .toList(),
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
      newPath =
          '/storage/emulated/0/Nerv/mp3/sorted/${currentPath.split('/').last}';
    } else if (destination == 'u') {
      newPath =
          '/storage/emulated/0/Nerv/mp3/unsorted/${currentPath.split('/').last}';
    } else if (destination == 'a') {
      newPath =
          '/storage/emulated/0/Nerv/mp3/archive/${currentPath.split('/').last}';
    } else {
      return;
    }

    try {
      // 플레이리스트에서 현재 노래 제거
      LastShownSongmodels.removeAt(LastSongIndex.value);

      // 파일 이동 - 플레이리스트 처리보다 먼저 실행
      file.renameSync(newPath);

      // 플레이리스트 업데이트
      playlist = ConcatenatingAudioSource(
        children:
            LastShownSongmodels.map((e) => AudioSource.uri(Uri.parse(e.data)))
                .toList(),
      );

      var index = LastSongIndex.value;

      // 플레이리스트가 비었는지 확인
      if (LastShownSongmodels.isEmpty) {
        // 플레이리스트가 비었으면 재생 중지 상태로 유지
        player.setAudioSource(playlist);
        return;
      }

      // 인덱스 조정
      if (index >= LastShownSongmodels.length) {
        index = LastShownSongmodels.length - 1;
      }

      // 재생 시작
      player.setAudioSource(playlist);
      LastSongIndex.value = index;
      player.seek(Duration.zero, index: LastSongIndex.value);
      play();
    } catch (e) {
      print('파일 이동 중 오류 발생: $e');
    }
  }

  final Audiotagger tagger = Audiotagger();
  RxList<String> currentTags = <String>[].obs;

  // 현재 파일의 장르 태그 읽기
  Future<void> loadTags() async {
    if (LastShownSongmodels.isEmpty ||
        LastSongIndex.value >= LastShownSongmodels.length) {
      currentTags.clear();
      return;
    }

    final filePath = LastShownSongmodels[LastSongIndex.value].data;
    final tags = await tagger.readTags(path: filePath);

    if (tags != null && tags.genre != null && tags.genre!.isNotEmpty) {
      currentTags.value = tags.genre!.split(',').map((e) => e.trim()).toList();
    } else {
      currentTags.clear();
    }
  }

  // 태그 토글 (추가/제거)
  Future<bool> toggleTag(String tag) async {
    if (LastShownSongmodels.isEmpty ||
        LastSongIndex.value >= LastShownSongmodels.length) {
      return false;
    }

    final filePath = LastShownSongmodels[LastSongIndex.value].data;
    final tags = await tagger.readTags(path: filePath);

    if (tags == null) {
      return false;
    }

    // 현재 태그 목록 가져오기
    List<String> genreTags = [];
    if (tags.genre != null && tags.genre!.isNotEmpty) {
      genreTags = tags.genre!.split(',').map((e) => e.trim()).toList();
    }

    // 태그 토글
    if (genreTags.contains(tag)) {
      genreTags.remove(tag);
    } else {
      genreTags.add(tag);
    }

    // 최종 태그 문자열 만들기
    final newGenre = genreTags.join(', ');

    // 새 태그 저장
    final newTag = Tag(
        title: tags.title,
        artist: tags.artist,
        album: tags.album,
        genre: newGenre,
        year: tags.year,
        artwork: tags.artwork,
        comment: tags.comment,
        discNumber: tags.discNumber,
        trackNumber: tags.trackNumber);

    final result = await tagger.writeTags(path: filePath, tag: newTag);

    // null 체크 추가
    final success = result == true;

    if (success) {
      // UI 업데이트를 위해 현재 태그 목록 갱신
      currentTags.value = genreTags;
      return true;
    }

    return false;
  }
  // 제목 수정 메서드
Future<bool> updateSongTitle(String newTitle) async {
  if (LastShownSongmodels.isEmpty || LastSongIndex.value >= LastShownSongmodels.length) {
    return false;
  }
  
  final filePath = LastShownSongmodels[LastSongIndex.value].data;
  final tags = await tagger.readTags(path: filePath);
  
  if (tags == null) {
    return false;
  }
  
  // 기존 태그를 유지하되 title만 변경
  final newTag = Tag(
    title: newTitle,
    artist: tags.artist,
    album: tags.album,
    genre: tags.genre,
    year: tags.year,
    artwork: tags.artwork,
    comment: tags.comment,
    discNumber: tags.discNumber,
    trackNumber: tags.trackNumber
  );
  
  final result = await tagger.writeTags(
    path: filePath, 
    tag: newTag
  );
  
  final success = result == true;
  
  if (success) {
    // 현재 모델 업데이트 (메모리상)
    SongModel updatedSong = LastShownSongmodels[LastSongIndex.value];
    // SongModel은 immutable할 수 있어 직접 수정이 불가능할 수 있음
    // 필요시 OnAudioQuery를 통해 다시 정보를 가져와야 할 수 있음
    
    // 필요한 UI 업데이트가 있으면 여기서 처리
    return true;
  }
  
  return false;
}

// 아티스트 수정 메서드
Future<bool> updateSongArtist(String newArtist) async {
  if (LastShownSongmodels.isEmpty || LastSongIndex.value >= LastShownSongmodels.length) {
    return false;
  }
  
  final filePath = LastShownSongmodels[LastSongIndex.value].data;
  final tags = await tagger.readTags(path: filePath);
  
  if (tags == null) {
    return false;
  }
  
  // 기존 태그를 유지하되 artist만 변경
  final newTag = Tag(
    title: tags.title,
    artist: newArtist,
    album: tags.album,
    genre: tags.genre,
    year: tags.year,
    artwork: tags.artwork,
    comment: tags.comment,
    discNumber: tags.discNumber,
    trackNumber: tags.trackNumber
  );
  
  final result = await tagger.writeTags(
    path: filePath, 
    tag: newTag
  );
  
  final success = result == true;
  
  if (success) {
    // 필요한 UI 업데이트가 있으면 여기서 처리
    return true;
  }
  
  return false;
}
}
