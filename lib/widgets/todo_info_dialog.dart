import 'package:flutter/cupertino.dart';
import '../models/todo.dart';

class TodoInfoDialog extends StatelessWidget {
  final Todo todo;

  const TodoInfoDialog({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width > 700 ? 500 : MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 400),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.systemGrey5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'ۋەزىپە تەپسىلاتى',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'UKIJ',
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Icon(CupertinoIcons.xmark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoSection(
                      title: 'ماۋزۇ',
                      content: todo.title,
                    ),
                    if (todo.details != null) ...[
                      const SizedBox(height: 16),
                      _InfoSection(
                        title: 'تەپسىلاتلار',
                        content: todo.details!,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _InfoSection(
                      title: 'قۇرۇلغان ۋاقىت',
                      content: _formatDateTime(todo.createdAt),
                    ),
                    if (todo.dueDate != null) ...[
                      const SizedBox(height: 16),
                      _InfoSection(
                        title: 'تاماملاش ۋاقتى',
                        content: _formatDateTime(todo.dueDate!),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _InfoSection(
                      title: 'ھالىتى',
                      content: todo.isCompleted ? 'تاماملاندى' : 'تاماملانمىدى',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String content;

  const _InfoSection({
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 14,
            fontFamily: 'UKIJ',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'UKIJ',
          ),
        ),
      ],
    );
  }
} 