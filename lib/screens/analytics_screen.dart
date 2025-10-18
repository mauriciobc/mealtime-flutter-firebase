import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtime/providers/household_provider.dart';
import 'package:mealtime/services/database_service.dart';
import 'package:mealtime/models/cat_model.dart';
import 'package:mealtime/models/feeding_model.dart';
import 'package:mealtime/widgets/feeding_frequency_chart.dart';
import 'package:mealtime/widgets/weight_trend_chart.dart';
import 'package:mealtime/widgets/export_data_button.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = '7d';
  Cat? _selectedCat;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HouseholdProvider>(
      builder: (context, householdProvider, child) {
        final household = householdProvider.currentHousehold;
        if (household == null) {
          return const Scaffold(
            body: Center(child: Text('Nenhuma casa selecionada')),
          );
        }

        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          return const Scaffold(
            body: Center(child: Text('Usuário não autenticado')),
          );
        }

        final databaseService = DatabaseService(uid: currentUser.uid);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Análises'),
            centerTitle: true,
            elevation: 0,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() {
                    _selectedPeriod = value;
                  });
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: '7d',
                    child: Text('Últimos 7 dias'),
                  ),
                  const PopupMenuItem(
                    value: '30d',
                    child: Text('Últimos 30 dias'),
                  ),
                  const PopupMenuItem(
                    value: '90d',
                    child: Text('Últimos 90 dias'),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_getPeriodText()),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  _showExportDialog(context, databaseService, household.id);
                },
                icon: const Icon(Icons.download),
                tooltip: 'Exportar Dados',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Alimentação'),
                Tab(text: 'Peso'),
                Tab(text: 'Resumo'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildFeedingTab(context, databaseService, household.id),
              _buildWeightTab(context, databaseService, household.id),
              _buildSummaryTab(context, databaseService, household.id),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedingTab(BuildContext context, DatabaseService databaseService, String householdId) {
    return StreamBuilder<List<Cat>>(
      stream: databaseService.getCatsByHousehold(householdId),
      builder: (context, catsSnapshot) {
        if (catsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final cats = catsSnapshot.data ?? [];
        if (cats.isEmpty) {
          return _buildEmptyState(context, 'Nenhum gato para análise');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cat selector
              if (cats.length > 1) ...[
                Text(
                  'Selecionar Gato',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Cat>(
                  value: _selectedCat,
                  decoration: const InputDecoration(
                    hintText: 'Todos os gatos',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<Cat>(
                      value: null,
                      child: Text('Todos os gatos'),
                    ),
                    ...cats.map((cat) => DropdownMenuItem<Cat>(
                      value: cat,
                      child: Text(cat.name),
                    )),
                  ],
                  onChanged: (cat) {
                    setState(() {
                      _selectedCat = cat;
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Feeding frequency chart
              Text(
                'Frequência de Alimentação',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              FeedingFrequencyChart(
                householdId: householdId,
                catId: _selectedCat?.id,
                period: _selectedPeriod,
              ),
              const SizedBox(height: 32),

              // Recent feedings
              Text(
                'Alimentações Recentes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildRecentFeedings(context, databaseService, householdId),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeightTab(BuildContext context, DatabaseService databaseService, String householdId) {
    return StreamBuilder<List<Cat>>(
      stream: databaseService.getCatsByHousehold(householdId),
      builder: (context, catsSnapshot) {
        if (catsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final cats = catsSnapshot.data ?? [];
        if (cats.isEmpty) {
          return _buildEmptyState(context, 'Nenhum gato para análise');
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cat selector
              if (cats.length > 1) ...[
                Text(
                  'Selecionar Gato',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Cat>(
                  value: _selectedCat,
                  decoration: const InputDecoration(
                    hintText: 'Todos os gatos',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<Cat>(
                      value: null,
                      child: Text('Todos os gatos'),
                    ),
                    ...cats.map((cat) => DropdownMenuItem<Cat>(
                      value: cat,
                      child: Text(cat.name),
                    )),
                  ],
                  onChanged: (cat) {
                    setState(() {
                      _selectedCat = cat;
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Weight trend chart
              Text(
                'Tendência de Peso',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              WeightTrendChart(
                householdId: householdId,
                catId: _selectedCat?.id,
                period: _selectedPeriod,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryTab(BuildContext context, DatabaseService databaseService, String householdId) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary cards
          Text(
            'Resumo Geral',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildSummaryCards(context, databaseService, householdId),
          const SizedBox(height: 32),

          // Quick stats
          Text(
            'Estatísticas Rápidas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildQuickStats(context, databaseService, householdId),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentFeedings(BuildContext context, DatabaseService databaseService, String householdId) {
    return StreamBuilder<List<Feeding>>(
      stream: databaseService.getFeedingsByHousehold(householdId, limit: 10),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final feedings = snapshot.data ?? [];
        if (feedings.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Nenhuma alimentação registrada'),
            ),
          );
        }

        return Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: feedings.length,
            itemBuilder: (context, index) {
              final feeding = feedings[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.restaurant),
                ),
                title: Text('Gato ID: ${feeding.catId}'),
                subtitle: Text(_formatDateTime(feeding.timestamp)),
                trailing: feeding.portionSize != null
                    ? Text('${feeding.portionSize!.toStringAsFixed(1)}g')
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(BuildContext context, DatabaseService databaseService, String householdId) {
    return StreamBuilder<List<Cat>>(
      stream: databaseService.getCatsByHousehold(householdId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final cats = snapshot.data ?? [];
        
        return Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.pets,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${cats.length}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'Gato${cats.length != 1 ? 's' : ''}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 32,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '0', // TODO: Calculate from feedings
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'Alimentações hoje',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStats(BuildContext context, DatabaseService databaseService, String householdId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatRow(context, 'Gatos ativos', '0'),
            const Divider(),
            _buildStatRow(context, 'Alimentações hoje', '0'),
            const Divider(),
            _buildStatRow(context, 'Peso médio', '0 kg'),
            const Divider(),
            _buildStatRow(context, 'Última alimentação', 'Nunca'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodText() {
    switch (_selectedPeriod) {
      case '7d':
        return '7 dias';
      case '30d':
        return '30 dias';
      case '90d':
        return '90 dias';
      default:
        return '7 dias';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays != 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours != 1 ? 's' : ''} atrás';
    } else {
      return '${difference.inMinutes} minuto${difference.inMinutes != 1 ? 's' : ''} atrás';
    }
  }

  void _showExportDialog(BuildContext context, DatabaseService databaseService, String householdId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Dados'),
        content: const Text('Escolha o formato para exportar os dados:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement CSV export
            },
            child: const Text('CSV'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement PDF export
            },
            child: const Text('PDF'),
          ),
        ],
      ),
    );
  }
}
