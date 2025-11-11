// tag_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:homp3/tag_screen_controller.dart';

class TagScreen extends StatelessWidget {
  final VoidCallback goToPlayerScreen;
  
  TagScreen({required this.goToPlayerScreen, Key? key}) : super(key: key);
  
  final TagScreenController controller = Get.put(TagScreenController());
  
  @override
  Widget build(BuildContext context) {
    // 네비게이션 콜백 설정
    controller.setNavigationCallback(goToPlayerScreen);
    
    return Column(
      children: [
        // 첫 번째 행: 모든 태그 표시
        Container(
          height: 120, // 높이 고정
          padding: EdgeInsets.all(8),
          child: Obx(() => controller.isLoading.value && controller.allTags.isEmpty
            ? Center(child: CircularProgressIndicator())
            : controller.allTags.isEmpty
              ? Center(child: Text('찾은 태그가 없습니다. 먼저 음악에 태그를 추가해주세요.'))
              : _buildTagsSection()
          ),
        ),
        
        // 구분선
        Divider(thickness: 1, height: 1),
        
        // 두 번째 행: 필터링된 노래 목록
        Expanded(
          child: Obx(() => controller.selectedTags.isEmpty
            ? Center(child: Text('태그를 선택하여 노래를 필터링하세요'))
            : controller.isLoading.value
              ? Center(child: CircularProgressIndicator())
              : controller.filteredSongs.isEmpty
                ? Center(child: Text('선택한 태그를 모두 포함하는 노래가 없습니다'))
                : _buildSongsList()
          ),
        ),
        
        // 세 번째 행: 재생 버튼
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Obx(() => ElevatedButton.icon(
            icon: Icon(Icons.play_arrow),
            label: Text('선택된 노래 재생하기 (${controller.filteredSongs.length}곡)'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: controller.filteredSongs.isEmpty 
              ? null 
              : controller.playFilteredSongs,
          )),
        ),
      ],
    );
  }
  
  Widget _buildTagsSection() {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controller.allTags.map((tag) => _buildTagChip(tag)).toList(),
      ),
    );
  }
  
  Widget _buildTagChip(String tag) {
    return Obx(() => FilterChip(
      label: Text(tag),
      selected: controller.selectedTags.contains(tag),
      selectedColor: Colors.blue.withOpacity(0.7),
      backgroundColor: Colors.grey.withOpacity(0.3),
      checkmarkColor: Colors.white,
      onSelected: (_) => controller.toggleTag(tag),
    ));
  }
  
  Widget _buildSongsList() {
    return ListView.builder(
      itemCount: controller.filteredSongs.length,
      itemBuilder: (context, index) {
        final song = controller.filteredSongs[index];
        return ListTile(
          leading: QueryArtworkWidget(
            id: song.id,
            type: ArtworkType.AUDIO,
            nullArtworkWidget: Icon(Icons.music_note),
          ),
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            song.artist ?? 'Unknown Artist',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}