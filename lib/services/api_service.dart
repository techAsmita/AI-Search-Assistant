import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:perplexity_clone/config.dart';
import 'package:perplexity_clone/models/quiz_models.dart';

class ApiService {
  static const String baseUrl = AppConfig.apiBaseUrl;
  static const Duration _timeout = Duration(seconds: 25);

  static Future<String> getAnswer(String query) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/chat"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"query": query}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["answer"] ?? "No answer received";
      } else {
        return "Sorry, the server returned an error (${response.statusCode}). Please try again.";
      }
    } on TimeoutException {
      return "The request timed out. Please check your connection and try again.";
    } on http.ClientException {
      return "Unable to reach the server. Make sure the backend is running.";
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  static Future<List<QuizQuestion>> generateQuiz(String answerText) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/generate-quiz"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"text": answerText}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List questionsJson = data["questions"] ?? [];
        return questionsJson
            .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception("Server error ${response.statusCode}");
      }
    } on TimeoutException {
      throw Exception("Request timed out. Please try again.");
    } on http.ClientException {
      throw Exception("Unable to reach the server.");
    } catch (e) {
      throw Exception("Failed to generate quiz. Please try again.");
    }
  }
}
