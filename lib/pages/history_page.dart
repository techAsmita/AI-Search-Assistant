import 'package:flutter/material.dart';
import 'package:perplexity_clone/services/history_service.dart';
import 'package:perplexity_clone/theme/colors.dart';

class HistoryPage extends StatefulWidget {
  final Function(String question, String answer) onSelect;

  const HistoryPage({super.key, required this.onSelect});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<HistoryItem> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final items = await HistoryService.getHistory();
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _clearAll() async {
    await HistoryService.clearHistory();
    setState(() {
      _items = [];
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.sideNav,
        title: const Text(
          "History",
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        iconTheme: const IconThemeData(color: AppColors.iconGrey),
        elevation: 0,
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text(
                "Clear",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : _items.isEmpty
          ? const Center(
              child: Text(
                "No history yet.\nAsk something to get started.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _items.length,
              separatorBuilder: (_, _) =>
                  const Divider(color: AppColors.searchBarBorder, height: 1),
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  title: Text(
                    item.question,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _formatTime(item.timestamp),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                    widget.onSelect(item.question, item.answer);
                    Navigator.pop(context);
                  },
                );
              },
            ),
    );
  }
}
