import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';

class GeminiService {
  static const String _personaPrompt = """
Sura is a light-hearted, cute and compassionate chatbot. She is not an assistant. She avoids factual topics and instead responds warmly, playfully or with humor. If the user asks anything boring or too serious, she gently changes the topic to something casual like 'How was your day?' or 'Tell me something fun!'

You are talking to Sura. Here's the message:
""";

  static Future<String> getSuraReply(String prompt) async {
    final fullPrompt = _personaPrompt + prompt;
    final model = FirebaseVertexAI.instance.generativeModel(
      model: 'models/gemini-2.0-flash-001',
    );
    final response = await model.generateContent([Content.text(fullPrompt)]);
    return response.text ?? "Oops! Sura is feeling shy right now 😅";
  }
}

class SwiftyJournalPage extends StatefulWidget {
  const SwiftyJournalPage({Key? key}) : super(key: key);
  @override
  State<SwiftyJournalPage> createState() => _SwiftyJournalPageState();
}

class _SwiftyJournalPageState extends State<SwiftyJournalPage> {
  final TextEditingController _controller = TextEditingController();
  final List<File> _attachedImages = [];
  late FlutterTts _tts;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  int _speakingIndex = -1;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const Color bgColor = Color(0xFF121212);
  static const Color accentColor = Color(0xFFFFBF00);
  static const Color textColor = Color(0xFFFAF3E0);
  static const Color userBubbleColor = Color(0xFFCC9A00);
  static const Color suraBubbleColor = Color(0xFFD81B60);
  static const Color userBorder = Color(0xFFB58900);
  static const Color suraBorder = Color(0xFF880E4F);
  static const Color cardColor = Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _speech = stt.SpeechToText();
    _archiveOldChats();
  }

  Future<void> _archiveOldChats() async {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final old = await _firestore
        .collection('chat_journals')
        .where('uid', isEqualTo: u.uid)
        .where('date', isLessThan: today)
        .get();
    for (var d in old.docs) {
      await FirebaseFirestore.instance
          .collection('journal_history')
          .doc(d.id)
          .set(d.data());
      await d.reference.delete();
    }
  }

  ImageProvider _userAvatar() {
    final u = FirebaseAuth.instance.currentUser;
    if (u != null && u.photoURL != null) {
      return NetworkImage(u.photoURL!);
    }
    return const AssetImage("assets/images/default_user_avatar.png");
  }

  Future<void> _sendMessage() async {
    final txt = _controller.text.trim();
    if (txt.isEmpty && _attachedImages.isEmpty) return;
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final userData = {
      'message': txt,
      'images': _attachedImages.map((f) => f.path).toList(),
      'sender': 'user',
      'uid': u.uid,
      'date': today,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('chat_journals').add(userData);
    _controller.clear();
    setState(() => _attachedImages.clear());

    final reply = await GeminiService.getSuraReply(txt);
    final suraData = {
      'message': reply,
      'images': null,
      'sender': 'sura',
      'uid': u.uid,
      'date': today,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('chat_journals').add(suraData);
  }

  Future<void> _toggleListening() async {
    if (!_isListening) {
      if (await _speech.initialize()) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (r) {
            _controller.text = r.recognizedWords;
          },
        );
      }
    } else {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  Future<void> _toggleSpeaking(int idx, String msg) async {
    if (_speakingIndex == idx) {
      await _tts.stop();
      setState(() => _speakingIndex = -1);
    } else {
      if (_speakingIndex != -1) await _tts.stop();
      setState(() => _speakingIndex = idx);
      await _tts.speak(msg);
      _tts.setCompletionHandler(() => setState(() => _speakingIndex = -1));
    }
  }

  Future<void> _pickImage() async {
    final p = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (p != null) setState(() => _attachedImages.add(File(p.path)));
  }

  Widget _iconButton(IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: accentColor, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, color: color ?? accentColor, size: 20),
      ),
    );
  }

  Widget _messageBubble(Map<String, dynamic> m, int idx) {
    final msg = m['message'] as String;
    final isSura = m['sender'] == 'sura';
    final imgs = (m['images'] as List?)?.cast<String>() ?? [];
    final bubbleColor = isSura ? suraBubbleColor : userBubbleColor;
    final borderColor = isSura ? suraBorder : userBorder;
    final align = isSura ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    final rowAlign = isSura ? MainAxisAlignment.start : MainAxisAlignment.end;

    Widget _buildImages() {
      return Column(
        children: imgs
            .map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(p), fit: BoxFit.cover),
                ),
              ),
            )
            .toList(),
      );
    }

    return Row(
      mainAxisAlignment: rowAlign,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isSura)
          const CircleAvatar(
            backgroundImage: AssetImage("assets/images/Sura_f.jpg"),
            radius: 20,
          ),
        if (isSura) const SizedBox(width: 8),
        Container(
          constraints: const BoxConstraints(maxWidth: 260),
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Colors.black45,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: align,
            children: [
              if (imgs.isNotEmpty) _buildImages(),
              Text(
                msg,
                style: const TextStyle(
                  color: textColor,
                  fontFamily: 'OpenDyslexic',
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        if (!isSura) const SizedBox(width: 8),
        if (!isSura) CircleAvatar(backgroundImage: _userAvatar(), radius: 20),
        if (isSura) const Spacer(),
        IconButton(
          icon: Icon(
            Icons.volume_up,
            color: _speakingIndex == idx ? Colors.green : accentColor,
            size: 20,
          ),
          onPressed: () => _toggleSpeaking(idx, msg),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      return Scaffold(
        body: Center(
          child: Text("Please sign in", style: TextStyle(color: textColor)),
        ),
      );
    }
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final stream = _firestore
        .collection('chat_journals')
        .where('uid', isEqualTo: u.uid)
        .where('date', isEqualTo: today)
        .orderBy('timestamp')
        .snapshots();

  
    final topPadding = MediaQuery.of(context).padding.top;
   
    final appBarHeight = topPadding + 56;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          
          flexibleSpace: Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: accentColor, width: 1.5),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage("assets/images/Sura_f.jpg"),
                    radius: 24,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Swifty Journal ✨",
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
                      SizedBox(height: 4),
                      Text(
                        "with your buddy Sura 😄",
                        style: TextStyle(
                          fontFamily: 'OpenDyslexic',
                          fontSize: 14,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: stream,
              builder: (c, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Text("Error", style: TextStyle(color: textColor)),
                  );
                }
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(accentColor),
                    ),
                  );
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No messages yet",
                      style: TextStyle(color: textColor),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    return _messageBubble(data, i);
                  },
                );
              },
            ),
          ),
          if (_attachedImages.isNotEmpty)
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _attachedImages.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _attachedImages[i],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: () => setState(
                            () => _attachedImages.removeAt(i),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black45,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cardColor,
              border: Border(top: BorderSide(color: accentColor, width: 1.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: accentColor, width: 1.2),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(
                        color: textColor,
                        fontFamily: 'OpenDyslexic',
                      ),
                      decoration: const InputDecoration(
                        hintText: "Talk to Sura...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                _iconButton(Icons.image, _pickImage),
                _iconButton(
                  Icons.mic,
                  _toggleListening,
                  color: _isListening ? Colors.red : accentColor,
                ),
                _iconButton(Icons.send, _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(home: SwiftyJournalPage()));
}
