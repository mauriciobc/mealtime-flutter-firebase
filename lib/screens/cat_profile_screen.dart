import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtime/services/database_service.dart';
import 'package:mealtime/models/cat_model.dart';
import 'package:mealtime/screens/weight_log_screen.dart';
import 'package:mealtime/screens/weight_history_screen.dart';
import 'package:mealtime/screens/feeding_history_screen.dart';

class CatProfileScreen extends StatefulWidget {
  final Cat cat;

  const CatProfileScreen({
    super.key,
    required this.cat,
  });

  @override
  State<CatProfileScreen> createState() => _CatProfileScreenState();
}

class _CatProfileScreenState extends State<CatProfileScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  Cat? _updatedCat;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updatedCat = widget.cat;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = _updatedCat ?? widget.cat;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(cat.name),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showEditDialog(context),
            icon: const Icon(Icons.edit),
            tooltip: 'Editar Gato',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditDialog(context);
                  break;
                case 'delete':
                  _showDeleteDialog(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Editar'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text('Excluir', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Perfil'),
            Tab(text: 'Peso'),
            Tab(text: 'Alimentação'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(cat),
          _buildWeightTab(cat),
          _buildFeedingTab(cat),
        ],
      ),
    );
  }

  Widget _buildProfileTab(Cat cat) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cat photo and basic info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Photo
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: cat.photoUrl != null
                        ? NetworkImage(cat.photoUrl!)
                        : null,
                    child: cat.photoUrl == null
                        ? const Icon(Icons.pets, size: 60)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Name and basic info
                  Text(
                    cat.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  
                  if (cat.birthdate != null) ...[
                    Text(
                      'Idade: ${_calculateAge(cat.birthdate!)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                  ],
                  
                  if (cat.currentWeight != null) ...[
                    Text(
                      'Peso atual: ${cat.currentWeight!.toStringAsFixed(1)} kg',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Health information
          if (cat.dietaryRestrictions != null || cat.medicalNotes != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informações de Saúde',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    if (cat.dietaryRestrictions != null) ...[
                      _buildInfoRow(
                        context,
                        Icons.restaurant_menu,
                        'Restrições Alimentares',
                        cat.dietaryRestrictions!,
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    if (cat.medicalNotes != null) ...[
                      _buildInfoRow(
                        context,
                        Icons.medical_services,
                        'Notas Médicas',
                        cat.medicalNotes!,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Groups
          if (cat.groups != null && cat.groups!.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grupos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cat.groups!.map((group) {
                        return Chip(
                          label: Text(group),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Feeding schedule
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Horário de Alimentação',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cat.schedule.isActive
                              ? Colors.green
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          cat.schedule.isActive ? 'Ativo' : 'Inativo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (cat.schedule.isActive) ...[
                    if (cat.schedule.type == ScheduleType.fixedInterval) ...[
                      _buildInfoRow(
                        context,
                        Icons.schedule,
                        'Intervalo',
                        'A cada ${cat.schedule.intervalHours} horas',
                      ),
                    ] else if (cat.schedule.type == ScheduleType.specificTimes) ...[
                      _buildInfoRow(
                        context,
                        Icons.schedule,
                        'Horários',
                        cat.schedule.specificTimes?.map((t) => t.format(context)).join(', ') ?? 'Não configurado',
                      ),
                    ],
                    
                    if (cat.schedule.lastFed != null) ...[
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        Icons.restaurant,
                        'Última Alimentação',
                        _formatDateTime(cat.schedule.lastFed!),
                      ),
                    ],
                  ] else ...[
                    Text(
                      'Horário de alimentação desativado',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightTab(Cat cat) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick actions
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WeightLogScreen(cat: cat),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar Peso'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WeightHistoryScreen(cat: cat),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Histórico'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current weight card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.monitor_weight,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    cat.currentWeight != null
                        ? '${cat.currentWeight!.toStringAsFixed(1)} kg'
                        : 'Peso não registrado',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Peso Atual',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Weight goal (if set)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meta de Peso',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhuma meta definida',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      // TODO: Navigate to weight goal screen
                    },
                    icon: const Icon(Icons.flag),
                    label: const Text('Definir Meta'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingTab(Cat cat) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick actions
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    // TODO: Quick feed action
                  },
                  icon: const Icon(Icons.restaurant),
                  label: const Text('Alimentar Agora'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => FeedingHistoryScreen(cat: cat),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Histórico'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Next feeding info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Próxima Alimentação',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  if (cat.schedule.isActive) ...[
                    if (cat.schedule.lastFed != null) ...[
                      Text(
                        _getNextFeedingTime(cat),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ] else ...[
                      Text(
                        'Nunca alimentado',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ] else ...[
                    Text(
                      'Horário desativado',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _calculateAge(DateTime birthdate) {
    final now = DateTime.now();
    final age = now.difference(birthdate);
    final years = age.inDays ~/ 365;
    final months = (age.inDays % 365) ~/ 30;
    
    if (years > 0) {
      return months > 0 ? '$years anos e $months meses' : '$years anos';
    } else {
      return months > 0 ? '$months meses' : 'Recém-nascido';
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

  String _getNextFeedingTime(Cat cat) {
    if (!cat.schedule.isActive) return 'Horário desativado';
    
    final now = DateTime.now();
    final lastFed = cat.schedule.lastFed;
    
    if (cat.schedule.type == ScheduleType.fixedInterval && cat.schedule.intervalHours != null) {
      if (lastFed != null) {
        final nextFeeding = lastFed.add(Duration(hours: cat.schedule.intervalHours!));
        if (nextFeeding.isAfter(now)) {
          final diff = nextFeeding.difference(now);
          if (diff.inHours > 0) {
            return 'em ${diff.inHours}h ${diff.inMinutes % 60}m';
          } else {
            return 'em ${diff.inMinutes}m';
          }
        } else {
          return 'Atrasado!';
        }
      } else {
        return 'Nunca alimentado';
      }
    } else if (cat.schedule.type == ScheduleType.specificTimes && cat.schedule.specificTimes != null) {
      // Find next specific time
      final todayTimes = cat.schedule.specificTimes!.map((time) {
        return DateTime(now.year, now.month, now.day, time.hour, time.minute);
      }).where((time) => time.isAfter(now)).toList();
      
      if (todayTimes.isNotEmpty) {
        final nextTime = todayTimes.first;
        final diff = nextTime.difference(now);
        if (diff.inHours > 0) {
          return 'em ${diff.inHours}h ${diff.inMinutes % 60}m';
        } else {
          return 'em ${diff.inMinutes}m';
        }
      } else {
        return 'Amanhã';
      }
    }
    
    return 'Não configurado';
  }

  void _showEditDialog(BuildContext context) {
    // TODO: Implement edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edição em desenvolvimento')),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Gato'),
        content: Text('Tem certeza que deseja excluir ${widget.cat.name}? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteCat();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCat() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final databaseService = DatabaseService(uid: user.uid);
      await databaseService.deleteCat(widget.cat.id);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.cat.name} foi excluído com sucesso'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir gato: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
