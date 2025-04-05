import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'music_model.dart';

class MusicPlayerWidget extends StatefulWidget {
  final MusicModel music;

  const MusicPlayerWidget({super.key, required this.music});

  @override
  State<MusicPlayerWidget> createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

 Future<void> _initAudio() async {
  try {
    await _player.setAsset(widget.music.filePath);

    // Listen to duration updates
    _player.durationStream.listen((dur) {
      if (dur != null) {
        setState(() => _duration = dur);
      }
    });

    _player.positionStream.listen((pos) {
      setState(() => _position = pos);
    });
  } catch (e) {
    print("Error loading audio: $e");
  }
}


  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(
          widget.music.name,
          style: TextStyle(
            fontFamily: 'OpenDyslexic',
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          "${_formatTime(_position)} / ${_formatTime(_duration)}",
          style: TextStyle(color: Colors.white70),
        ),
        trailing: StreamBuilder<PlayerState>(
  stream: _player.playerStateStream,
  builder: (context, snapshot) {
    final playerState = snapshot.data;
    final processingState = playerState?.processingState;
    final playing = playerState?.playing;

    if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
      return const CircularProgressIndicator();
    } else if (playing != true) {
      return IconButton(
        icon: Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
        onPressed: _player.play,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        icon: Icon(Icons.pause_circle_filled, color: Colors.white, size: 30),
        onPressed: _player.pause,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.replay, color: Colors.white, size: 30),
        onPressed: () => _player.seek(Duration.zero),
      );
    }
  },
)

      ),
    );
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
