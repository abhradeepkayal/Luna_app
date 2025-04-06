// lib/pages/mind_dump_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';

class MindDumpPage extends StatefulWidget {
  const MindDumpPage({Key? key}) : super(key: key);

  @override
  State<MindDumpPage> createState() => _MindDumpPageState();
}

class _MindDumpPageState extends State<MindDumpPage> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _showWriteSection = true;
  bool _isListening = false;
  bool _isSpeaking = false;
  final List<String> _imagePaths = [];
  String? _mindDumpDocId;

  static const Color bgColor = Color(0xFF121212);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color textColor = Color(0xFFFAF3E0);
  static const Color accentColor = Color(0xFFFFBF00);

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initTtsHandlers();
    _loadLatestMindDump();
  }

  void _initTtsHandlers() {
    _flutterTts
      ..setStartHandler(() => setState(() => _isSpeaking = true))
      ..setCompletionHandler(() => setState(() => _isSpeaking = false))
      ..setErrorHandler((_) => setState(() => _isSpeaking = false));
  }

  Future<void> _loadLatestMindDump() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap =
        await FirebaseFirestore.instance
            .collection('mind_dumps')
            .where('uid', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
    if (snap.docs.isNotEmpty) {
      final doc = snap.docs.first;
      _mindDumpDocId = doc.id;
      _controller.text = doc.data()['content'] ?? '';
      setState(() {});
    }
  }

  Future<void> _autoSaveMindDump() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final content = _buildPreviewText();
    if (content.trim().isEmpty) return;
    final col = FirebaseFirestore.instance.collection('mind_dumps');
    if (_mindDumpDocId != null) {
      await col.doc(_mindDumpDocId).update({
        'content': content,
        'timestamp': Timestamp.now(),
        'uid': user.uid,
      });
    } else {
      final docRef = await col.add({
        'content': content,
        'timestamp': Timestamp.now(),
        'uid': user.uid,
      });
      _mindDumpDocId = docRef.id;
    }
  }

  Future<void> _toggleListening() async {
    if (!_isListening) {
      if (await _speech.initialize()) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            _controller.text += ' ${val.recognizedWords}';
            _autoSaveMindDump();
            setState(() {});
          },
        );
      }
    } else {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  Future<void> _toggleSpeak() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await _flutterTts.speak(_controller.text);
    }
  }

  Future<void> _insertImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final path = picked.path;
    final text = _controller.text;
    final sel = _controller.selection;
    final pos = sel.baseOffset >= 0 ? sel.baseOffset : text.length;
    _controller.text = text.replaceRange(pos, pos, '📷');
    _imagePaths.add('file://$path');
    _controller.selection = TextSelection.collapsed(offset: pos + 1);
    _autoSaveMindDump();
    setState(() {});
  }

  String _buildPreviewText() {
    int idx = 0;
    return _controller.text.replaceAllMapped(RegExp('📷'), (m) {
      final p = idx < _imagePaths.length ? _imagePaths[idx] : '';
      idx++;
      return '![📷]($p)';
    });
  }

  void _onTextChanged(String _) {
    _autoSaveMindDump();
    setState(() {});
  }

  void _showEmojiPicker() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => _EmojiPicker(
            onEmojiSelected: (e) {
              Navigator.pop(context);
              _controller.text += e;
              _autoSaveMindDump();
              setState(() {});
            },
          ),
    );
  }

  Future<void> _clearAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: cardColor,
            title: const Text(
              "Clear All",
              style: TextStyle(
                fontFamily: 'AtkinsonHyperlegible',
                color: textColor,
              ),
            ),
            content: const Text(
              "Are you sure you want to clear everything?",
              style: TextStyle(fontFamily: 'OpenDyslexic', color: textColor),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: accentColor),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Clear",
                  style: TextStyle(color: accentColor),
                ),
              ),
            ],
          ),
    );
    if (ok == true) {
      _controller.clear();
      _imagePaths.clear();
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All content cleared")));
    }
  }

  @override
  void dispose() {
    _autoSaveMindDump();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Mind Dump',
          style: const TextStyle(
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                MaterialLocalizations.of(
                  context,
                ).formatCompactDate(DateTime.now()),
                style: const TextStyle(
                  fontFamily: 'OpenDyslexic',
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearAll,
        backgroundColor: accentColor,
        elevation: 6,
        child: const Icon(Icons.delete, color: bgColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Write/Edit Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '📝 Write/Edit',
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
                  _iconButton(
                    icon:
                        _showWriteSection
                            ? Icons.expand_less
                            : Icons.expand_more,
                    onTap:
                        () => setState(
                          () => _showWriteSection = !_showWriteSection,
                        ),
                  ),
                ],
              ),
              if (_showWriteSection) ...[
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
                          _iconButton(
                            icon: Icons.format_bold,
                            onTap: () {
                              _controller.text += '**bold**';
                              _autoSaveMindDump();
                              setState(() {});
                            },
                          ),
                          _iconButton(
                            icon: Icons.format_italic,
                            onTap: () {
                              _controller.text += '_italic_';
                              _autoSaveMindDump();
                              setState(() {});
                            },
                          ),
                          _iconButton(icon: Icons.image, onTap: _insertImage),
                        ],
                      ),
                      Row(
                        children: [
                          _iconButton(
                            icon: Icons.mic,
                            iconColor:
                                _isListening ? Colors.redAccent : textColor,
                            onTap: _toggleListening,
                          ),
                          _iconButton(
                            icon: Icons.volume_up,
                            iconColor: _isSpeaking ? Colors.green : textColor,
                            onTap: _toggleSpeak,
                          ),
                          _iconButton(
                            icon: Icons.emoji_emotions,
                            onTap: _showEmojiPicker,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Text Field
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
                    onChanged: _onTextChanged,
                    maxLines: null,
                    style: const TextStyle(
                      fontFamily: 'OpenDyslexic',
                      color: textColor,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Dump your thoughts...',
                      hintStyle: TextStyle(color: Colors.white54),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              // Preview Header
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
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
              // Markdown Preview
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
                  data: _buildPreviewText().replaceAll('\n', '  \n'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconButton({
    required IconData icon,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
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
        child: Icon(icon, color: iconColor ?? textColor, size: 20),
      ),
    );
  }
}

class _EmojiPicker extends StatelessWidget {
  final void Function(String) onEmojiSelected;
  const _EmojiPicker({required this.onEmojiSelected, Key? key})
    : super(key: key);

  static const List<String> _emojis = [
    '😀',
    '😃',
    '😄',
    '😁',
    '😆',
    '😅',
    '😂',
    '🤣',
    '😊',
    '😇',
    '🙂',
    '🙃',
    '😉',
    '😌',
    '😍',
    '🥰',
    '😘',
    '😗',
    '😙',
    '😚',
    '😋',
    '😛',
    '😝',
    '😜',
    '🤪',
    '🤨',
    '🧐',
    '🤓',
    '😎',
    '🥳',
    '😏',
    '😒',
    '😞',
    '😔',
    '😟',
    '😕',
    '🙁',
    '☹',
    '😣',
    '😖',
    '😫',
    '😩',
    '🥺',
    '😢',
    '😭',
    '😤',
    '😠',
    '😡',
    '🤬',
    '🤯',
    '😳',
    '🥵',
    '🥶',
    '😱',
    '😨',
    '😰',
    '😥',
    '😓',
    '🤗',
    '🤔',
    '🤭',
    '🤫',
    '🤥',
    '😶',
    '😐',
    '😑',
    '😬',
    '🙄',
    '😯',
    '😦',
    '😧',
    '😮',
    '😲',
    '🥱',
    '😴',
    '🤤',
    '😪',
    '😵',
    '🤐',
    '🥴',
    '🤢',
    '🤮',
    '🤧',
    '😷',
    '🤒',
    '🤕',
    '🤑',
    '🤠',
    '😈',
    '👿',
    '👹',
    '👺',
    '💀',
    '👻',
    '👽',
    '🤖',
    '❤',
    '💔',
    '💕',
    '💖',
    '💗',
    '💓',
    '💞',
    '💟',
    '❣',
    '💤',
    '💩',
    '🔥',
    '✨',
    '🌟',
    '⭐',
    '🌈',
    '☀',
    '🌤',
    '⛅',
    '🌥',
    '☁',
    '🌦',
    '🌧',
    '⛈',
    '🌩',
    '🌨',
    '❄',
    '⚡',
    '💧',
    '🌊',
    '🎉',
    '🎊',
    '🎈',
    '🎂',
    '🍎',
    '🍌',
    '🍉',
    '🍇',
    '🍓',
    '🍒',
    '🍍',
    '🥭',
    '🍑',
    '🍆',
    '🌽',
    '🥕',
    '🍔',
    '🍟',
    '🍕',
    '🌭',
    '🍿',
    '🥗',
    '🍩',
    '🍪',
    '🍫',
    '🍭',
    '🍺',
    '🍷',
    '🥂',
    '☕',
    '🍵',
    '🍼',
    '🍶',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white38,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.count(
            crossAxisCount: 8,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(12),
            children:
                _emojis.map((e) {
                  return GestureDetector(
                    onTap: () => onEmojiSelected(e),
                    child: Center(
                      child: Text(e, style: const TextStyle(fontSize: 24)),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
