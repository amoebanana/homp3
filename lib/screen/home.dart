import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart'; // Get 패키지 추가
import 'package:homp3/parts/filelist.dart';
import 'package:homp3/screen/screen_player.dart';
import 'package:homp3/screen/screen_playlist.dart';
import 'package:homp3/screen/screen_tag.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  late List<Widget> _screens; // 여기서는 초기화하지 않습니다

  @override
  void initState() {
    super.initState();
    // initState에서 _screens 초기화
    _screens = [
      ScreenPlayer(),
      ScreenPlaylist(),
      TagScreen(goToPlayerScreen: _goToPlayerScreen),
      MyFileList(_switchTab, "/storage/emulated/0/Nerv/mp3/sorted"),
      MyFileList(_switchTab, "/storage/emulated/0/Nerv/mp3/unsorted"),
    ];
  }

  // 플레이어 화면으로 이동하는 함수
  void _goToPlayerScreen() {
    setState(() {
      _selectedIndex = 0;
    });
  }

  // 탭 전환 함수
  void _switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.grey[900]
    ));
    return Scaffold(
      body: SafeArea(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // 5개 이상의 아이템 지원
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.play_circle), label: 'Player'),
          BottomNavigationBarItem(icon: Icon(Icons.playlist_play), label: 'Playlists'),
          BottomNavigationBarItem(icon: Icon(Icons.tag), label: 'Tags'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Sorted'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_open), label: 'Unsorted'),
        ],
      ),
    );
  }
}