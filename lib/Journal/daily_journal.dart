// daily_journal_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class DailyJournalPage extends StatefulWidget {
  const DailyJournalPage({super.key});

  @override
  State<DailyJournalPage> createState() => _DailyJournalPageState();
}

class _DailyJournalPageState extends State<DailyJournalPage> {
  final TextEditingController _controller = TextEditingController();
  String selectedMood = '';
  bool _showWriteSection = true;
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadTodayJournal();
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
            });
          },
        );
      }
    }
  }

  Future<void> _loadTodayJournal() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final snapshot =
        await FirebaseFirestore.instance
            .collection('daily_journals')
            .where('date', isEqualTo: today)
            .limit(1)
            .get();
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      _controller.text = data['content'] ?? '';
      selectedMood = data['mood'] ?? '';
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
      setState(() {});
    }
  }

  Future<void> _saveJournal() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (now.isAfter(endOfDay)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can't edit the journal after today."),
        ),
      );
      return;
    }

    final snapshot =
        await FirebaseFirestore.instance
            .collection('daily_journals')
            .where('date', isEqualTo: today)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('daily_journals')
          .doc(snapshot.docs.first.id)
          .update({'content': _controller.text, 'mood': selectedMood});
    } else {
      await FirebaseFirestore.instance.collection('daily_journals').add({
        'date': today,
        'content': _controller.text,
        'mood': selectedMood,
        'timestamp': Timestamp.now(),
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Journal saved')));
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

  Widget _buildMoodSelector() {
    const moods = {
      "😄": "Happy",
      "😢": "Sad",
      "😠": "Angry",
      "😌": "Calm",
      "😴": "Tired",
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "How’s your mood today!?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Wrap(
          children:
              moods.entries.map((entry) {
                return GestureDetector(
                  onTap: () => setState(() => selectedMood = entry.value),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selectedMood == entry.value
                              ? Colors.blueAccent
                              : Colors.black45,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${entry.key} ${entry.value}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Daily Journal'),
            Text(
              DateFormat('yyyy-MM-dd').format(DateTime.now()),
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
          ],
        ),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMoodSelector(),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.format_bold,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                _controller.text += '*bold*';
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
                            setState(() {});
                          },
                          config: const Config(
                            emojiViewConfig: EmojiViewConfig(
                              emojiSizeMax: 32,
                              columns: 8,
                            ),
                            bottomActionBarConfig: BottomActionBarConfig(
                              showBackspaceButton: true,
                            ),
                          ),
                        ),
                        TextField(
                          controller: _controller,
                          onChanged: (_) => setState(() {}),
                          maxLines: null,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Write your journal...',
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

              ElevatedButton(
                onPressed: _saveJournal,
                child: const Text('Save Journal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}