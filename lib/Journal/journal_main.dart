// lib/pages/journal_main.dart

import 'package:flutter/material.dart';
import 'mind_dump.dart';
import 'daily_journal.dart';
import 'swifty_journal.dart';
import 'history_page.dart';

class JournalMain extends StatelessWidget {
  const JournalMain({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: MainJournalPage());
  }
}

class MainJournalPage extends StatefulWidget {
  const MainJournalPage({Key? key}) : super(key: key);

  @override
  State<MainJournalPage> createState() => _MainJournalPageState();
}

class _MainJournalPageState extends State<MainJournalPage>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animController;
  late PageController _pageController;

  static const Color bgColor = Color(0xFF121212);
  static const Color cardColor = Color(0xFF1E1E1E);
  static const Color accentColor = Color(0xFFFFBF00);

  static const TextStyle titleStyle = TextStyle(
    fontFamily: 'AtkinsonHyperlegible',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: accentColor,
    shadows: [
      Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 2),
    ],
  );

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pageController = PageController();
  }

  @override
  void dispose() {
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildOption(String label, IconData icon, Widget page) {
    return AnimatedSlide(
      offset: _isExpanded ? Offset.zero : const Offset(0, 0.5),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToPage(page),
          icon: Icon(icon, color: bgColor),
          label: Text(
            label,
            style: const TextStyle(fontFamily: 'OpenDyslexic', color: bgColor),
          ),
          backgroundColor: accentColor,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build the 14 page asset paths:
    final pages = List.generate(14, (i) {
      final num = (i + 1).toString().padLeft(4, '0');
      return 'assets/images/journalguide_pages-to-jpg-$num.jpg';
    });

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 4,
        centerTitle: true,
        title: const Text('Journal Guide', style: titleStyle),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: accentColor),
            tooltip: 'History',
            onPressed: () => _navigateToPage(const HistoryPage()),
          ),
        ],
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: pages.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accentColor, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      offset: Offset(4, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Image.asset(pages[index], fit: BoxFit.contain),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isExpanded) ...[
            _buildOption('Mind Dump', Icons.psychology, const MindDumpPage()),
            _buildOption(
              'Daily Journal',
              Icons.calendar_today,
              const DailyJournalPage(),
            ),
            _buildOption(
              'Swifty Journal',
              Icons.smart_toy,
              const SwiftyJournalPage(),
            ),
          ],
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () {
              setState(() => _isExpanded = !_isExpanded);
              _isExpanded
                  ? _animController.forward()
                  : _animController.reverse();
            },
            backgroundColor: accentColor,
            elevation: 6,
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _animController,
              color: bgColor,
            ),
          ),
        ],
      ),
    );
  }
}
