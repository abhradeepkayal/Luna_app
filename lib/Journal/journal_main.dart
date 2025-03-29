/*import 'package:flutter/material.dart';
import 'mind_dump.dart';
import 'daily_journal.dart';
import 'swifty_journal.dart';
import 'history_page.dart';

void main() {
  runApp(const NeurofixApp());
}

class NeurofixApp extends StatelessWidget {
  const NeurofixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neurofix',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1C1C1C),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Color(0xFFF5F5DC),
            fontFamily: 'OpenDyslexic',
          ),
          titleLarge: TextStyle(
            fontFamily: 'AtkinsonHyperlegible',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("Neurofix")),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
            },
          ),
        ],
        backgroundColor: Colors.black,
      ),
      body: const Center(child: Text("Journal Guide Goes Here")),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isExpanded) ...[
            _buildOption("Mind-dump", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MindDumpPage()));
            }),
            _buildOption("Daily Journal", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyJournalPage()));
            }),
            _buildOption("Swifty Journal", () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SwiftyJournalPage()));
            }),
          ],
          FloatingActionButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: FloatingActionButton.extended(
        onPressed: onTap,
        label: Text(label),
        icon: const Icon(Icons.edit),
        backgroundColor: Colors.grey[800],
      ),
    );
  }
}*/