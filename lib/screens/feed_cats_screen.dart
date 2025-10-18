import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtime/providers/household_provider.dart';
import 'package:mealtime/services/database_service.dart';
import 'package:mealtime/models/cat_model.dart';
import 'package:mealtime/widgets/feed_button.dart';
import 'package:mealtime/widgets/next_feeding_countdown.dart';

class FeedCatsScreen extends StatefulWidget {
  const FeedCatsScreen({super.key});

  @override
  State<FeedCatsScreen> createState() => _FeedCatsScreenState();
}

class _FeedCatsScreenState extends State<FeedCatsScreen> {
  final Set<String> _selectedCats = {};
  bool _isFeeding = false;

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
            title: const Text('Alimentar Gatos'),
            centerTitle: true,
            elevation: 0,
            actions: [
              if (_selectedCats.isNotEmpty)
                TextButton(
                  onPressed: _isFeeding ? null : () => _feedSelectedCats(databaseService, household.id),
                  child: _isFeeding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('Alimentar (${_selectedCats.length})'),
                ),
            ],
          ),
          body: StreamBuilder<List<Cat>>(
            stream: databaseService.getCatsByHousehold(household.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar gatos',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                );
              }

              final cats = snapshot.data ?? [];

              if (cats.isEmpty) {
                return _buildEmptyState(context);
              }

              return _buildCatsList(context, cats, databaseService, household.id);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 120,
            color: Theme.of(context).colorScheme.primary.withAlpha(77),
          ),
          const SizedBox(height: 32),
          Text(
            'Nenhum gato para alimentar',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Adicione gatos primeiro para poder alimentá-los',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCatsList(BuildContext context, List<Cat> cats, DatabaseService databaseService, String householdId) {
    return Column(
      children: [
        // Next feeding countdown
        if (cats.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: NextFeedingCountdown(cats: cats),
          ),

        // Cats list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: cats.length,
            itemBuilder: (context, index) {
              final cat = cats[index];
              final isSelected = _selectedCats.contains(cat.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: cat.photoUrl != null
                          ? NetworkImage(cat.photoUrl!)
                          : null,
                      child: cat.photoUrl == null
                          ? const Icon(Icons.pets)
                          : null,
                    ),
                    title: Text(cat.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (cat.schedule.isActive) ...[
                          Text(
                            'Próxima alimentação: ${_getNextFeedingTime(cat)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ] else ...[
                          Text(
                            'Horário desativado',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        else
                          Icon(
                            Icons.radio_button_unchecked,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        const SizedBox(width: 8),
                        FeedButton(
                          cat: cat,
                          onFed: () {
                            _feedSingleCat(cat, databaseService, householdId);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedCats.remove(cat.id);
                        } else {
                          _selectedCats.add(cat.id);
                        }
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _getNextFeedingTime(Cat cat) {
    if (!cat.schedule.isActive) return 'Desativado';
    
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

  Future<void> _feedSingleCat(Cat cat, DatabaseService databaseService, String householdId) async {
    setState(() {
      _isFeeding = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await databaseService.logFeeding(
        householdId,
        cat.id,
        notes: 'Alimentado via app',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${cat.name} foi alimentado!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alimentar ${cat.name}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFeeding = false;
        });
      }
    }
  }

  Future<void> _feedSelectedCats(DatabaseService databaseService, String householdId) async {
    if (_selectedCats.isEmpty) return;

    setState(() {
      _isFeeding = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      int successCount = 0;
      for (final catId in _selectedCats) {
        try {
          await databaseService.logFeeding(
            householdId,
            catId,
            notes: 'Alimentado via app (múltiplos)',
          );
          successCount++;
        } catch (e) {
          // Continue with other cats even if one fails
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$successCount gato(s) alimentado(s) com sucesso!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        
        setState(() {
          _selectedCats.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao alimentar gatos: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFeeding = false;
        });
      }
    }
  }
}
