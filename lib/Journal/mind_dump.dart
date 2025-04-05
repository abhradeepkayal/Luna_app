import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MindDumpPage extends StatefulWidget {
  const MindDumpPage({super.key});

  @override
  State<MindDumpPage> createState() => _MindDumpPageState();
}

class _MindDumpPageState extends State<MindDumpPage> {
  final TextEditingController _controller = TextEditingController();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    _prefs = await SharedPreferences.getInstance();
    String? savedContent = _prefs.getString('mindDumpContent');
    if (savedContent != null) {
      _controller.text = savedContent;
    }
  }

  Future<void> _saveContent() async {
    await _prefs.setString('mindDumpContent', _controller.text);
  }

  @override
  void dispose() {
    _saveContent();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Mind-dump"),
            Text(
              "Unload thoughts freely without structure!",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: TextField(
          controller: _controller,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: "Write anything that comes to mind...",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.black12,
          ),
        ),
      ),
    );
  }
}
