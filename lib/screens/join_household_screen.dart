import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtime/providers/household_provider.dart';
import 'package:mealtime/services/database_service.dart';
import 'package:mealtime/screens/main_screen.dart';

class JoinHouseholdScreen extends StatefulWidget {
  const JoinHouseholdScreen({super.key});

  @override
  State<JoinHouseholdScreen> createState() => _JoinHouseholdScreenState();
}

class _JoinHouseholdScreenState extends State<JoinHouseholdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinHousehold() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final databaseService = DatabaseService(uid: user.uid);
      final success = await databaseService.joinHouseholdByCode(
        _codeController.text.trim().toUpperCase(),
      );

      if (success) {
        // Recarregar households do usuário
        final households = await databaseService.getUserHouseholds().first;
        if (mounted) {
          context.read<HouseholdProvider>().setUserHouseholds(households);

          if (households.isNotEmpty) {
            context.read<HouseholdProvider>().setCurrentHousehold(
              households.last,
            );
          }

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Código de convite inválido ou expirado'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao entrar na casa: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
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
        title: const Text('Entrar em Casa'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Icon(
                Icons.login_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Entrar em Casa Existente',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Digite o código de convite que você recebeu',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Code input
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Código de Convite',
                  hintText: 'Ex: ABC123',
                  prefixIcon: Icon(Icons.vpn_key),
                  helperText: 'Digite o código de 6 caracteres',
                ),
                textInputAction: TextInputAction.done,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                ],
                onFieldSubmitted: (_) => _joinHousehold(),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Código de convite é obrigatório';
                  }
                  if (value.trim().length != 6) {
                    return 'Código deve ter exatamente 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Join button
              FilledButton(
                onPressed: _isLoading ? null : _joinHousehold,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Entrar na Casa'),
              ),
              const SizedBox(height: 16),

              // Info card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Como obter o código?',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Peça para um membro da casa compartilhar o código\n'
                        '• O código é gerado automaticamente quando a casa é criada\n'
                        '• Você pode encontrá-lo nas configurações da casa',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Alternative action
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.add_home),
                label: const Text('Criar Nova Casa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
