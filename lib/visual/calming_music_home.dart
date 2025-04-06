import 'package:flutter/material.dart';
import 'video_background.dart';
import 'music_category_page.dart';
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
        // Background video remains intact.
        VideoBackground(videoPath: "assets/videos/main_bg.mp4"),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 4,
            title: Text(
              "Calming Visuals & Music",
              style: const TextStyle(
                fontFamily: 'AtkinsonHyperlegible',
                color: Color(0xFFFFBF00), // Golden accent for the title
                fontSize: 22,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 3,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
          ),
          body: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (ctx, index) {
              final cat = categories[index];
              return CategoryTile(
                title: cat["title"],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => MusicCategoryPage(
                            title: cat["title"],
                            videoPath: cat["video"],
                          ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
