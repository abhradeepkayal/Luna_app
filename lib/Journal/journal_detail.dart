/*import 'package:flutter/material.dart';
import 'package:zefyrka/zefyrka.dart';

class JournalDetailPage extends StatelessWidget {
  final dynamic content; // List for daily, String for swifty
  final String date;
  final String type;
  final String? mood;

  const JournalDetailPage({
    super.key,
    required this.content,
    required this.date,
    required this.type,
    this.mood,
  });

  @override
  Widget build(BuildContext context) {
    final isDaily = type == "daily";
    final document = isDaily && content is List
        ? NotusDocument.fromJson(content as List<dynamic>)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Journal Detail"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: const TextStyle(fontSize: 18, color: Colors.white70),
            ),
            if (isDaily && mood != null && mood!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mood!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: isDaily && document != null
                  ? ZefyrEditor(
                      controller: ZefyrController(document),
                      focusNode: FocusNode(),
                      readOnly: true,
                      padding: const EdgeInsets.all(8),
                    )
                  : SingleChildScrollView(
                      child: Text(
                        content.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}*/