import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:string_similarity/string_similarity.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PictureToWord extends StatefulWidget {
  const PictureToWord({super.key});

  @override
  State<PictureToWord> createState() => _PictureToWordState();
}

class _PictureToWordState extends State<PictureToWord>
    with TickerProviderStateMixin {
  late String currentTag;
  String imageUrl = 'https://via.placeholder.com/400x300.png?text=Loading...';
  final TextEditingController _controller = TextEditingController();
  String feedback = '';
  final double threshold = 0.8;
  bool _isLoading = false;

  late AnimationController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _loadRandomImage();
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadRandomImage() async {
    setState(() => _isLoading = true);
    currentTag = await _generateTagFromAI();
    final fetchedUrl = await _fetchImageUrl(currentTag);
    imageUrl =
        fetchedUrl ??
        'https://via.placeholder.com/400x300.png?text=${Uri.encodeComponent(currentTag)}';

    _controller.clear();
    setState(() {
      feedback = '';
      _isLoading = false;
    });
  }

  Future<String> _generateTagFromAI() async {
    final model = FirebaseVertexAI.instance.generativeModel(
      model: 'models/gemini-2.0-flash-lite-001',
    );

    const prompt = '''
Pick exactly one common everyday object (in singular form) at random, such as "apple", "dog", or "chair". Respond with only that single word, no punctuation or explanation.
''';

    try {
      final response = await model.generateContent([Content.text(prompt)]);
      final text = response.text?.trim().split(RegExp(r'\s+')).first;
      if (text != null && text.isNotEmpty) {
        return text.toLowerCase();
      }
    } catch (e) {
      debugPrint('Tag generation error: $e');
    }

    return 'object';
  }

  Future<String?> _fetchImageUrl(String tag) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];
    final cx = dotenv.env['CUSTOM_SEARCH_ENGINE_ID'];
    if (apiKey == null || cx == null) {
      debugPrint('Missing .env configuration for API key or CSE ID');
      return null;
    }

    final url =
        'https://www.googleapis.com/customsearch/v1?key=$apiKey&cx=$cx&q=${Uri.encodeQueryComponent(tag)}&searchType=image';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final items = data['items'] as List<dynamic>?;
        if (items != null && items.isNotEmpty) {
          return items.first['link'] as String?;
        }
      }
    } catch (e) {
      debugPrint('Error fetching image: $e');
    }
    return null;
  }

  Future<void> checkAnswer([_]) async {
    final userAnswer = _controller.text.trim().toLowerCase();
    final expected = currentTag.toLowerCase();
    final isCorrect =
        StringSimilarity.compareTwoStrings(userAnswer, expected) >= threshold;

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

1) ${isCorrect ? 'Give a short enthusiastic compliment.' : 'Give an encouraging remark and reveal the correct answer.'}
2) A two line joke about "$correctTag", starting with "Just for fun: "

Respond in two concise paragraphs, no filler.
''';
    try {
      final resp = await model.generateContent([Content.text(prompt)]);
      return resp.text ?? 'Great effort!';
    } catch (e) {
      return 'Error generating feedback: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    final creamyWhite = const Color(0xFFFFF8E7);
    const gold = Color(0xFFFFBF00);
    const darkGrey = Color(0xFF1A1A1A);

    final theme = Theme.of(context).copyWith(
      scaffoldBackgroundColor: darkGrey,
      textTheme: Theme.of(context).textTheme.apply(
        bodyColor: creamyWhite,
        displayColor: creamyWhite,
        fontFamilyFallback: ['Atkinson Hyperlegible', 'OpenDyslexic'],
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.black54,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: gold, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: TextStyle(color: gold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: darkGrey,
          backgroundColor: gold,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          shadowColor: gold.withOpacity(0.3),
          elevation: 10,
        ),
      ),
    );

    return Theme(
      data: theme,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: darkGrey,
          elevation: 8,
          shadowColor: Colors.black,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: gold,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              Image.asset('assets/images/luna.png', height: 30),
              const SizedBox(width: 8),
              Text(
                'Luna',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: gold,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(1, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: gold, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(
                                    imageUrl,
                                    height: 300,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (ctx, err, st) => Container(
                                          height: 300,
                                          color: Colors.grey,
                                          child: const Center(
                                            child: Text('Loading Image…'),
                                          ),
                                        ),
                                  )
                                  .animate(controller: _confettiController)
                                  .shake(),
                              if (_isLoading)
                                Container(
                                  height: 300,
                                  color: Colors.black38,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: gold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _controller,
                        onSubmitted: checkAnswer,
                        style: TextStyle(color: creamyWhite),
                        decoration: const InputDecoration(
                          labelText: 'What is this?',
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: checkAnswer,
                        child: const Text('Submit'),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        feedback,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFFFFF8E7),
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
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
      ),
    );
  }
}
