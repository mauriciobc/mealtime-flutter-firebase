import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mealtime/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtime/models/weight_entry_model.dart';

class WeightTrendChart extends StatefulWidget {
  final String householdId;
  final String? catId;
  final String period;

  const WeightTrendChart({
    super.key,
    required this.householdId,
    this.catId,
    this.period = '7d',
  });

  @override
  State<WeightTrendChart> createState() => _WeightTrendChartState();
}

class _WeightTrendChartState extends State<WeightTrendChart> {
  List<WeightEntry> _weightEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeightEntries();
  }

  @override
  void didUpdateWidget(WeightTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.householdId != widget.householdId ||
        oldWidget.catId != widget.catId ||
        oldWidget.period != widget.period) {
      _loadWeightEntries();
    }
  }

  Future<void> _loadWeightEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final databaseService = DatabaseService(uid: user.uid);

      if (widget.catId != null) {
        final entries = await databaseService
            .getWeightHistory(widget.catId!, limit: 100)
            .first;
        if (mounted) {
          setState(() {
            _weightEntries = entries;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _weightEntries = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

    if (_weightEntries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.monitor_weight_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  'Nenhum registro de peso',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Adicione registros de peso para ver o gráfico',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
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
              'Tendência de Peso',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 0.1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withAlpha(51),
                        strokeWidth: 1,
                      );
                    },
                  ),
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
                          if (index >= 0 && index < chartData.length) {
                            return Text(
                              _formatDate(chartData[index].timestamp),
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
                            '${value.toStringAsFixed(1)}kg',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value.weight);
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Theme.of(context).colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: Theme.of(context).colorScheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withAlpha(26),
                      ),
                    ),
                  ],
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

  List<WeightEntry> _prepareChartData() {
    final sortedEntries = List<WeightEntry>.from(_weightEntries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final endDate = DateTime.now();
    final startDate = _getStartDate(endDate);

    return sortedEntries
        .where((entry) => entry.timestamp.isAfter(startDate))
        .toList();
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

  Widget _buildStats(BuildContext context, List<WeightEntry> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final weights = entries.map((e) => e.weight).toList();
    final currentWeight = weights.last;
    final previousWeight = weights.length > 1
        ? weights[weights.length - 2]
        : currentWeight;
    final weightChange = currentWeight - previousWeight;
    final averageWeight = weights.fold(0.0, (a, b) => a + b) / weights.length;
    final minWeight = weights.fold(weights.first, (a, b) => a < b ? a : b);
    final maxWeight = weights.fold(weights.first, (a, b) => a > b ? a : b);

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            'Atual',
            '${currentWeight.toStringAsFixed(1)}kg',
            Icons.monitor_weight,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            'Variação',
            '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)}kg',
            weightChange >= 0 ? Icons.trending_up : Icons.trending_down,
            color: weightChange >= 0 ? Colors.green : Colors.red,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            'Média',
            '${averageWeight.toStringAsFixed(1)}kg',
            Icons.analytics,
          ),
        ),
        Expanded(
          child: _buildStatItem(
            context,
            'Faixa',
            '${minWeight.toStringAsFixed(1)}-${maxWeight.toStringAsFixed(1)}kg',
            Icons.height,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Icon(icon, size: 20, color: effectiveColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: effectiveColor,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
