import 'package:flutter/foundation.dart';
import 'package:hello_flutter_llm/models/app_theme.dart';
import 'package:hello_flutter_llm/providers/app_state.dart';

// Base class for all requests
abstract class LLMDecision {
  Map<String, dynamic> toJson();

  void execute(AppState appState);
}

// For add_new_task function
class AddTaskLLMDecition extends LLMDecision {
  final String title;
  final String description;
  final DateTime dueDate;

  AddTaskLLMDecition({
    required this.title,
    required this.description,
    required this.dueDate,
  });

  @override
  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'due_date': dueDate.toIso8601String(),
  };

  @override
  void execute(AppState appState) {
    appState.addTodo(title, description, dueDate);
  }

  factory AddTaskLLMDecition.fromJson(Map<String, dynamic> json) => AddTaskLLMDecition(
    title: json['title'] as String,
    description: json['description'] as String,
    dueDate: DateTime.parse(json['due_date'] as String),
  );
}

// For complete_task function
class CompleteTaskLLMDecition extends LLMDecision {
  final String taskId;

  CompleteTaskLLMDecition({required this.taskId});

  @override
  Map<String, dynamic> toJson() => {'task_id': taskId};

  @override
  void execute(AppState appState) {
    appState.toggleTodo(taskId);
  }

  factory CompleteTaskLLMDecition.fromJson(Map<String, dynamic> json) => 
    CompleteTaskLLMDecition(taskId: json['task_id'] as String);
}

// For delete_task function
class DeleteTaskLLMDecition extends LLMDecision {
  final String taskId;

  DeleteTaskLLMDecition({required this.taskId});

  @override
  Map<String, dynamic> toJson() => {'task_id': taskId};

  @override
  void execute(AppState appState) {
    appState.removeTodo(taskId);
  }

  factory DeleteTaskLLMDecition.fromJson(Map<String, dynamic> json) => 
    DeleteTaskLLMDecition(taskId: json['task_id'] as String);
}

// For undo_previous_operation function
class UndoOperationLLMDecition extends LLMDecision {
  final int undoCount;

  UndoOperationLLMDecition({required this.undoCount});

  @override
  Map<String, dynamic> toJson() => {'undo_count': undoCount};

  @override
  void execute(AppState appState) {
    for (int i = 0; i < undoCount; i++) {
      appState.undo();
    }
  }

  factory UndoOperationLLMDecition.fromJson(Map<String, dynamic> json) => 
    UndoOperationLLMDecition(undoCount: json['undo_count'] as int);
}

// For change_app_color_theme function
class ChangeThemeLLMDecition extends LLMDecision {
  final String theme;

  ChangeThemeLLMDecition({required this.theme});

  @override
  Map<String, dynamic> toJson() => {'theme': theme};

  @override
  void execute(AppState appState) {
    appState.setTheme(AppTheme.presets.firstWhere((e) => e.name == theme));
  }

  factory ChangeThemeLLMDecition.fromJson(Map<String, dynamic> json) => 
    ChangeThemeLLMDecition(theme: json['theme'] as String);
}

// Wrapper class for all possible function calls
@immutable
class ChatFunctionCall {
  final String name;
  final Map<String, dynamic> arguments;

  const ChatFunctionCall({
    required this.name,
    required this.arguments,
  });

  dynamic parseArguments() {
    switch (name) {
      case 'add_new_task':
        return AddTaskLLMDecition.fromJson(arguments);
      case 'complete_task':
        return CompleteTaskLLMDecition.fromJson(arguments);
      case 'delete_task':
        return DeleteTaskLLMDecition.fromJson(arguments);
      case 'undo_previous_operation':
        return UndoOperationLLMDecition.fromJson(arguments);
      case 'change_app_color_theme':
        return ChangeThemeLLMDecition.fromJson(arguments);
      default:
        throw ArgumentError('Unknown function name: $name');
    }
  }
} 