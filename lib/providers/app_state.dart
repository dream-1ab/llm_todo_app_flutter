import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../models/app_theme.dart';
import '../services/chat_service.dart';

// Base Operation class
abstract class _Operation {
  final DateTime timestamp;

  _Operation() : timestamp = DateTime.now();

  void apply(AppState state);
  void undo(AppState state);
}

// Concrete Operation classes
class AddTodoOperation extends _Operation {
  final Todo todo;

  AddTodoOperation(this.todo);

  @override
  void apply(AppState state) {
    state._todos.add(todo);
  }

  @override
  void undo(AppState state) {
    state._todos.removeWhere((t) => t.id == todo.id);
  }
}

class DeleteTodoOperation extends _Operation {
  final Todo todo;
  final int index;

  DeleteTodoOperation(this.todo, this.index);

  @override
  void apply(AppState state) {
    state._todos.removeAt(index);
  }

  @override
  void undo(AppState state) {
    state._todos.insert(index, todo);
  }
}

class ToggleTodoOperation extends _Operation {
  final String todoId;
  final bool previousState;

  ToggleTodoOperation(this.todoId, this.previousState);

  @override
  void apply(AppState state) {
    final todo = state._todos.firstWhere((t) => t.id == todoId);
    todo.isCompleted = !previousState;
  }

  @override
  void undo(AppState state) {
    final todo = state._todos.firstWhere((t) => t.id == todoId);
    todo.isCompleted = previousState;
  }
}

class ChangeThemeOperation extends _Operation {
  final AppTheme newTheme;
  final AppTheme previousTheme;

  ChangeThemeOperation(this.newTheme, this.previousTheme);

  @override
  void apply(AppState state) {
    state._theme = newTheme;
  }

  @override
  void undo(AppState state) {
    state._theme = previousTheme;
  }
}

class ClearCompletedOperation extends _Operation {
  final List<Todo> completedTodos;
  final List<int> originalIndices;

  ClearCompletedOperation(this.completedTodos, this.originalIndices);

  @override
  void apply(AppState state) {
    state._todos.removeWhere((todo) => completedTodos.any((t) => t.id == todo.id));
  }

  @override
  void undo(AppState state) {
    for (var i = 0; i < completedTodos.length; i++) {
      state._todos.insert(originalIndices[i], completedTodos[i]);
    }
  }
}

class ReorderTodoOperation extends _Operation {
  final Todo todo;
  final int oldIndex;
  final int newIndex;

  ReorderTodoOperation(this.todo, this.oldIndex, this.newIndex);

  @override
  void apply(AppState state) {
    final todo = state._todos.removeAt(oldIndex);
    state._todos.insert(newIndex, todo);
  }

  @override
  void undo(AppState state) {
    final todo = state._todos.removeAt(newIndex);
    state._todos.insert(oldIndex, todo);
  }
}



class AppState extends ChangeNotifier {
  final List<Todo> _todos = [];
  final List<_Operation> _history = [];
  final List<_Operation> _undoneHistory = [];
  late final ChatService chatService = ChatService(this);
  static const int _maxHistorySize = 100;
  AppTheme _theme = AppTheme.light;

  // Getters
  List<Todo> get todos => List.unmodifiable(_todos);
  List<Todo> get completedTodos => _todos.where((todo) => todo.isCompleted).toList();
  List<Todo> get uncompletedTodos => _todos.where((todo) => !todo.isCompleted).toList();
  AppTheme get theme => _theme;


  // History management
  void _addToHistory(_Operation operation) {
    _history.add(operation);
    _undoneHistory.clear();
    if (_history.length > _maxHistorySize) {
      _history.removeAt(0);
    }
    operation.apply(this);
    notifyListeners();
  }

  // Operations now use specific operation classes
  void addTodo(String title, String? details, DateTime? dueDate) {
    final todo = Todo(
      title: title,
      details: details,
      dueDate: dueDate,
    );
    _addToHistory(AddTodoOperation(todo));
  }

  void removeTodo(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _addToHistory(DeleteTodoOperation(_todos[index], index));
    }
  }

  void toggleTodo(String id) {
    final todo = _todos.firstWhere((todo) => todo.id == id);
    _addToHistory(ToggleTodoOperation(id, todo.isCompleted));
  }

  void setTheme(AppTheme newTheme) {
    _addToHistory(ChangeThemeOperation(newTheme, _theme));
  }

  void clearCompletedTodos() {
    final completedTodos = _todos.where((todo) => todo.isCompleted).toList();
    if (completedTodos.isEmpty) return;

    final indices = completedTodos
        .map((todo) => _todos.indexWhere((t) => t.id == todo.id))
        .toList();
    _addToHistory(ClearCompletedOperation(completedTodos, indices));
  }

  void reorderTodos(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    _addToHistory(ReorderTodoOperation(_todos[oldIndex], oldIndex, newIndex));
  }

  // Undo/Redo functionality
  bool canUndo() => _history.isNotEmpty;
  bool canRedo() => _undoneHistory.isNotEmpty;

  void undo() {
    if (!canUndo()) return;
    
    final operation = _history.removeLast();
    operation.undo(this);
    _undoneHistory.add(operation);
    notifyListeners();
  }

  void redo() {
    if (!canRedo()) return;
    
    final operation = _undoneHistory.removeLast();
    operation.apply(this);
    _history.add(operation);
    notifyListeners();
  }

  // Debug helper with improved type information
  List<String> getHistoryDescription() {
    return _history.map((op) => '${op.timestamp}: ${op.runtimeType}').toList();
  }

  @override
  void dispose() {
    chatService.dispose();
    super.dispose();
  }
}