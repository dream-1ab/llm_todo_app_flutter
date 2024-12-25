import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/app_state.dart';
import 'todo_info_dialog.dart';

class TodoList extends StatelessWidget {
  final List<Todo> todos;

  const TodoList({
    super.key,
    required this.todos,
  });

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return GestureDetector(
          onTap: () {
            showCupertinoDialog(
              context: context,
              builder: (context) => TodoInfoDialog(todo: todo),
            );
          },
          child: CupertinoListTile(
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                fontFamily: 'UKIJ',
              ),
            ),
            subtitle: todo.details != null
                ? Text(
                    todo.details!,
                    style: TextStyle(
                      decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                      fontFamily: 'UKIJ',
                    ),
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (todo.dueDate != null)
                  Text(
                    _formatDate(todo.dueDate!),
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey,
                      fontSize: 12,
                    ),
                  ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Icon(
                    todo.isCompleted
                        ? CupertinoIcons.check_mark_circled_solid
                        : CupertinoIcons.circle,
                    color: todo.isCompleted
                        ? CupertinoColors.activeGreen
                        : CupertinoColors.systemGrey,
                  ),
                  onPressed: () => appState.toggleTodo(todo.id),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: const Icon(
                    CupertinoIcons.delete,
                    color: CupertinoColors.systemRed,
                  ),
                  onPressed: () => appState.removeTodo(todo.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
} 