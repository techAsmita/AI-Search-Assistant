import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:perplexity_clone/theme/colors.dart';
import 'package:perplexity_clone/widgets/side_bar.dart';
import 'package:perplexity_clone/services/api_service.dart';
import 'package:perplexity_clone/services/history_service.dart';
import 'package:perplexity_clone/pages/quiz_page.dart';
import 'package:perplexity_clone/pages/history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _answer;
  String? _error;
  bool _isSidebarCollapsed = false;

  Future<void> _askQuestion({String? customQuery}) async {
    final query = (customQuery ?? _controller.text).trim();

    // Input validation
    if (query.isEmpty) {
      setState(() {
        _error = "Please enter a question.";
        _answer = null;
      });
      return;
    }

    if (query.length > 500) {
      setState(() {
        _error = "Question is too long. Please keep it under 500 characters.";
        _answer = null;
      });
      return;
    }

    // Prevent duplicate submissions
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _answer = null;
      _error = null;
    });

    final result = await ApiService.getAnswer(query);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.startsWith("Error:") ||
          result.startsWith("Failed to connect")) {
        _error = result;
        _answer = null;
      } else {
        _answer = result;
        _error = null;

        // Save to local history
        HistoryService.addItem(question: query, answer: result);
      }
    });
  }

  Future<void> _startQuiz() async {
    if (_answer == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final questions = await ApiService.generateQuiz(_answer!);

      if (!mounted) return;

      if (questions.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = "Could not generate quiz questions. Try again.";
        });
        return;
      }

      setState(() {
        _isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuizPage(questions: questions)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = "Failed to start quiz: $e";
      });
    }
  }

  void _newChat() {
    setState(() {
      _controller.clear();
      _answer = null;
      _error = null;
      _isLoading = false;
    });
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HistoryPage(
          onSelect: (question, answer) {
            setState(() {
              _controller.text = question;
              _answer = answer;
              _error = null;
              _isLoading = false;
            });
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool shouldCollapse = constraints.maxWidth < 800;
          final bool collapsed = shouldCollapse || _isSidebarCollapsed;

          return Row(
            children: [
              SideBar(
                isCollapsed: collapsed,
                onToggle: () {
                  setState(() {
                    _isSidebarCollapsed = !_isSidebarCollapsed;
                  });
                },
                onNewChat: _newChat,
                onHistory: _openHistory,
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Where knowledge begins",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Ask anything. Get clear, AI-powered answers.",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 48),

                              // Search Bar
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 720,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.searchBar,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.searchBarBorder,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.search,
                                          color: AppColors.iconGrey,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: TextField(
                                            controller: _controller,
                                            enabled: !_isLoading,
                                            decoration: const InputDecoration(
                                              hintText: "Ask anything...",
                                              hintStyle: TextStyle(
                                                color: AppColors.textMuted,
                                                fontSize: 16,
                                              ),
                                              border: InputBorder.none,
                                            ),
                                            style: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 16,
                                            ),
                                            onSubmitted: (_) => _askQuestion(),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.only(
                                            left: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _isLoading
                                                ? AppColors.accent.withOpacity(
                                                    0.6,
                                                  )
                                                : AppColors.accent,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: IconButton(
                                            onPressed: _isLoading
                                                ? null
                                                : () => _askQuestion(),
                                            icon: _isLoading
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white,
                                                        ),
                                                  )
                                                : const Icon(
                                                    Icons.arrow_upward,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Empty State + Suggestion Chips
                              if (!_isLoading &&
                                  _answer == null &&
                                  _error == null) ...[
                                const SizedBox(height: 16),
                                const Text(
                                  "Try asking one of these",
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    _buildSuggestionChip("What is Flutter?"),
                                    _buildSuggestionChip(
                                      "Explain Clean Architecture",
                                    ),
                                    _buildSuggestionChip(
                                      "Best state management 2025",
                                    ),
                                    _buildSuggestionChip(
                                      "How does Gemini work?",
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 32),

                              // Loading Skeleton
                              if (_isLoading)
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 720,
                                  ),
                                  child: Column(
                                    children: [
                                      _buildSkeletonBox(
                                        height: 18,
                                        width: double.infinity,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildSkeletonBox(
                                        height: 18,
                                        width: double.infinity,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildSkeletonBox(height: 18, width: 400),
                                      const SizedBox(height: 24),
                                      _buildSkeletonBox(
                                        height: 18,
                                        width: double.infinity,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildSkeletonBox(
                                        height: 18,
                                        width: double.infinity,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildSkeletonBox(height: 18, width: 300),
                                    ],
                                  ),
                                ),

                              // Error State
                              if (_error != null && !_isLoading)
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 720,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      _error!,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),

                              // Answer Section
                              if (_answer != null && !_isLoading)
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 720,
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.fromLTRB(
                                      22,
                                      22,
                                      22,
                                      18,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.card,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.searchBarBorder,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MarkdownBody(
                                          data: _answer!,
                                          selectable: true,
                                          styleSheet: MarkdownStyleSheet(
                                            p: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 15.5,
                                              height: 1.65,
                                            ),
                                            h1: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              height: 1.3,
                                            ),
                                            h2: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              height: 1.35,
                                            ),
                                            h3: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                              height: 1.4,
                                            ),
                                            strong: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                            em: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            listBullet: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 15.5,
                                            ),
                                            listIndent: 20,
                                            blockquote: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 15,
                                              height: 1.5,
                                            ),
                                            blockquoteDecoration: BoxDecoration(
                                              color: AppColors.searchBar
                                                  .withOpacity(0.6),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: const Border(
                                                left: BorderSide(
                                                  color: AppColors.accent,
                                                  width: 3,
                                                ),
                                              ),
                                            ),
                                            code: TextStyle(
                                              backgroundColor:
                                                  AppColors.searchBar,
                                              color: AppColors.accent,
                                              fontSize: 13.5,
                                              fontFamily: 'monospace',
                                            ),
                                            codeblockDecoration: BoxDecoration(
                                              color: const Color(0xFF161616),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color:
                                                    AppColors.searchBarBorder,
                                              ),
                                            ),
                                            codeblockPadding:
                                                const EdgeInsets.all(14),
                                            tableHead: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                            tableBody: const TextStyle(
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                            tableBorder: TableBorder.all(
                                              color: AppColors.searchBarBorder,
                                              width: 1,
                                            ),
                                            tableCellsPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                            horizontalRuleDecoration:
                                                BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                      color: AppColors
                                                          .searchBarBorder
                                                          .withOpacity(0.7),
                                                      width: 1,
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 22),
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: _isLoading
                                                ? null
                                                : _startQuiz,
                                            icon: const Icon(
                                              Icons.quiz_outlined,
                                              size: 18,
                                              color: AppColors.accent,
                                            ),
                                            label: const Text(
                                              "Quiz me on this",
                                              style: TextStyle(
                                                color: AppColors.accent,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                color: AppColors.accent,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Footer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      color: AppColors.footer,
                      child: const Center(
                        child: Text(
                          "Perplexity Clone • Built with Flutter",
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(
        text,
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
      backgroundColor: AppColors.card,
      side: const BorderSide(color: AppColors.searchBarBorder),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: _isLoading
          ? null
          : () {
              _controller.text = text;
              _askQuestion(customQuery: text);
            },
    );
  }

  Widget _buildSkeletonBox({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.searchBar,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
