import 'package:flutter/material.dart';
import 'package:mealtime/models/cat_model.dart';

class NextFeedingCountdown extends StatefulWidget {
  final List<Cat> cats;

  const NextFeedingCountdown({
    super.key,
    required this.cats,
  });

  @override
  State<NextFeedingCountdown> createState() => _NextFeedingCountdownState();
}

class _NextFeedingCountdownState extends State<NextFeedingCountdown> {
  @override
  void initState() {
    super.initState();
    // Update every minute
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {});
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nextFeeding = _getNextFeeding();
    
    if (nextFeeding == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.schedule,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Próxima alimentação',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    '${nextFeeding.cat.name} - ${nextFeeding.timeText}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (nextFeeding.isOverdue)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ATRASADO',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  NextFeeding? _getNextFeeding() {
    final now = DateTime.now();
    NextFeeding? closest;

    for (final cat in widget.cats) {
      if (!cat.schedule.isActive) continue;

      final nextTime = _getNextFeedingTime(cat, now);
      if (nextTime == null) continue;

      if (closest == null || nextTime.isBefore(closest.nextTime)) {
        closest = NextFeeding(
          cat: cat,
          nextTime: nextTime,
          timeText: _formatTimeDifference(nextTime, now),
          isOverdue: nextTime.isBefore(now),
        );
      }
    }

    return closest;
  }

  DateTime? _getNextFeedingTime(Cat cat, DateTime now) {
    if (cat.schedule.type == ScheduleType.fixedInterval && cat.schedule.intervalHours != null) {
      if (cat.schedule.lastFed != null) {
        return cat.schedule.lastFed!.add(Duration(hours: cat.schedule.intervalHours!));
      } else {
        // If never fed, assume first feeding is due now
        return now;
      }
    } else if (cat.schedule.type == ScheduleType.specificTimes && cat.schedule.specificTimes != null) {
      // Find next specific time today
      final todayTimes = cat.schedule.specificTimes!.map((time) {
        final [hour, minute] = time.split(':').map(int.parse);
        return DateTime(now.year, now.month, now.day, hour, minute);
      }).where((time) => time.isAfter(now)).toList();
      
      if (todayTimes.isNotEmpty) {
        return todayTimes.first;
      } else {
        // Check tomorrow's first time
        final tomorrowTimes = cat.schedule.specificTimes!.map((time) {
          final [hour, minute] = time.split(':').map(int.parse);
          return DateTime(now.year, now.month, now.day + 1, hour, minute);
        }).toList();
        
        if (tomorrowTimes.isNotEmpty) {
          return tomorrowTimes.first;
        }
      }
    }
    
    return null;
  }

  String _formatTimeDifference(DateTime target, DateTime now) {
    final difference = target.difference(now);
    
    if (difference.isNegative) {
      final absDiff = difference.abs();
      if (absDiff.inHours > 0) {
        return 'Atrasado há ${absDiff.inHours}h ${absDiff.inMinutes % 60}m';
      } else {
        return 'Atrasado há ${absDiff.inMinutes}m';
      }
    } else {
      if (difference.inHours > 0) {
        return 'em ${difference.inHours}h ${difference.inMinutes % 60}m';
      } else {
        return 'em ${difference.inMinutes}m';
      }
    }
  }
}

class NextFeeding {
  final Cat cat;
  final DateTime nextTime;
  final String timeText;
  final bool isOverdue;

  NextFeeding({
    required this.cat,
    required this.nextTime,
    required this.timeText,
    required this.isOverdue,
  });
}
