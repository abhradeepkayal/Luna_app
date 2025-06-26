import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';

final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();

class GeminiAPI {
  static Future<String> getResponse(
    String message,
    String botType,
    FirebaseVertexAI vertexAI,
  ) async {
    try {
      String personality;
      if (botType == 'Chill Guy') {
        personality = "calm, positive, solution-oriented, 'good bro' vibe";
      } else if (botType == 'Emma') {
        personality = "funny, charming, joyful, kind";
      } else {
        personality = "wise, serious, motivational, big-picture";
      }
      final prompt =
          "You are a $botType AI assistant with a $personality personality. Respond appropriately.\nUser: $message";
      final model = vertexAI.generativeModel(
        model: 'models/gemini-2.0-flash-lite-001',
      );
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "No reply received.";
    } catch (e) {
      debugPrint("Error calling Vertex AI: $e");
      return "Something went wrong while talking to Gemini.";
    }
  }
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with RouteAware {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseVertexAI _vertexAI = FirebaseVertexAI.instanceFor(
    auth: FirebaseAuth.instance,
  );

  String _botType = 'Chill Guy';
  bool _isListening = false;
  bool _showBotList = false;
  bool _isImageLoading = false;
  bool _isSending = false;
  String? _imagePath;

  final List<Map<String, String>> _bots = [
    {'name': 'Chill Guy', 'description': 'Cool, calm, funny, helpful'},
    {'name': 'Emma', 'description': 'Joyful, fun, sweet vibes'},
    {'name': 'Patrick', 'description': 'Wise, deep, smart, motivational'},
  ];

  final Map<String, String> _welcomeMessages = {
    'Chill Guy':
        "Hey there! I’m Chill Guy, cool, calm, and ready to help you. What’s up?",
    'Emma':
        "Hi! I’m Emma, your joyful and sweet assistant. How can I bring some fun today?",
    'Patrick':
        "Hello, I’m Patrick. I’m here to guide you with deep, insightful responses. Let’s dive into things!",
  };

  @override
  void initState() {
    super.initState();
    
    _checkAndShowWelcomeMessage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  
  @override
  void didPopNext() {
    
  }

  
  Future<void> _checkAndShowWelcomeMessage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    final snapshot =
        await _firestore
            .collection('chats')
            .where('uid', isEqualTo: uid)
            .where('botType', isEqualTo: _botType)
            .get();

    if (snapshot.docs.isEmpty) {
      
      final welcomeText = _welcomeMessages[_botType]!;
      await _saveMessageToFirestore(welcomeText, 'bot', uid);
    }
  }

  
  Future<void> _sendMessage() async {
    if ((_controller.text.isEmpty && _imagePath == null) || _isSending) return;
    setState(() => _isSending = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;

    
    if (_imagePath != null) {
      await _firestore
          .collection('chats')
          .add({
            'text': '',
            'sender': 'user',
            'botType': _botType,
            'uid': uid,
            'timestamp': FieldValue.serverTimestamp(),
            'imagePath': _imagePath,
          })
          .then((docRef) {
            debugPrint('Image message saved with id: ${docRef.id}');
          });
      setState(() {
        _imagePath = null;
      });
    }

    
    final userText = _controller.text.trim();
    if (userText.isNotEmpty) {
      await _saveMessageToFirestore(userText, 'user', uid);
      _controller.clear();
      
      await _getBotResponse(userText, uid);
    }
    setState(() => _isSending = false);
  }

  
  Future<void> _getBotResponse(String message, String uid) async {
    final response = await GeminiAPI.getResponse(message, _botType, _vertexAI);
    await _saveMessageToFirestore(response, 'bot', uid);
  }

  
  Future<void> _saveMessageToFirestore(
    String text,
    String sender,
    String uid,
  ) async {
    try {
      await _firestore
          .collection('chats')
          .add({
            'text': text,
            'sender': sender,
            'botType': _botType,
            'uid': uid,
            'timestamp': FieldValue.serverTimestamp(),
          })
          .then((docRef) {
            debugPrint('Message saved with id: ${docRef.id}');
          });
    } catch (e, s) {
      debugPrint('Error saving message: $e');
      debugPrint('Stack trace: $s');
    }
  }

  
  void _startListening() async {
    if (await _speech.initialize()) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
      );
    }
  }

  
  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  
  void _readAloud(String text) async {
    await _flutterTts.speak(text);
  }

  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    setState(() => _isImageLoading = true);
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
    setState(() => _isImageLoading = false);
  }

  
  void _switchBotType(String type) {
    setState(() {
      _botType = type;
      _imagePath = null;
    });
    
    _checkAndShowWelcomeMessage();
  }

  void _toggleBotList() => setState(() => _showBotList = !_showBotList);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(body: Center(child: Text("User not signed in.")));
    }
    final uid = user.uid;

    
    final messagesStream =
        _firestore
            .collection('chats')
            .where('uid', isEqualTo: uid)
            .where('botType', isEqualTo: _botType)
            .orderBy('timestamp')
            .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _toggleBotList,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/images/$_botType.jpg'),
              ),
              const SizedBox(width: 8),
              Text(_botType),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_showBotList)
            Container(
              color: Colors.grey[900],
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                children:
                    _bots.map((bot) {
                      return ListTile(
                        title: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                'assets/images/${bot['name']}.png',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              bot['name']!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          bot['description']!,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        onTap: () => _switchBotType(bot['name']!),
                      );
                    }).toList(),
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint("Stream error: ${snapshot.error}");
                  return Center(
                    child: Text(
                      "Error loading messages:\n${snapshot.error}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No messages yet.",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    
                    return ChatMessage(
                      text: data['text'] ?? '',
                      sender: data['sender'] == 'bot' ? _botType : 'user',
                      imageFile:
                          data['imagePath'] != null
                              ? File(data['imagePath'])
                              : null,
                      onReadAloud: () => _readAloud(data['text'] ?? ''),
                    );
                  },
                );
              },
            ),
          ),
          if (_isImageLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          if (_imagePath != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Stack(
                children: [
                  Image.file(
                    File(_imagePath!),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => setState(() => _imagePath = null),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    
                    debugPrint('Refresh pressed.');
                  },
                ),
                IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
                    enabled: !_isSending,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class ChatMessage extends StatelessWidget {
  final String text;
  final String sender;
  final VoidCallback onReadAloud;
  final File? imageFile;

  const ChatMessage({
    super.key,
    required this.text,
    required this.sender,
    required this.onReadAloud,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    if (sender == 'user') {
      backgroundColor = Colors.grey[800]!;
    } else if (sender == 'Chill Guy') {
      backgroundColor = Colors.orangeAccent.shade200;
    } else if (sender == 'Emma') {
      backgroundColor = Colors.pinkAccent.shade100;
    } else {
      backgroundColor = Colors.blue.shade700;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            child:
                sender == 'user'
                    ? const Icon(Icons.person)
                    : const Icon(Icons.face),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageFile != null)
                  Image.file(
                    imageFile!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                if (text.isNotEmpty)
                  Text(text, style: const TextStyle(color: Color(0xFFFFFDD0))),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.volume_up), onPressed: onReadAloud),
        ],
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }
  runApp(const MaterialApp(home: ChatbotScreen()));
}
