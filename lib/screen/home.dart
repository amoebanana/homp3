import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homp3/parts/filelist.dart';
import 'package:homp3/screen/screen_player.dart';
import 'package:homp3/screen/screen_playlist.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController tabController = TabController(length: 4, vsync: this);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    	systemNavigationBarColor: Colors.grey[900]
    ));
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: tabController,
              children: [
                ScreenPlayer(),
                ScreenPlaylist(),
                MyFileList(switchTab, "/storage/emulated/0/Nerv/mp3/sorted"),
                MyFileList(switchTab, "/storage/emulated/0/Nerv/mp3/unsorted"),
              ],
            ),
          ),
          TabBar(controller: tabController, tabs: [
            Tab(text: 'Player'),
            Tab(text: 'Playlists'),
            Tab(text: 'Sorted'),
            Tab(text: 'Unsorted'),
          ])
        ],
      )),
      // body: MyFileList(),
    );
  }
  void switchTab(int index) {
    tabController.animateTo(index);
  }
}
