import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

/// Перечисление для фильтрации задач
enum TaskFilter {
  all,       // Все задачи
  active,    // Текущие (невыполненные)
  completed, // Выполненные
}

/// Провайдер для управления состоянием списка задач
/// Использует паттерн ChangeNotifier для уведомления слушателей об изменениях
class TaskProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final Uuid _uuid = const Uuid();

  List<Task> _tasks = [];
  TaskFilter _currentFilter = TaskFilter.all;
  bool _isLoading = false;

  // Геттеры
  List<Task> get tasks => _tasks;
  TaskFilter get currentFilter => _currentFilter;
  bool get isLoading => _isLoading;

  /// Получить отфильтрованный список задач
  List<Task> get filteredTasks {
    switch (_currentFilter) {
      case TaskFilter.active:
        return _tasks.where((task) => !task.isCompleted).toList();
      case TaskFilter.completed:
        return _tasks.where((task) => task.isCompleted).toList();
      case TaskFilter.all:
      default:
        return _tasks;
    }
  }

  /// Количество активных задач
  int get activeTasksCount => _tasks.where((task) => !task.isCompleted).length;

  /// Количество выполненных задач
  int get completedTasksCount => _tasks.where((task) => task.isCompleted).length;

  /// Инициализация - загрузка задач из памяти
  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    _tasks = await _storageService.loadTasks();

    // Сортировка: сначала новые задачи
    _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _isLoading = false;
    notifyListeners();
  }

  /// Добавление новой задачи
  Future<void> addTask({
    required String title,
    String description = '',
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
    );

    _tasks.insert(0, task); // Добавляем в начало списка
    notifyListeners();

    await _storageService.saveTasks(_tasks);
  }

  /// Обновление существующей задачи
  Future<void> updateTask({
    required String id,
    String? title,
    String? description,
    bool? isCompleted,
  }) async {
    final index = _tasks.indexWhere((task) => task.id == id);

    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        title: title,
        description: description,
        isCompleted: isCompleted,
      );

      notifyListeners();
      await _storageService.saveTasks(_tasks);
    }
  }

  /// Переключение статуса выполнения задачи
  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);

    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );

      notifyListeners();
      await _storageService.saveTasks(_tasks);
    }
  }

  /// Удаление задачи
  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((task) => task.id == id);
    notifyListeners();

    await _storageService.saveTasks(_tasks);
  }

  /// Изменение текущего фильтра
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  /// Получение задачи по ID
  Task? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Удаление всех выполненных задач
  Future<void> clearCompletedTasks() async {
    _tasks.removeWhere((task) => task.isCompleted);
    notifyListeners();

    await _storageService.saveTasks(_tasks);
  }
}
