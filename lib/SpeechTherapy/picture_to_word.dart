import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:string_similarity/string_similarity.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';

const String googleApiKey = 'AIzaSyC8aoDt6_PM5i9_xz7AlHBo720SU_nAHSY';
const String customSearchEngineId = 'd0355ea3695f2481b';

class PictureToWord extends StatefulWidget {
  const PictureToWord({super.key});

  @override
  State<PictureToWord> createState() => _PictureToWordState();
}

class _PictureToWordState extends State<PictureToWord>
    with TickerProviderStateMixin {
  final List<String> tags = [
    'apple', 'banana', 'orange', 'grapes', 'watermelon', 'strawberry',
    'pineapple', 'mango', 'peach', 'lemon',
    'tomato', 'potato', 'onion', 'cucumber', 'broccoli',
    'lettuce', 'spinach', 'eggplant', 'pumpkin', 'pepper', 'corn',
    'dog', 'cat', 'bird', 'fish', 'rabbit', 'horse', 'cow', 'goat', 'sheep',
    'lion', 'tiger', 'elephant', 'giraffe', 'zebra', 'monkey', 'bear', 'fox',
    'car', 'bus', 'train', 'bicycle', 'motorcycle', 'airplane', 'ship',
    'house', 'bed', 'chair', 'table', 'door', 'window', 'television',
    'computer', 'phone', 'book', 'pencil', 'pen', 'paper', 'scissors', 'bag',
    'shirt', 'pants', 'shoes', 'hat', 'toothbrush', 'toothpaste', 'soap',
    'towel', 'water', 'juice', 'coffee', 'tea', 'sugar', 'salt', 'oil', 'spoon',
    'fork', 'knife', 'plate', 'cup'
  ];

  late String currentTag;
  String imageUrl = 'https://via.placeholder.com/400x300.png?text=Loading...';
  final TextEditingController _controller = TextEditingController();
  String feedback = '';
  final double threshold = 0.8;

  late AnimationController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadRandomImage();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadRandomImage() async {
    final random = Random();
    currentTag = tags[random.nextInt(tags.length)];
    final fetchedUrl = await _fetchImageUrl(currentTag);
    if (fetchedUrl != null) {
      imageUrl = fetchedUrl;
    } else {
      imageUrl = 'https://via.placeholder.com/400x300.png?text=${Uri.encodeComponent(currentTag)}';
    }
    _controller.clear();
    setState(() {
      feedback = '';
    });
  }

  Future<String?> _fetchImageUrl(String tag) async {
    final query = 'photo of $tag';
    final url =
        'https://www.googleapis.com/customsearch/v1?key=$googleApiKey&cx=$customSearchEngineId&q=${Uri.encodeQueryComponent(query)}&searchType=image';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['items'] != null && jsonData['items'].length > 0) {
          return jsonData['items'][0]['link'];
        }
      }
    } catch (e) {
      debugPrint('Error fetching image: $e');
    }
    return null;
  }

  Future<void> _checkAnswer([_]) async {
    final userAnswer = _controller.text.trim().toLowerCase();
    final expected = currentTag.toLowerCase();
    bool isCorrect =
        StringSimilarity.compareTwoStrings(userAnswer, expected) >= threshold;

    if (isCorrect) {
      _confettiController.forward(from: 0);
      await _audioPlayer.setAsset('assets/sounds/correct.mp3');
    } else {
      await _audioPlayer.setAsset('assets/sounds/wrong.mp3');
    }
    _audioPlayer.play();

    final aiResponse = await _generateAIResponse(
      userAnswer: userAnswer,
      correctTag: currentTag,
      isCorrect: isCorrect,
    );

    setState(() {
      feedback = aiResponse;
    });
  }

  Future<String> _generateAIResponse({
    required String userAnswer,
    required String correctTag,
    required bool isCorrect,
  }) async {
    final model = FirebaseVertexAI.instance.generativeModel(
      model: 'models/gemini-2.0-flash-001',
    );

    final prompt = '''
User typed: "$userAnswer"
Correct Word: "$correctTag"
They were ${isCorrect ? 'correct' : 'incorrect'}.

Please provide:
1) A short enthusiastic compliment if the answer is correct.
Otherwise, give an encouraging remark and also tell the correct answer. Make it personalised according to the user input. Answer in two sentences.
2) A two liner joke about "$correctTag" in simple words.

Answer in two concise paragraphs and not points. Do not write any filler sentences. Only two points. Befor the joke, write "Just for fun: "
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'Great effort!';
    } catch (e) {
      return 'Error generating AI response: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Image.asset('assets/images/NeuroApp.jpeg', height: 30),
            const SizedBox(width: 8),
            const Text('NeuroApp'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  children: [
                    Image.network(
                      imageUrl,
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          color: Colors.grey,
                          child:
                              const Center(child: Text('Image not available')),
                        );
                      },
                    ).animate(controller: _confettiController).shake(),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      onSubmitted: _checkAnswer,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'What is this?',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _checkAnswer,
                      child: const Text('Submit'),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      feedback,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadRandomImage,
                      child: const Text('Next Image'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}