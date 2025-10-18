import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtime/providers/household_provider.dart';
import 'package:mealtime/services/database_service.dart';
import 'package:mealtime/models/cat_model.dart';
import 'package:mealtime/screens/add_cat_screen.dart';
import 'package:mealtime/screens/cat_profile_screen.dart';
import 'package:mealtime/widgets/cat_card.dart';

class CatsListScreen extends StatelessWidget {
  const CatsListScreen({super.key});

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
            title: Text('Gatos - ${household.name}'),
            centerTitle: true,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddCatScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                tooltip: 'Adicionar Gato',
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
                      const SizedBox(height: 8),
                      Text(
                        'Verifique sua conexão e tente novamente',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final cats = snapshot.data ?? [];

              if (cats.isEmpty) {
                return _buildEmptyState(context);
              }

              return _buildCatsGrid(context, cats);
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddCatScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Gato'),
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
            Icons.pets_outlined,
            size: 120,
            color: Theme.of(context).colorScheme.primary.withAlpha(77),
          ),
          const SizedBox(height: 32),
          Text(
            'Nenhum gato cadastrado',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Adicione o primeiro gato para começar a gerenciar a alimentação',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddCatScreen()),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Primeiro Gato'),
          ),
        ],
      ),
    );
  }

  Widget _buildCatsGrid(BuildContext context, List<Cat> cats) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          final cat = cats[index];
          return CatCard(
            cat: cat,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => CatProfileScreen(cat: cat),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
