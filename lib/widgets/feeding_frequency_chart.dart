import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mealtime/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtime/models/feeding_model.dart';

class FeedingFrequencyChart extends StatefulWidget {
  final String householdId;
  final String? catId;
  final String period;

  const FeedingFrequencyChart({
    super.key,
    required this.householdId,
    this.catId,
    this.period = '7d',
  });

  @override
  State<FeedingFrequencyChart> createState() => _FeedingFrequencyChartState();
}

class _FeedingFrequencyChartState extends State<FeedingFrequencyChart> {
  List<Feeding> _feedings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedings();
  }

  @override
  void didUpdateWidget(FeedingFrequencyChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.householdId != widget.householdId ||
        oldWidget.catId != widget.catId ||
        oldWidget.period != widget.period) {
      _loadFeedings();
    }
  }

  Future<void> _loadFeedings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final databaseService = DatabaseService(uid: user.uid);
      final endDate = DateTime.now();
      final startDate = _getStartDate(endDate);

      final feedings = await databaseService
          .getFeedingsByHousehold(
            widget.householdId,
            startDate: startDate,
            endDate: endDate,
            limit: 1000,
          )
          .first;

      setState(() {
        _feedings = widget.catId != null
            ? feedings.where((f) => f.catId == widget.catId).toList()
            : feedings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  DateTime _getStartDate(DateTime endDate) {
    switch (widget.period) {
      case '7d':
        return endDate.subtract(const Duration(days: 7));
      case '30d':
        return endDate.subtract(const Duration(days: 30));
      case '90d':
        return endDate.subtract(const Duration(days: 90));
      default:
        return endDate.subtract(const Duration(days: 7));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_feedings.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.bar_chart_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma alimentação registrada',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final chartData = _prepareChartData();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alimentações por Dia',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY:
                      chartData.values
                          .fold(0, (a, b) => a > b ? a : b)
                          .toDouble() +
                      1,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < chartData.keys.length) {
                            return Text(
                              chartData.keys.elementAt(index),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: chartData.entries.map((entry) {
                    final index = chartData.keys.toList().indexOf(entry.key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Theme.of(context).colorScheme.primary,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildStats(context, chartData),
          ],
        ),
      ),
    );
  }

  Map<String, int> _prepareChartData() {
    final Map<String, int> dailyCount = {};

    for (final feeding in _feedings) {
      final date = DateTime(
        feeding.timestamp.year,
        feeding.timestamp.month,
        feeding.timestamp.day,
      );
      final dateKey = _formatDate(date);
      dailyCount[dateKey] = (dailyCount[dateKey] ?? 0) + 1;
    }

    final startDate = _getStartDate(DateTime.now());
    final endDate = DateTime.now();

    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      final date = startDate.add(Duration(days: i));
      final dateKey = _formatDate(date);
      if (!dailyCount.containsKey(dateKey)) {
        dailyCount[dateKey] = 0;
      }
    }

    final sortedEntries = dailyCount.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Map.fromEntries(sortedEntries);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Hoje';
    } else if (date == yesterday) {
      return 'Ontem';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  Widget _buildStats(BuildContext context, Map<String, int> chartData) {
    final totalFeedings = chartData.values.fold(0, (a, b) => a + b);
    final averagePerDay = totalFeedings / chartData.length;
    final maxDay = chartData.entries.fold(
      chartData.entries.first,
      (a, b) => a.value > b.value ? a : b,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            'Total',
            totalFeedings.toString(),
            Icons.restaurant,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            'Média/dia',
            averagePerDay.toStringAsFixed(1),
            Icons.trending_up,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            'Pico',
            '${maxDay.value} (${maxDay.key})',
            Icons.analytics,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
