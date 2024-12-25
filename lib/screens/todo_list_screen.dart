import 'package:flutter/cupertino.dart';
import 'package:hello_flutter_llm/providers/app_state.dart';
import '../models/todo.dart';
import '../widgets/todo_input_dialog.dart';
import '../widgets/todo_list.dart';
import '../widgets/theme_settings_dialog.dart';
import '../widgets/floating_chat_button.dart';
import 'package:provider/provider.dart';
import 'package:provider/provider.dart';
import 'package:hello_flutter_llm/providers/app_state.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'ۋاقىت ئورۇنلاشتۇرغۇچ',
          style: TextStyle(fontFamily: 'UKIJ'),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.paintbrush),
          onPressed: () {
            showCupertinoDialog(
              context: context,
              builder: (context) => const ThemeSettingsDialog(),
            );
          },
        ),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CupertinoButton.filled(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => TodoInputDialog(
                          onSubmit: appState.addTodo,
                        ),
                      );
                    },
                    child: const Text('يېڭى ۋەزىپە قوشۇش'),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > constraints.maxHeight) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTodoSection('ۋەزىپىلەر', appState.uncompletedTodos),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: _buildTodoSection('تاماملانغانلىرى', appState.completedTodos),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            Expanded(
                              child: _buildTodoSection('ۋەزىپىلەر', appState.uncompletedTodos),
                            ),
                            if (appState.completedTodos.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Expanded(
                                child: _buildTodoSection('تاماملانغانلىرى', appState.completedTodos),
                              ),
                            ],
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const FloatingChatButton(),
        ],
      ),
    );
  }

  Widget _buildTodoSection(String title, List<Todo> todos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: CupertinoColors.systemGrey5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TodoList(
                todos: todos,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 