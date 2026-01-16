import 'package:flutter/material.dart';
import '../providers/task_provider.dart';

/// Виджет с чипами для фильтрации задач
class FilterChips extends StatelessWidget {
  final TaskFilter currentFilter;
  final int activeCount;
  final int completedCount;
  final Function(TaskFilter) onFilterChanged;

  const FilterChips({
    super.key,
    required this.currentFilter,
    required this.activeCount,
    required this.completedCount,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildChip(
            context,
            label: 'Все',
            filter: TaskFilter.all,
            count: activeCount + completedCount,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: 'Текущие',
            filter: TaskFilter.active,
            count: activeCount,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: 'Выполненные',
            filter: TaskFilter.completed,
            count: completedCount,
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required TaskFilter filter,
    required int count,
  }) {
    final isSelected = currentFilter == filter;

    return Expanded(
      child: GestureDetector(
        onTap: () => onFilterChanged(filter),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
