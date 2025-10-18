import 'package:flutter/material.dart';
import 'package:mealtime/models/weight_entry_model.dart';

class WeightEntryTile extends StatelessWidget {
  final WeightEntry entry;
  final VoidCallback? onTap;

  const WeightEntryTile({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.monitor_weight,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          '${entry.weight.toStringAsFixed(1)} kg',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatDateTime(entry.timestamp)),
            if (entry.notes != null) ...[
              const SizedBox(height: 2),
              Text(
                entry.notes!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getMeasurementTypeIcon(entry.measurementType),
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              _getMeasurementTypeText(entry.measurementType),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final entryDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateText;
    if (entryDate == today) {
      dateText = 'Hoje';
    } else if (entryDate == yesterday) {
      dateText = 'Ontem';
    } else {
      dateText = '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}/'
          '${dateTime.year}';
    }
    
    return '$dateText às ${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  IconData _getMeasurementTypeIcon(String? type) {
    switch (type) {
      case 'smart_scale':
        return Icons.smart_toy;
      case 'vet_visit':
        return Icons.medical_services;
      case 'home_scale':
        return Icons.scale;
      default:
        return Icons.edit;
    }
  }

  String _getMeasurementTypeText(String? type) {
    switch (type) {
      case 'smart_scale':
        return 'Balança';
      case 'vet_visit':
        return 'Veterinário';
      case 'home_scale':
        return 'Casa';
      default:
        return 'Manual';
    }
  }
}
