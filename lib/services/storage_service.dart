import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

/// Сервис для работы с локальным хранилищем телефона
/// Использует SharedPreferences для сохранения данных
class StorageService {
  static const String _tasksKey = 'todo_tasks';

  // Синглтон
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// Сохранение списка задач в память телефона
  Future<bool> saveTasks(List<Task> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = Task.encodeTaskList(tasks);
      return await prefs.setString(_tasksKey, jsonString);
    } catch (e) {
      print('Ошибка сохранения задач: $e');
      return false;
    }
  }

  /// Загрузка списка задач из памяти телефона
  Future<List<Task>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_tasksKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      return Task.decodeTaskList(jsonString);
    } catch (e) {
      print('Ошибка загрузки задач: $e');
      return [];
    }
  }

  /// Очистка всех сохранённых задач
  Future<bool> clearTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_tasksKey);
    } catch (e) {
      print('Ошибка очистки задач: $e');
      return false;
    }
  }
}
