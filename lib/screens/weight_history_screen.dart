import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtime/services/database_service.dart';
import 'package:mealtime/models/cat_model.dart' hide WeightEntry;
import 'package:mealtime/models/weight_entry_model.dart';
import 'package:mealtime/screens/weight_log_screen.dart';
import 'package:mealtime/widgets/weight_chart.dart';
import 'package:mealtime/widgets/weight_entry_tile.dart';

class WeightHistoryScreen extends StatefulWidget {
  final Cat cat;

  const WeightHistoryScreen({super.key, required this.cat});

  @override
  State<WeightHistoryScreen> createState() => _WeightHistoryScreenState();
}

class _WeightHistoryScreenState extends State<WeightHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<WeightEntry> _weightEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadWeightHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWeightHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final databaseService = DatabaseService(uid: user.uid);
      final entries = await databaseService
          .getWeightHistory(widget.cat.id, limit: 100)
          .first;

      if (mounted) {
        setState(() {
          _weightEntries = entries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading weight history: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de Peso - ${widget.cat.name}'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => WeightLogScreen(cat: widget.cat),
                ),
              );
              _loadWeightHistory();
            },
            icon: const Icon(Icons.add),
            tooltip: 'Registrar Peso',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Gráfico'),
            Tab(text: 'Lista'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildChartTab(), _buildListTab()],
      ),
    );
  }

  Widget _buildChartTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_weightEntries.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          WeightChart(weightEntries: _weightEntries),
          const SizedBox(height: 24),
          _buildQuickStats(),
        ],
      ),
    );
  }

  Widget _buildListTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_weightEntries.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _weightEntries.length,
      itemBuilder: (context, index) {
        final entry = _weightEntries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: WeightEntryTile(
            entry: entry,
            onTap: () {
              _showEntryDetails(entry);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withAlpha(77),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum registro de peso',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Registre o primeiro peso do ${widget.cat.name} para começar o acompanhamento',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WeightLogScreen(cat: widget.cat),
                  ),
                );
                _loadWeightHistory();
              },
              icon: const Icon(Icons.add),
              label: const Text('Registrar Primeiro Peso'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    if (_weightEntries.length < 2) {
      return const SizedBox.shrink();
    }

    final weights = _weightEntries.map((e) => e.weight).toList();
    final currentWeight = weights.first;
    final previousWeight = weights[1];
    final weightChange = currentWeight - previousWeight;
    final averageWeight = weights.fold(0.0, (a, b) => a + b) / weights.length;
    final minWeight = weights.fold(weights.first, (a, b) => a < b ? a : b);
    final maxWeight = weights.fold(weights.first, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Atual',
                    '${currentWeight.toStringAsFixed(1)}kg',
                    Icons.monitor_weight,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Variação',
                    '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)}kg',
                    weightChange >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: weightChange >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Média',
                    '${averageWeight.toStringAsFixed(1)}kg',
                    Icons.analytics,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Faixa',
                    '${minWeight.toStringAsFixed(1)}-${maxWeight.toStringAsFixed(1)}kg',
                    Icons.height,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Icon(icon, size: 24, color: effectiveColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: effectiveColor,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  void _showEntryDetails(WeightEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Peso: ${entry.weight.toStringAsFixed(1)}kg'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Data: ${_formatDateTime(entry.timestamp)}'),
            if (entry.notes != null) ...[
              const SizedBox(height: 8),
              Text('Observações: ${entry.notes}'),
            ],
            const SizedBox(height: 8),
            Text('Tipo: ${entry.measurementType ?? 'Manual'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} às '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
