import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

/// Экран добавления и редактирования задачи
class TaskScreen extends StatefulWidget {
  final String? taskId;

  const TaskScreen({super.key, this.taskId});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isEditing = false;
  Task? _existingTask;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.taskId != null;

    if (_isEditing) {
      // Загружаем данные существующей задачи
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingTask();
      });
    }
  }

  void _loadExistingTask() {
    final provider = context.read<TaskProvider>();
    _existingTask = provider.getTaskById(widget.taskId!);

    if (_existingTask != null) {
      _titleController.text = _existingTask!.title;
      _descriptionController.text = _existingTask!.description;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Редактирование' : 'Новая задача',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          // Кнопка удаления (только при редактировании)
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Удалить задачу',
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Статус задачи (только при редактировании)
            if (_isEditing && _existingTask != null) ...[
              _buildStatusCard(),
              const SizedBox(height: 24),
            ],

            // Поле названия
            _buildInputCard(
              title: 'Название задачи',
              child: TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Введите название задачи',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 16),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Пожалуйста, введите название';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 16),

            // Поле описания
            _buildInputCard(
              title: 'Описание',
              child: TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Добавьте описание (необязательно)',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(fontSize: 16),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 5,
                minLines: 3,
              ),
            ),

            const SizedBox(height: 32),

            // Кнопка сохранения
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  _isEditing ? 'Сохранить изменения' : 'Создать задачу',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Кнопка отмены
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Отмена',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Карточка статуса задачи
  Widget _buildStatusCard() {
    return Card(
      elevation: 0,
      color: _existingTask!.isCompleted
          ? Colors.green.shade50
          : Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          _existingTask!.isCompleted
              ? Icons.check_circle
              : Icons.pending_outlined,
          color: _existingTask!.isCompleted
              ? Colors.green
              : Colors.orange,
        ),
        title: Text(
          _existingTask!.isCompleted ? 'Выполнено' : 'В процессе',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: _existingTask!.isCompleted
                ? Colors.green.shade700
                : Colors.orange.shade700,
          ),
        ),
        trailing: TextButton(
          onPressed: _toggleStatus,
          child: Text(
            _existingTask!.isCompleted
                ? 'Вернуть в работу'
                : 'Отметить выполненной',
          ),
        ),
      ),
    );
  }

  /// Карточка с полем ввода
  Widget _buildInputCard({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: child,
        ),
      ],
    );
  }

  /// Сохранение задачи
  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<TaskProvider>();

      if (_isEditing) {
        provider.updateTask(
          id: widget.taskId!,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
        );
      } else {
        provider.addTask(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
        );
      }

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Задача обновлена' : 'Задача создана'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Переключение статуса задачи
  void _toggleStatus() {
    final provider = context.read<TaskProvider>();
    provider.toggleTaskCompletion(widget.taskId!);

    // Обновляем локальное состояние
    _existingTask = provider.getTaskById(widget.taskId!);
    setState(() {});
  }

  /// Диалог подтверждения удаления
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить задачу?'),
        content: const Text(
          'Это действие нельзя отменить.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(widget.taskId!);
              Navigator.pop(context); // Закрываем диалог
              Navigator.pop(context); // Возвращаемся на главный экран

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Задача удалена'),
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
