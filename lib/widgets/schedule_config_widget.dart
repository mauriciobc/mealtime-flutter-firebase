import 'package:flutter/material.dart';
import 'package:mealtime/models/cat_model.dart';

class ScheduleConfigWidget extends StatefulWidget {
  final FeedingSchedule schedule;
  final Function(FeedingSchedule) onScheduleChanged;

  const ScheduleConfigWidget({
    super.key,
    required this.schedule,
    required this.onScheduleChanged,
  });

  @override
  State<ScheduleConfigWidget> createState() => _ScheduleConfigWidgetState();
}

class _ScheduleConfigWidgetState extends State<ScheduleConfigWidget> {
  late ScheduleType _selectedType;
  late int? _intervalHours;
  late List<TimeOfDay> _specificTimes;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.schedule.type;
    _intervalHours = widget.schedule.intervalHours;
    _specificTimes = List.from(widget.schedule.specificTimes ?? []);
    _isActive = widget.schedule.isActive;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active toggle
        SwitchListTile(
          title: const Text('Horário Ativo'),
          subtitle: const Text('Ativar lembretes de alimentação'),
          value: _isActive,
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
            _updateSchedule();
          },
        ),

        if (_isActive) ...[
          const Divider(),
          const SizedBox(height: 16),

          // Schedule type selection
          Text(
            'Tipo de Horário',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<ScheduleType>(
                  title: const Text('Intervalo'),
                  subtitle: const Text('A cada X horas'),
                  value: ScheduleType.fixedInterval,
                  groupValue: _selectedType,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                    _updateSchedule();
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<ScheduleType>(
                  title: const Text('Horários'),
                  subtitle: const Text('Horários específicos'),
                  value: ScheduleType.specificTimes,
                  groupValue: _selectedType,
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                    _updateSchedule();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Configuration based on type
          if (_selectedType == ScheduleType.fixedInterval)
            _buildIntervalConfig()
          else
            _buildSpecificTimesConfig(),
        ],
      ],
    );
  }

  Widget _buildIntervalConfig() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Intervalo de Alimentação',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('A cada '),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: _intervalHours?.toString() ?? '8',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      _intervalHours = int.tryParse(value);
                      _updateSchedule();
                    },
                  ),
                ),
                const Text(' horas'),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Exemplo: Se configurado para 8 horas, o gato será alimentado às 8h, 16h e meia-noite.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificTimesConfig() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Horários Específicos',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: _addSpecificTime,
                  icon: const Icon(Icons.add),
                  tooltip: 'Adicionar horário',
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_specificTimes.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Nenhum horário configurado. Toque no + para adicionar.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ..._specificTimes.asMap().entries.map((entry) {
                final index = entry.key;
                final time = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue:
                              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                          decoration: const InputDecoration(
                            labelText: 'Horário',
                            hintText: 'HH:MM',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.schedule),
                          ),
                          onTap: () async {
                            final newTime = await showTimePicker(
                              context: context,
                              initialTime: time,
                            );
                            if (newTime != null) {
                              setState(() {
                                _specificTimes[index] = newTime;
                              });
                              _updateSchedule();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _removeSpecificTime(index),
                        icon: const Icon(Icons.remove_circle),
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 8),
            Text(
              'Formato: HH:MM (ex: 08:00, 18:30)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addSpecificTime() {
    setState(() {
      _specificTimes.add(const TimeOfDay(hour: 8, minute: 0));
    });
    _updateSchedule();
  }

  void _removeSpecificTime(int index) {
    setState(() {
      _specificTimes.removeAt(index);
    });
    _updateSchedule();
  }

  void _updateSchedule() {
    final newSchedule = FeedingSchedule(
      type: _selectedType,
      intervalHours: _selectedType == ScheduleType.fixedInterval
          ? _intervalHours
          : null,
      specificTimes:
          _selectedType == ScheduleType.specificTimes &&
              _specificTimes.isNotEmpty
          ? _specificTimes
          : null,
      isActive: _isActive,
      lastFed: widget.schedule.lastFed,
      notes: widget.schedule.notes,
    );

    widget.onScheduleChanged(newSchedule);
  }
}
