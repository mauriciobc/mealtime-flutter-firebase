import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtime/providers/household_provider.dart';
import 'package:mealtime/services/database_service.dart';
import 'package:mealtime/screens/household_selection_screen.dart';
import 'package:mealtime/widgets/member_list_tile.dart';

class HouseholdSettingsScreen extends StatefulWidget {
  const HouseholdSettingsScreen({super.key});

  @override
  State<HouseholdSettingsScreen> createState() =>
      _HouseholdSettingsScreenState();
}

class _HouseholdSettingsScreenState extends State<HouseholdSettingsScreen> {
  bool _isLoading = false;

  Future<void> _leaveHousehold() async {
    // Show confirmation dialog before proceeding
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final household =
            Provider.of<HouseholdProvider>(context, listen: false)
                .currentHousehold;
        return AlertDialog(
          title: const Text('Sair da Casa'),
          content: Text(
            'Tem certeza que deseja sair da casa "${household?.name}"? '
            'Você perderá acesso a todos os dados dos gatos e alimentações.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Set loading state
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // Access context-dependent objects before async gap
    final householdProvider =
        Provider.of<HouseholdProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final household = householdProvider.currentHousehold;

    if (household == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final databaseService = DatabaseService(uid: user.uid);
      await databaseService.leaveHousehold(household.id);

      householdProvider.removeHousehold(household.id);

      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HouseholdSelectionScreen(),
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao sair da casa: $e'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteHousehold() async {
    // Show confirmation dialog before proceeding
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final household =
            Provider.of<HouseholdProvider>(context, listen: false)
                .currentHousehold;
        return AlertDialog(
          title: const Text('Excluir Casa'),
          content: Text(
            'Tem certeza que deseja excluir permanentemente a casa "${household?.name}"? '
            'Esta ação não pode ser desfeita e todos os dados serão perdidos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    // Set loading state
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    // Access context-dependent objects before async gap
    final householdProvider =
        Provider.of<HouseholdProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final household = householdProvider.currentHousehold;

    if (household == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final databaseService = DatabaseService(uid: user.uid);
      await databaseService.deleteHousehold(household.id);

      householdProvider.removeHousehold(household.id);

      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => const HouseholdSelectionScreen(),
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir casa: $e'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _copyInviteCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado para a área de transferência'),
        duration: Duration(seconds: 2),
      ),
    );
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
        final isAdmin = household.isAdmin(currentUser?.uid ?? '');

        return Scaffold(
          appBar: AppBar(
            title: const Text('Configurações da Casa'),
            centerTitle: true,
            elevation: 0,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.home,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    household.name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                ],
                              ),
                              if (household.description != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  household.description!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${household.members.length} membro${household.members.length != 1 ? 's' : ''}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Código de Convite',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Compartilhe este código para convidar outros membros:',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      household.inviteCode ?? 'N/A',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontFamily: 'monospace',
                                            letterSpacing: 2,
                                          ),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () => _copyInviteCode(
                                        household.inviteCode ?? '',
                                      ),
                                      icon: const Icon(Icons.copy),
                                      tooltip: 'Copiar código',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Membros',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Column(
                          children: household.members.map((member) {
                            return MemberListTile(
                              member: member,
                              isCurrentUser: member.userId == currentUser?.uid,
                              canChangeRole:
                                  isAdmin && member.userId != currentUser?.uid,
                              onRoleChanged: (newRole) async {
                                if (!mounted) return;
                                final householdProvider =
                                    context.read<HouseholdProvider>();
                                final scaffoldMessenger =
                                    ScaffoldMessenger.of(context);
                                final theme = Theme.of(context);
                                try {
                                  final databaseService = DatabaseService(
                                    uid: currentUser!.uid,
                                  );
                                  await databaseService.updateMemberRole(
                                    household.id,
                                    member.userId,
                                    newRole,
                                  );

                                  final updatedHousehold = await databaseService
                                      .getHousehold(household.id);

                                  if (updatedHousehold != null) {
                                    householdProvider
                                        .setCurrentHousehold(updatedHousehold);
                                  }
                                } catch (e) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Erro ao alterar role: $e'),
                                      backgroundColor:
                                          theme.colorScheme.error,
                                    ),
                                  );
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Zona de Perigo',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  Icons.exit_to_app,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                title: const Text('Sair da Casa'),
                                subtitle: const Text(
                                  'Você perderá acesso aos dados',
                                ),
                                onTap: _leaveHousehold,
                              ),
                              if (isAdmin) ...[
                                const Divider(),
                                ListTile(
                                  leading: Icon(
                                    Icons.delete_forever,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  title: const Text('Excluir Casa'),
                                  subtitle: const Text(
                                    'Esta ação não pode ser desfeita',
                                  ),
                                  onTap: _deleteHousehold,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
