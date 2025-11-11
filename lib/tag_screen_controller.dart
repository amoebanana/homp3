// tag_screen_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:audiotagger/audiotagger.dart';
import 'package:homp3/mycontroller.dart';
import 'package:just_audio/just_audio.dart';

class TagScreenController extends GetxController {
  final MyController mainController = Get.find<MyController>();
  final OnAudioQuery audioQuery = OnAudioQuery();
  final Audiotagger tagger = Audiotagger();
  
  // 플레이어 화면으로 이동하기 위한 콜백
  VoidCallback? goToPlayerScreen;
  
  void setNavigationCallback(VoidCallback callback) {
    goToPlayerScreen = callback;
  }
  
  RxList<String> allTags = <String>[].obs;
  RxList<String> selectedTags = <String>[].obs;
  RxList<SongModel> filteredSongs = <SongModel>[].obs;
  RxBool isLoading = true.obs;
  
  // 폴더 경로 목록
  final List<String> folderPaths = [
    '/storage/emulated/0/Nerv/mp3/sorted',
    '/storage/emulated/0/Nerv/mp3/unsorted',
    '/storage/emulated/0/Nerv/mp3/archive'
  ];
  
  @override
  void onInit() {
    super.onInit();
    print("TagScreenController - onInit 시작");
    loadAllTags();
    print("TagScreenController - onInit 종료");
  }
  
  // 모든 폴더에서 모든 태그 로드
  Future<void> loadAllTags() async {
    print("loadAllTags 시작");
    isLoading.value = true;
    allTags.clear();
    Set<String> uniqueTags = {};
    
    try {
      for (String folderPath in folderPaths) {
        print("폴더 검색: $folderPath");
        try {
          List<SongModel> songs = await audioQuery.querySongs(
            path: folderPath,
            ignoreCase: true,
            orderType: OrderType.DESC_OR_GREATER,
            sortType: SongSortType.DATE_ADDED,
          );
          print("찾은 노래 수: ${songs.length}");
          
          for (SongModel song in songs) {
            if (song.size <= 0) continue; // 빈 파일 무시
            
            try {
              final tags = await tagger.readTags(path: song.data);
              if (tags != null && tags.genre != null && tags.genre!.isNotEmpty) {
                final songTags = tags.genre!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
                uniqueTags.addAll(songTags);
              }
            } catch (e) {
              print("태그 읽기 오류: $e");
            }
          }
        } catch (e) {
          print("폴더 검색 오류: $e");
        }
      }
      
      allTags.value = uniqueTags.toList()..sort();
      print("로드된 태그: ${allTags.value}");
    } catch (e) {
      print("태그 로드 중 오류: $e");
    } finally {
      isLoading.value = false;
      print("loadAllTags 종료");
    }
  }
  
  // 태그 토글 (선택/해제)
  void toggleTag(String tag) {
    print("태그 토글: $tag");
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
    
    filterSongsByTags();
  }
  
  // 선택된 태그로 노래 필터링
  Future<void> filterSongsByTags() async {
    print("filterSongsByTags 시작: ${selectedTags.value}");
    if (selectedTags.isEmpty) {
      filteredSongs.clear();
      return;
    }
    
    isLoading.value = true;
    List<SongModel> matchingSongs = [];
    
    for (String folderPath in folderPaths) {
      try {
        List<SongModel> songs = await audioQuery.querySongs(
          path: folderPath,
          ignoreCase: true,
          orderType: OrderType.DESC_OR_GREATER,
          sortType: SongSortType.DATE_ADDED,
        );
        
        for (SongModel song in songs) {
          if (song.size <= 0) continue; // 빈 파일 무시
          
          try {
            final tags = await tagger.readTags(path: song.data);
            if (tags != null && tags.genre != null && tags.genre!.isNotEmpty) {
              final songTags = tags.genre!.split(',').map((e) => e.trim()).toSet();
              
              // 선택된 모든 태그가 노래에 포함되어 있는지 확인
              bool allTagsIncluded = true;
              for (String selectedTag in selectedTags) {
                if (!songTags.contains(selectedTag)) {
                  allTagsIncluded = false;
                  break;
                }
              }
              
              if (allTagsIncluded) {
                matchingSongs.add(song);
              }
            }
          } catch (e) {
            print("태그 읽기 오류: $e");
          }
        }
      } catch (e) {
        print("필터링 중 오류: $e");
      }
    }
    
    filteredSongs.value = matchingSongs;
    print("필터링된 노래 수: ${filteredSongs.length}");
    isLoading.value = false;
  }
  
  // 필터링된 노래 재생
  void playFilteredSongs() {
    print("playFilteredSongs 시작");
    if (filteredSongs.isEmpty) return;
    
    mainController.stop();
    mainController.LastShownSongmodels.value = filteredSongs.toList();
    mainController.playlist = ConcatenatingAudioSource(
      children: mainController.LastShownSongmodels.map((e) => 
        AudioSource.uri(Uri.parse(e.data))
      ).toList(),
    );
    
    mainController.player.setAudioSource(mainController.playlist);
    mainController.LastSongIndex.value = 0;
    mainController.player.seek(Duration.zero, index: 0);
    mainController.play();
    mainController.loadTags();
    
    // Player 탭으로 전환
    if (goToPlayerScreen != null) {
      goToPlayerScreen!();
    }
    print("playFilteredSongs 종료");
  }
}