/*import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zefyrka/zefyrka.dart'; // ✅ all you need
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MindDumpPage extends StatefulWidget {
  const MindDumpPage({super.key});

  @override
  State<MindDumpPage> createState() => _MindDumpPageState();
}

class _MindDumpPageState extends State<MindDumpPage> {
  late ZefyrController _controller;
  late FocusNode _focusNode;
  bool _isLoading = true;

  final String docId = FirebaseAuth.instance.currentUser?.uid ?? '';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = ZefyrController(); // temporary empty
    _loadMindDump();
  }

  Future<void> _loadMindDump() async {
    if (docId.isEmpty) return;

    final doc = await firestore.collection('mind_dumps').doc(docId).get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['content'] != null) {
        final document = NotusDocument.fromJson(data['content']);
        setState(() {
          _controller = ZefyrController(document);
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveMindDump() async {
    if (docId.isEmpty) return;

    final content = _controller.document.toJson();
    await firestore.collection('mind_dumps').doc(docId).set({
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    _saveMindDump();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
      body: Column(
        children: [
          ZefyrToolbar.basic(controller: _controller),
          Expanded(
            child: Container(
              color: Colors.black,
              child: ZefyrEditor(
                controller: _controller,
                focusNode: _focusNode,
                readOnly: false,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/