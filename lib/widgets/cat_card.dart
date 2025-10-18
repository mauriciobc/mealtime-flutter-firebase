import 'package:flutter/material.dart';
import 'package:mealtime/models/cat_model.dart';

class CatCard extends StatelessWidget {
  final Cat cat;
  final VoidCallback? onTap;
  final bool showSchedule;

  const CatCard({
    super.key,
    required this.cat,
    this.onTap,
    this.showSchedule = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cat photo and name
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        child: cat.photoUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  cat.photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildPlaceholder(context);
                                  },
                                ),
                              )
                            : _buildPlaceholder(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Cat info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cat.currentWeight != null) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.monitor_weight,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${cat.currentWeight!.toStringAsFixed(1)} kg',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    
                    if (showSchedule) ...[
                      Row(
                        children: [
                          Icon(
                            cat.schedule.isActive ? Icons.schedule : Icons.schedule_outlined,
                            size: 14,
                            color: cat.schedule.isActive
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _getScheduleText(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cat.schedule.isActive
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (cat.groups != null && cat.groups!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: cat.groups!.take(2).map((group) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              group,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.pets,
        size: 40,
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
      ),
    );
  }

  String _getScheduleText() {
    if (!cat.schedule.isActive) {
      return 'Horário desativado';
    }

    if (cat.schedule.type == ScheduleType.fixedInterval && cat.schedule.intervalHours != null) {
      return 'A cada ${cat.schedule.intervalHours}h';
    } else if (cat.schedule.type == ScheduleType.specificTimes && cat.schedule.specificTimes != null) {
      if (cat.schedule.specificTimes!.length == 1) {
        return '${cat.schedule.specificTimes!.first}';
      } else if (cat.schedule.specificTimes!.length == 2) {
        return '${cat.schedule.specificTimes!.first} e ${cat.schedule.specificTimes!.last}';
      } else {
        return '${cat.schedule.specificTimes!.length} horários';
      }
    }

    return 'Não configurado';
  }
}
