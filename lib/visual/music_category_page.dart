import 'package:flutter/material.dart';
import 'music_model.dart';
import 'video_background.dart';
import 'music_player_widget.dart';
import 'music_data.dart'; 

class MusicCategoryPage extends StatelessWidget {
  final String title; 
  final String videoPath; 

  const MusicCategoryPage({
    super.key,
    required this.title,
    required this.videoPath,
  });
  @override
  Widget build(BuildContext context) {
    
    final List<MusicModel> musicList = categoryMusicMap[title] ?? [];

    return Stack(
      children: [
        VideoBackground(videoPath: videoPath),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              title,
              style: const TextStyle(
                fontFamily: 'AtkinsonHyperlegible',
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: musicList.isEmpty
              ? const Center(
                  child: Text(
                    "No music found for this category.",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: musicList.length,
                  itemBuilder: (context, index) {
                    return MusicPlayerWidget(music: musicList[index]);
                  },
                ),
        ),
      ],
    );
  }
}
