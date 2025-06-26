import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:Luna/SpeechTherapy/picture_to_word.dart';
import 'package:Luna/SpeechTherapy/scenario_feature.dart';
import 'package:Luna/SpeechTherapy/speech_therapy.dart';
import 'package:Luna/aboutus.dart';
import 'package:Luna/contact.dart';
import 'package:Luna/forum.dart';
import 'package:Luna/todo/todo_main_page.dart';
import 'package:Luna/visual/calming_music_home.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:Luna/Activites/activites_main.dart';
import 'package:Luna/Activites/jumbledwords.dart';
import 'package:Luna/Activites/puzzles.dart';
import 'package:Luna/Journal/daily_journal.dart';
import 'package:Luna/Journal/mind_dump.dart';
import 'package:Luna/Journal/swifty_journal.dart';
import 'package:Luna/MainChatbot/chatbot.dart';
import 'package:Luna/profile.dart';
import 'package:Luna/Journal/journal_main.dart'; 
class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  
  final List<String> _allFeatures = [
    "Chatbot",
    "Journaling",
    "Speech Therapy",
    "Activities",
    "JumbledWords",
    "Picture to Word",
    "To-do List",
    "Scenario Game",
    "Daily Journal",
    "Mind-dump",
    "Swifty Journal",
    "Profile",
    "About Us",
    "Contact",
    "Forum",
    "Calming Visuals & Music",
    "Puzzles",
  ];

  List<String> _filteredFeatures = [];

  
  final Map<String, Widget Function()> _featureRoutes = {
    "Journaling": () => const JournalMain(),
    "Activities": () => const ActivitesMain(),
    "JumbledWords": () => const JumbledWordsApp(),
    "Picture to Word": () => const PictureToWord(),
    "To-do List": () => const TodoMainPage(),
    "Scenario Game": () => ScenarioScreen(),
    "Daily Journal": () => const DailyJournalPage(),
    "Mind-dump": () => const MindDumpPage(),
    "Swifty Journal": () => const SwiftyJournalPage(),
    "Profile": () => const ProfilePage(),
    "About Us": () => const AboutUsPage(),
    "Contact": () => const ContactPage(),
    "Forum": () => const ForumPage(),
    "Calming Visuals & Music": () => CalmingMusicHome(),
    "Chatbot": () => const ChatbotScreen(),
    "Speech Therapy": () => const SpeechTherapyPage(),
    "Puzzles": () => const PuzzlesPage(),
  };

  
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _filteredFeatures = List.from(_allFeatures);
    _searchController.addListener(_onSearchChanged);
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFeatures =
          _allFeatures
              .where((feature) => feature.toLowerCase().contains(query))
              .toList();
    });
  }

  void _onFeatureTap(String feature) {
    if (_featureRoutes.containsKey(feature)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => _featureRoutes[feature]!()),
      );
    } else {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Feature '$feature' is not available yet.")),
      );
    }
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (errorNotification) {
          setState(() => _isListening = false);
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _searchController.text = result.recognizedWords;
              _searchController.selection = TextSelection.fromPosition(
                TextPosition(offset: _searchController.text.length),
              );
            });
          },
          localeId: 'en_US', 
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(
                              color: Color(0xFFFFFDD0),
                              fontFamily: 'OpenDyslexic',
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              hintText: "Search features...",
                              hintStyle: TextStyle(
                                color: const Color(0xFFFFFDD0).withOpacity(0.7),
                                fontFamily: 'OpenDyslexic',
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _listen,
                          icon: Icon(
                            _isListening ? Icons.mic_off : Icons.mic,
                            color: const Color(0xFFFFFDD0),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                          },
                          icon: const Icon(
                            Icons.search,
                            color: Color(0xFFFFFDD0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Expanded(
                child:
                    _filteredFeatures.isNotEmpty
                        ? ListView.separated(
                          itemCount: _filteredFeatures.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final feature = _filteredFeatures[index];
                            return Card(
                              color: Colors.grey[850]?.withOpacity(0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              child: ListTile(
                                title: Text(
                                  feature,
                                  style: const TextStyle(
                                    color: Color(0xFFFFFDD0),
                                    fontFamily: 'AtkinsonHyperlegible',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                onTap: () => _onFeatureTap(feature),
                              ),
                            );
                          },
                        )
                        : Center(
                          child: Text(
                            "No features found.",
                            style: const TextStyle(
                              color: Color(0xFFFFFDD0),
                              fontFamily: 'OpenDyslexic',
                              fontSize: 18,
                            ),
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
