import 'package:flutter/material.dart';
import 'package:homp3/parts/filelist.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late TabController tabController = TabController(length: 2, vsync: this);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                // const Placeholder(),
                MyFileList(),
                // MyFileList(),
                // const Text('Songs'),
                const Text('Songs'),
              ],
            ),
          ),
          TabBar(controller: tabController, tabs: [
            Tab(text: 'Files'),
            Tab(text: 'Songs'),

          ])
        ],
      )),
      // body: MyFileList(),
    );
  }
}
