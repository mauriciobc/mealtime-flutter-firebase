import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtime/services/database_service.dart';
import 'package:mealtime/models/cat_model.dart';
import 'package:mealtime/models/feeding_model.dart';
import 'package:mealtime/widgets/feeding_log_tile.dart';

class FeedingHistoryScreen extends StatefulWidget {
  final Cat cat;

  const FeedingHistoryScreen({
    super.key,
    required this.cat,
  });

  @override
  State<FeedingHistoryScreen> createState() => _FeedingHistoryScreenState();
}

class _FeedingHistoryScreenState extends State<FeedingHistoryScreen> {
  List<Feeding> _feedings = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadFeedings();
  }

  Future<void> _loadFeedings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final databaseService = DatabaseService(uid: user.uid);
      final feedings = await databaseService.getFeedingsByCat(widget.cat.id, limit: 100).first;
      
      if(mounted) {
        setState(() {
          _feedings = feedings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico - ${widget.cat.name}'),
        centerTitle: true,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Todos'),
              ),
              const PopupMenuItem(
                value: 'today',
                child: Text('Hoje'),
              ),
              const PopupMenuItem(
                value: 'week',
                child: Text('Esta Semana'),
              ),
              const PopupMenuItem(
                value: 'month',
                child: Text('Este Mês'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _feedings.isEmpty
              ? _buildEmptyState()
              : _buildFeedingsList(),
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
              Icons.restaurant_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withAlpha(77),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma alimentação registrada',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Registre a primeira alimentação do ${widget.cat.name} para começar o acompanhamento',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingsList() {
    final filteredFeedings = _getFilteredFeedings();

    return Column(
      children: [
        // Filter summary
        if (_selectedFilter != 'all')
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              'Mostrando ${filteredFeedings.length} alimentação${filteredFeedings.length != 1 ? 'ões' : ''}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),

        // Feedings list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: filteredFeedings.length,
            itemBuilder: (context, index) {
              final feeding = filteredFeedings[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: FeedingLogTile(
                  feeding: feeding,
                  onTap: () {
                    _showFeedingDetails(feeding);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Feeding> _getFilteredFeedings() {
    final now = DateTime.now();
    
    switch (_selectedFilter) {
      case 'today':
        final today = DateTime(now.year, now.month, now.day);
        return _feedings.where((f) => f.timestamp.isAfter(today)).toList();
      case 'week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return _feedings.where((f) => f.timestamp.isAfter(weekAgo)).toList();
      case 'month':
        final monthAgo = now.subtract(const Duration(days: 30));
        return _feedings.where((f) => f.timestamp.isAfter(monthAgo)).toList();
      default:
        return _feedings;
    }
  }

  void _showFeedingDetails(Feeding feeding) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Alimentação - ${_formatDateTime(feeding.timestamp)}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gato: ${widget.cat.name}'),
            const SizedBox(height: 8),
            if (feeding.portionSize != null)
              Text('Quantidade: ${feeding.portionSize!.toStringAsFixed(1)}g'),
            if (feeding.foodType != null) ...[
              const SizedBox(height: 8),
              Text('Tipo: ${feeding.foodType}'),
            ],
            if (feeding.notes != null) ...[
              const SizedBox(height: 8),
              Text('Observações: ${feeding.notes}'),
            ],
            const SizedBox(height: 8),
            Text('Status: ${feeding.wasEaten ? 'Comido' : 'Recusado'}'),
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
