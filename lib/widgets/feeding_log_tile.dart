import 'package:flutter/material.dart';
import 'package:mealtime/models/feeding_model.dart';

class FeedingLogTile extends StatelessWidget {
  final Feeding feeding;
  final VoidCallback? onTap;

  const FeedingLogTile({super.key, required this.feeding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: feeding.wasEaten ? Colors.green : Colors.orange,
          child: Icon(
            feeding.wasEaten ? Icons.restaurant : Icons.restaurant_menu,
            color: Colors.white,
          ),
        ),
        title: Text(
          _formatDateTime(feeding.timestamp),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (feeding.portionSize != null) ...[
              Text('Quantidade: ${feeding.portionSize!.toStringAsFixed(1)}g'),
            ],
            if (feeding.foodType != null) ...[
              Text('Tipo: ${feeding.foodType}'),
            ],
            if (feeding.notes != null) ...[
              const SizedBox(height: 2),
              Text(
                feeding.notes!,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: feeding.wasEaten
                    ? Colors.green.withAlpha(25)
                    : Colors.orange.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                feeding.wasEaten ? 'Comido' : 'Recusado',
                style: TextStyle(
                  color: feeding.wasEaten ? Colors.green : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getTimeAgo(feeding.timestamp),
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
      dateText =
          '${dateTime.day.toString().padLeft(2, '0')}/'
          '${dateTime.month.toString().padLeft(2, '0')}';
    }

    return '$dateText às ${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m atrás';
    } else {
      return 'Agora';
    }
  }
}
