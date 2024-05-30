import 'dart:io';
import 'dart:typed_data';

import 'package:audiotagger/audiotagger.dart';
import 'package:audiotagger/models/tag.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:get/get.dart';
import 'package:homp3/main.dart';
import 'package:permission_handler/permission_handler.dart';

class MyController extends GetxController {
  RxBool isLoadingDone = false.obs;
  RxList<Map<String, dynamic>> songs = <Map<String, dynamic>>[].obs;

  RxList<String> LastFileList = <String>[].obs;
  Rx<int> LastFileIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    checkPermission();
    isLoadingDone.value = true;
  }

  Future<void> loadFiles() async {
    songs.clear();
    final Directory dir = Directory('/storage/emulated/0/mp3/unsorted');
    final List<FileSystemEntity> files = dir.listSync();
    for (var file in files) {
      Metadata metadata = await MetadataRetriever.fromFile(File(file.path));
      Uint8List? artwork = metadata.albumArt;
      songs.add({
        'path':file.path,
        'title':metadata.trackName ??  'unknown',
        'artist':metadata.trackArtistNames?[0] ?? 'unknown',
        'artwork':artwork,
      });
    }
    print('loadfiles done');
  }

  Future<void> checkPermission() async {
    if (await Permission.audio.isGranted == false) {
      await Permission.audio.request();
    }
    if (await Permission.manageExternalStorage.isGranted == false) {
      await Permission.manageExternalStorage.request();
    }
  }
}
