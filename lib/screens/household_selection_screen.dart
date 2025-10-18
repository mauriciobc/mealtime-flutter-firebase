import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mealtime/providers/household_provider.dart';
import 'package:mealtime/models/household_model.dart';
import 'package:mealtime/screens/create_household_screen.dart';
import 'package:mealtime/screens/join_household_screen.dart';
import 'package:mealtime/screens/main_screen.dart';
import 'package:mealtime/widgets/household_card.dart';

class HouseholdSelectionScreen extends StatefulWidget {
  const HouseholdSelectionScreen({super.key});

  @override
  State<HouseholdSelectionScreen> createState() => _HouseholdSelectionScreenState();
}

class _HouseholdSelectionScreenState extends State<HouseholdSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Casa'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<HouseholdProvider>(
        builder: (context, householdProvider, child) {
          return StreamBuilder<List<Household>>(
            stream: householdProvider.userHouseholds.isNotEmpty
                ? Stream.value(householdProvider.userHouseholds)
                : null,
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
                        'Erro ao carregar casas',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Verifique sua conexão e tente novamente',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Retry logic
                        },
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                );
              }

              final households = snapshot.data ?? [];

              if (households.isEmpty) {
                return _buildEmptyState(context);
              }

              if (households.length == 1) {
                // Se há apenas uma casa, selecionar automaticamente
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if(mounted){
                    householdProvider.setCurrentHousehold(households.first);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  }
                });
                return const Center(child: CircularProgressIndicator());
              }

              return _buildHouseholdList(context, households);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_outlined,
            size: 120,
            color: Theme.of(context).colorScheme.primary.withAlpha(77),
          ),
          const SizedBox(height: 32),
          Text(
            'Bem-vindo ao MealTime!',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Para começar, você precisa criar uma casa ou entrar em uma existente.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CreateHouseholdScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_home),
                  label: const Text('Criar Nova Casa'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const JoinHouseholdScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Entrar em Casa Existente'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHouseholdList(BuildContext context, List<Household> households) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Selecione uma casa para continuar',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: households.length,
            itemBuilder: (context, index) {
              final household = households[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: HouseholdCard(
                  household: household,
                  onTap: () {
                    context.read<HouseholdProvider>().setCurrentHousehold(household);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  },
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CreateHouseholdScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Nova Casa'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const JoinHouseholdScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Entrar'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
