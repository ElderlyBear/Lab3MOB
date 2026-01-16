import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chips.dart';
import 'task_screen.dart';

/// Главный экран приложения со списком задач
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Загружаем задачи при инициализации экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Todo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          // Кнопка очистки выполненных задач
          Consumer<TaskProvider>(
            builder: (context, provider, child) {
              if (provider.completedTasksCount == 0) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Удалить выполненные',
                onPressed: () => _showClearCompletedDialog(context, provider),
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // Фильтры
              Container(
                color: Colors.white,
                child: FilterChips(
                  currentFilter: provider.currentFilter,
                  activeCount: provider.activeTasksCount,
                  completedCount: provider.completedTasksCount,
                  onFilterChanged: (filter) => provider.setFilter(filter),
                ),
              ),
              const SizedBox(height: 8),
              // Список задач
              Expanded(
                child: _buildTaskList(provider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToTaskScreen(context),
        icon: const Icon(Icons.add),
        label: const Text('Добавить'),
        elevation: 4,
      ),
    );
  }

  /// Построение списка задач
  Widget _buildTaskList(TaskProvider provider) {
    final tasks = provider.filteredTasks;

    if (tasks.isEmpty) {
      return _buildEmptyState(provider.currentFilter);
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTile(
          task: task,
          onToggle: () => provider.toggleTaskCompletion(task.id),
          onTap: () => _navigateToTaskScreen(context, taskId: task.id),
        );
      },
    );
  }

  /// Виджет пустого состояния в зависимости от фильтра
  Widget _buildEmptyState(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.active:
        return const EmptyState(
          icon: Icons.check_circle_outline,
          title: 'Все задачи выполнены!',
          subtitle: 'Отличная работа! Добавьте новые задачи.',
        );
      case TaskFilter.completed:
        return const EmptyState(
          icon: Icons.pending_actions_outlined,
          title: 'Нет выполненных задач',
          subtitle: 'Выполненные задачи появятся здесь.',
        );
      case TaskFilter.all:
      default:
        return const EmptyState(
          icon: Icons.inbox_outlined,
          title: 'Нет запланированных задач',
          subtitle: 'Нажмите "Добавить" чтобы создать первую задачу.',
        );
    }
  }

  /// Переход на экран добавления/редактирования задачи
  void _navigateToTaskScreen(BuildContext context, {String? taskId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskScreen(taskId: taskId),
      ),
    );
  }

  /// Диалог подтверждения удаления выполненных задач
  void _showClearCompletedDialog(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить выполненные задачи?'),
        content: Text(
          'Будет удалено ${provider.completedTasksCount} задач(и). '
          'Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              provider.clearCompletedTasks();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Выполненные задачи удалены'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
