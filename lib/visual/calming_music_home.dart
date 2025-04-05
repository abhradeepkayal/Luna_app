import 'package:flutter/material.dart';
import 'video_background.dart';
import 'music_category_page.dart';
//import '../visual/music_player_widget.dart';
// import '../visuals/music_model.dart';
import 'category_tile.dart';

class CalmingMusicHome extends StatelessWidget {
  CalmingMusicHome({super.key});
  final List<Map<String, dynamic>> categories = [
    {"title": "Focus", "video": "assets/videos/focus_bg.mp4"},
    {"title": "Sleep", "video": "assets/videos/sleep_bg.mp4"},
    {"title": "Meditation", "video": "assets/videos/meditation_bg.mp4"},
    {"title": "Soothing", "video": "assets/videos/soothing_bg.mp4"},
    {"title": "Spiritual", "video": "assets/videos/spiritual_bg.mp4"},
    {"title": "Reading", "video": "assets/videos/reading_bg.mp4"},
    {"title": "Binaural Beats", "video": "assets/videos/binaural_bg.mp4"},
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background video
        VideoBackground(videoPath: "assets/videos/main_bg.mp4"),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text("Calming Visuals & Music",
                style: TextStyle(
                  fontFamily: 'AtkinsonHyperlegible',
                  color: Colors.white,
                )),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (ctx, index) {
              final cat = categories[index];
              return CategoryTile(
                title: cat["title"],
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => MusicCategoryPage(
                      title: cat["title"],
                      videoPath: cat["video"],
                    ),
                  ));
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
