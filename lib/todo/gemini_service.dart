import 'dart:async';
import 'package:firebase_vertexai/firebase_vertexai.dart';

class GeminiService {
  static final _model = FirebaseVertexAI.instance.generativeModel(
    model: 'models/gemini-2.0-flash-001', 
  );

  static Future<String?> generateTaskBreakdown(String task) async {
    final prompt = 'Break down the task "$task" into detailed, manageable steps.';
    try {
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);
      return response.text;
    } catch (e) {
      print('❌ Gemini Task Breakdown Error: $e');
      return null;
    }
  }

  static Future<String?> generateDailySummary(List<String> tasks) async {
    final prompt = 'Give a short motivational daily summary based on these tasks: ${tasks.join(", ")}';
    try {
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);
      return response.text;
    } catch (e) {
      print('❌ Gemini Daily Summary Error: $e');
      return null;
    }
  }

  static Future<String?> generateCustom(String prompt) async {
    try {
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);
      return response.text;
    } catch (e) {
      print('❌ Gemini Custom Prompt Error: $e');
      return null;
    }
  }
}
