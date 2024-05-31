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
  late TabController tabController = TabController(length: 3, vsync: this);
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
              controller: tabController,
              children: [
                MyFileList(switchTab),
                ScreenPlaylist(),
                ScreenPlayer(),
              ],
            ),
          ),
          TabBar(controller: tabController, tabs: [
            Tab(text: 'Files'),
            Tab(text: 'Playlists'),
            Tab(text: 'Player'),
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
