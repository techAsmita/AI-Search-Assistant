import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HistoryItem {
  final String question;
  final String answer;
  final DateTime timestamp;

  HistoryItem({
    required this.question,
    required this.answer,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      question: json['question'] as String,
      answer: json['answer'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class HistoryService {
  static const String _key = 'chat_history';
  static const int _maxItems = 20;

  static Future<List<HistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_key);

    if (raw == null || raw.isEmpty) return [];

    final List decoded = jsonDecode(raw);
    return decoded
        .map((item) => HistoryItem.fromJson(item as Map<String, dynamic>))
        .toList()
        .reversed
        .toList(); // newest first
  }

  static Future<void> addItem({
    required String question,
    required String answer,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getHistory();

    // Avoid exact duplicates at the top
    if (current.isNotEmpty &&
        current.first.question == question &&
        current.first.answer == answer) {
      return;
    }

    final newItem = HistoryItem(
      question: question,
      answer: answer,
      timestamp: DateTime.now(),
    );

    final updated = [newItem, ...current];

    // Keep only the latest 20 items
    final limited = updated.take(_maxItems).toList();

    final encoded = jsonEncode(limited.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
