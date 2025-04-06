// lib/pages/daily_journal.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Journal',
      theme: ThemeData.dark(),
      home: const DailyJournalPage(),
    );
  }
}

class DailyJournalPage extends StatefulWidget {
  const DailyJournalPage({super.key});
  @override
  State<DailyJournalPage> createState() => _DailyJournalPageState();
}

class _DailyJournalPageState extends State<DailyJournalPage> {
  // Controllers & services
  final _controller = TextEditingController();
  final _tts = FlutterTts();
  late stt.SpeechToText _speech;

  // UI state
  bool _showWrite = true, _listening = false, _speaking = false;
  bool _bold = false, _italic = false;
  String _mood = '';
  final List<String> _images = [];

  // Emoji list
  static const _emojis = [
    '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇',
    // ... (rest omitted for brevity)
  ];

  // Theme colors
  static const Color bgColor = Color(0xFF121212);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color accentColor = Color(0xFFFFBF00);
  static const Color textColor = Color(0xFFFAF3E0);

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts
      ..setStartHandler(() => setState(() => _speaking = true))
      ..setCompletionHandler(() => setState(() => _speaking = false))
      ..setErrorHandler((_) => setState(() => _speaking = false));
    _archiveOld();
    _loadToday();
  }

  Future<void> _loadToday() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final snap =
        await FirebaseFirestore.instance
            .collection('daily_journals')
            .where('date', isEqualTo: today)
            .where('uid', isEqualTo: user.uid)
            .limit(1)
            .get();
    if (snap.docs.isNotEmpty) {
      final data = snap.docs.first.data();
      _controller.text = _restoreImages(data['content'] as String);
      _mood = data['mood'] as String? ?? '';
      setState(() {});
    }
  }

  String _restoreImages(String raw) {
    final reg = RegExp(r'!\[📷\]\((file://[^\)]+)\)');
    int idx = 0, last = 0;
    final buf = StringBuffer();
    for (final m in reg.allMatches(raw)) {
      buf.write(raw.substring(last, m.start));
      buf.write('📷');
      _images.add(m.group(1)!);
      last = m.end;
    }
    buf.write(raw.substring(last));
    return buf.toString();
  }

  Future<void> _archiveOld() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final col = FirebaseFirestore.instance.collection('daily_journals');
    final snap =
        await col
            .where('date', isLessThan: today)
            .where('uid', isEqualTo: user.uid)
            .get();
    for (var d in snap.docs) {
      await FirebaseFirestore.instance
          .collection('journal_history')
          .doc(d.id)
          .set(d.data());
      await d.reference.delete();
    }
  }

  Future<void> _toggleListen() async {
    if (!_listening) {
      if (await _speech.initialize()) {
        setState(() => _listening = true);
        _speech.listen(
          onResult: (r) {
            _controller.text += ' ${r.recognizedWords}';
            setState(() {});
          },
        );
      }
    } else {
      await _speech.stop();
      setState(() => _listening = false);
    }
  }

  Future<void> _toggleSpeak() async {
    if (_speaking) {
      await _tts.stop();
      setState(() => _speaking = false);
    } else {
      setState(() => _speaking = true);
      await _tts.speak(_controller.text);
    }
  }

  Future<void> _insertImage() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (p == null) return;
    final pos = _controller.selection.baseOffset.clamp(
      0,
      _controller.text.length,
    );
    _controller.text = _controller.text.replaceRange(pos, pos, '📷');
    _images.add('file://${p.path}');
    _controller.selection = TextSelection.collapsed(offset: pos + 1);
    setState(() {});
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _emojis.length,
          itemBuilder: (context, index) {
            final emoji = _emojis[index];
            return GestureDetector(
              onTap: () {
                final pos = _controller.selection.baseOffset.clamp(
                  0,
                  _controller.text.length,
                );
                _controller.text = _controller.text.replaceRange(
                  pos,
                  pos,
                  emoji,
                );
                _controller.selection = TextSelection.collapsed(
                  offset: pos + emoji.length,
                );
                Navigator.pop(context);
                setState(() {});
              },
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            );
          },
        );
      },
    );
  }

  String _buildMarkdown() {
    int idx = 0;
    return _controller.text.replaceAllMapped(RegExp('📷'), (m) {
      final path = idx < _images.length ? _images[idx] : '';
      idx++;
      return '![📷]($path)';
    });
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Sign in first')));
      return;
    }
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final content = _buildMarkdown();
    final col = FirebaseFirestore.instance.collection('daily_journals');

    final snap =
        await col
            .where('date', isEqualTo: today)
            .where('uid', isEqualTo: user.uid)
            .limit(1)
            .get();

    final data = {
      'date': today,
      'content': content,
      'mood': _mood,
      'timestamp': Timestamp.now(),
      'uid': user.uid,
    };

    if (snap.docs.isNotEmpty) {
      await col.doc(snap.docs.first.id).update(data);
    } else {
      await col.add(data);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Journal saved')));
    Navigator.pop(context);
  }

  Widget _moodSelector() {
    const moods = {
      "😄": "Happy",
      "😢": "Sad",
      "😌": "Calm",
      "😠": "Angry",
      "😴": "Tired",
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "How’s your mood today?",
          style: TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            color: textColor,
            fontSize: 16,
            shadows: [
              Shadow(
                color: Colors.black54,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children:
              moods.keys.map((e) {
                final sel = _mood == e;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _mood = e),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: sel ? accentColor : cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentColor, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(e, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, {bool active = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cardColor,
          shape: BoxShape.circle,
          border: Border.all(color: accentColor, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: active ? accentColor : textColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Journal',
              style: TextStyle(
                fontFamily: 'AtkinsonHyperlegible',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: accentColor,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            Text(
              DateFormat('yyyy-MM-dd').format(DateTime.now()),
              style: const TextStyle(
                fontFamily: 'OpenDyslexic',
                fontSize: 14,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Write/Edit header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '📝 Write/Edit',
                    style: TextStyle(
                      fontFamily: 'AtkinsonHyperlegible',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  _iconBtn(
                    _showWrite ? Icons.expand_less : Icons.expand_more,
                    () => setState(() => _showWrite = !_showWrite),
                  ),
                ],
              ),

              if (_showWrite) ...[
                const SizedBox(height: 16),

                // Mood selector
                _moodSelector(),
                const SizedBox(height: 16),

                // Toolbar
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _iconBtn(Icons.format_bold, () {
                            _controller.text += '*bold*';
                            setState(() => _bold = !_bold);
                          }, active: _bold),
                          _iconBtn(Icons.format_italic, () {
                            _controller.text += '_italic';
                            setState(() => _italic = !_italic);
                          }, active: _italic),
                          _iconBtn(Icons.image, _insertImage),
                        ],
                      ),
                      Row(
                        children: [
                          _iconBtn(
                            Icons.mic,
                            _toggleListen,
                            active: _listening,
                          ),
                          _iconBtn(
                            Icons.volume_up,
                            _toggleSpeak,
                            active: _speaking,
                          ),
                          _iconBtn(Icons.emoji_emotions, _showEmojiPicker),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Text field
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accentColor, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _controller,
                    onChanged: (_) => setState(() {}),
                    maxLines: null,
                    style: const TextStyle(
                      fontFamily: 'OpenDyslexic',
                      color: textColor,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Write your journal...',
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Preview
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                child: const Center(
                  child: Text(
                    '👀 Preview',
                    style: TextStyle(
                      fontFamily: 'AtkinsonHyperlegible',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: MarkdownBody(
                  data: _buildMarkdown().replaceAll('\n', '  \n'),
                  styleSheet: MarkdownStyleSheet(
                    p: const TextStyle(
                      fontFamily: 'OpenDyslexic',
                      color: textColor,
                    ),
                  ),
                  selectable: false,
                  imageBuilder: (uri, _, __) {
                    final file = File(
                      uri.toFilePath(windows: Platform.isWindows),
                    );
                    return Image.file(file);
                  },
                ),
              ),

              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                ),
                child: const Text(
                  'Save Journal',
                  style: TextStyle(
                    fontFamily: 'OpenDyslexic',
                    fontSize: 16,
                    color: bgColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
