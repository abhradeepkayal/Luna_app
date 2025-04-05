import 'package:flutter/material.dart';
import 'mind_dump.dart';
import 'daily_journal.dart';
import 'swifty_journal.dart';
import 'history_page.dart';

class JournalMain extends StatelessWidget {
  const JournalMain({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: MainJournalPage());
  }
}

class MainJournalPage extends StatefulWidget {
  const MainJournalPage({super.key});

  @override
  State<MainJournalPage> createState() => _MainJournalPageState();
}

class _MainJournalPageState extends State<MainJournalPage> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Neurofix Journal", textAlign: TextAlign.center),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _navigateToPage(const HistoryPage()),
          ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "Your journaling journey starts here! Tap + to begin.",
            style: TextStyle(fontSize: 18, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isExpanded) ...[
            _buildOption("Mind-dump", const MindDumpPage()),
            _buildOption("Daily Journal", const DailyJournalPage()),
            _buildOption("Swifty Journal", const SwiftyJournalPage()),
          ],
          FloatingActionButton(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            child: Icon(_isExpanded ? Icons.close : Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String label, Widget page) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: FloatingActionButton.extended(
        onPressed: () => _navigateToPage(page),
        label: Text(label),
        icon: const Icon(Icons.edit),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  void _navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }
}
