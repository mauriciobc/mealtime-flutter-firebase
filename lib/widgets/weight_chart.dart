import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mealtime/models/weight_entry_model.dart';

class WeightChart extends StatelessWidget {
  final List<WeightEntry> weightEntries;

  const WeightChart({
    super.key,
    required this.weightEntries,
  });

  @override
  Widget build(BuildContext context) {
    if (weightEntries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text('Nenhum dado de peso disponível'),
          ),
        ),
      );
    }

    final sortedEntries = List<WeightEntry>.from(weightEntries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolução do Peso',
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
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
                          if (index >= 0 && index < sortedEntries.length) {
                            final entry = sortedEntries[index];
                            return Text(
                              _formatDate(entry.timestamp),
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
                      spots: sortedEntries.asMap().entries.map((entry) {
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
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildTrendInfo(context, sortedEntries),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendInfo(BuildContext context, List<WeightEntry> sortedEntries) {
    if (sortedEntries.length < 2) {
      return const SizedBox.shrink();
    }

    final firstWeight = sortedEntries.first.weight;
    final lastWeight = sortedEntries.last.weight;
    final weightChange = lastWeight - firstWeight;
    final daysBetween = sortedEntries.last.timestamp.difference(sortedEntries.first.timestamp).inDays;

    return Row(
      children: [
        Expanded(
          child: _buildTrendItem(
            context,
            'Variação Total',
            '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)}kg',
            weightChange >= 0 ? Icons.trending_up : Icons.trending_down,
            weightChange >= 0 ? Colors.green : Colors.red,
          ),
        ),
        Expanded(
          child: _buildTrendItem(
            context,
            'Período',
            '$daysBetween dias',
            Icons.calendar_today,
            Theme.of(context).colorScheme.primary,
          ),
        ),
        Expanded(
          child: _buildTrendItem(
            context,
            'Registros',
            '${sortedEntries.length}',
            Icons.analytics,
            Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
