// mind_dump_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class MindDumpPage extends StatefulWidget {
  const MindDumpPage({super.key});

  @override
  State<MindDumpPage> createState() => _MindDumpPageState();
}

class _MindDumpPageState extends State<MindDumpPage> {
  final TextEditingController _controller = TextEditingController();
  bool _showWriteSection = true;
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadLatestMindDump();
  }

  void _toggleWriteSection() =>
      setState(() => _showWriteSection = !_showWriteSection);

  void _speakText() async => await _flutterTts.speak(_controller.text);

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              _controller.text += ' ${val.recognizedWords}';
              _autoSaveMindDump();
            });
          },
        );
      }
    }
  }

  Future<void> _loadLatestMindDump() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection('mind_dumps')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      _controller.text = data['content'] ?? '';
      setState(() {});
    }
  }

  void _insertImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final path = picked.path;
      imagePaths.add(path);
      _controller.text += '\n\n![Image]($path)\n\n';
      _autoSaveMindDump();
      setState(() {});
    }
  }

  Future<void> _autoSaveMindDump() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;
    await FirebaseFirestore.instance.collection('mind_dumps').add({
      'content': content,
      'timestamp': Timestamp.now(),
    });
  }

  Widget _buildMarkdownPreview() {
    return MarkdownBody(
      data: _controller.text.replaceAll('\n', '  \n'),
      imageBuilder: (uri, title, alt) {
        final file = File.fromUri(uri);
        return Image.file(file);
      },
      styleSheet: MarkdownStyleSheet.fromTheme(
        Theme.of(context),
      ).copyWith(p: const TextStyle(color: Colors.white)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Mind Dump'),
        backgroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    "📝 Write/Edit",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showWriteSection ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                    ),
                    onPressed: _toggleWriteSection,
                  ),
                ],
              ),

              if (_showWriteSection)
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.format_bold,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _controller.text += '*bold*';
                                _autoSaveMindDump();
                                setState(() {});
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.format_italic,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _controller.text += '_italic';
                                _autoSaveMindDump();
                                setState(() {});
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.image,
                                color: Colors.white,
                              ),
                              onPressed: _insertImage,
                            ),
                            IconButton(
                              icon: const Icon(Icons.mic, color: Colors.white),
                              onPressed: _startListening,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.volume_up,
                                color: Colors.white,
                              ),
                              onPressed: _speakText,
                            ),
                          ],
                        ),
                        EmojiPicker(
                          onEmojiSelected: (cat, emoji) {
                            _controller.text += emoji.emoji;
                            _autoSaveMindDump();
                            setState(() {});
                          },
                          config: const Config(
                            emojiViewConfig: EmojiViewConfig(emojiSizeMax: 32),
                            bottomActionBarConfig: BottomActionBarConfig(
                              showBackspaceButton: true,
                            ),
                          ),
                        ),
                        TextField(
                          controller: _controller,
                          onChanged: (val) {
                            _autoSaveMindDump();
                            setState(() {});
                          },
                          maxLines: null,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Dump your thoughts...',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "👀 Preview",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(child: _buildMarkdownPreview()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}