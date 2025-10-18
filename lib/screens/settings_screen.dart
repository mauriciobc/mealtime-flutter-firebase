import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtime/providers/theme_provider.dart';
import 'package:mealtime/providers/language_provider.dart';
import 'package:mealtime/providers/household_provider.dart';
import 'package:mealtime/screens/household_settings_screen.dart';
import 'package:mealtime/screens/household_selection_screen.dart';
import 'package:mealtime/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildUserSection(context),
          _buildHouseholdSection(context),
          _buildPreferencesSection(context),
          _buildNotificationsSection(context),
          _buildAboutSection(context),
          _buildDangerZone(context),
        ],
      ),
    );
  }

  Widget _buildUserSection(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Perfil', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null ? const Icon(Icons.person) : null,
              ),
              title: Text(user?.displayName ?? 'Usuário'),
              subtitle: Text(user?.email ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHouseholdSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Casa', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Consumer<HouseholdProvider>(
              builder: (context, householdProvider, child) {
                final household = householdProvider.currentHousehold;

                return ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(household?.name ?? 'Nenhuma casa selecionada'),
                  subtitle: household != null
                      ? Text(
                          '${household.members.length} membro${household.members.length != 1 ? 's' : ''}',
                        )
                      : const Text('Selecione uma casa'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    if (household != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HouseholdSettingsScreen(),
                        ),
                      );
                    } else {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              const HouseholdSelectionScreen(),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferências',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return ListTile(
                  leading: const Icon(Icons.palette),
                  title: const Text('Tema'),
                  subtitle: Text(_getThemeText(themeProvider.themeMode)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showThemeDialog(context, themeProvider);
                  },
                );
              },
            ),

            const Divider(),
            Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Idioma'),
                  subtitle: Text(
                    _getLanguageText(
                      languageProvider.currentLocale ?? const Locale('en'),
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showLanguageDialog(context, languageProvider);
                  },
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Fuso Horário'),
              subtitle: const Text('Automático (Brasil)'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notificações',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text('Lembretes de Alimentação'),
              subtitle: const Text(
                'Receber notificações quando for hora de alimentar',
              ),
              value: true,
              onChanged: (value) {},
            ),

            const Divider(),

            SwitchListTile(
              secondary: const Icon(Icons.warning),
              title: const Text('Alertas de Atraso'),
              subtitle: const Text(
                'Notificar quando alimentação estiver atrasada',
              ),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sobre', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Versão do App'),
              subtitle: const Text('1.0.0'),
              onTap: () {},
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Ajuda'),
              subtitle: const Text('Central de ajuda e suporte'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacidade'),
              subtitle: const Text('Política de privacidade e termos'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zona de Perigo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Sair da Conta',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              subtitle: Text(
                'Fazer logout da sua conta',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onErrorContainer.withAlpha(178),
                ),
              ),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeText(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  String _getLanguageText(Locale locale) {
    switch (locale.languageCode) {
      case 'pt':
        return 'Português (Brasil)';
      case 'en':
        return 'English (US)';
      case 'es':
        return 'Español (España)';
      default:
        return 'Sistema';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Claro'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              onTap: () {
                  themeProvider.setThemeMode(ThemeMode.light);
                  Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Escuro'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              onTap: () {
                  themeProvider.setThemeMode(ThemeMode.dark);
                  Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Sistema'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: themeProvider.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    themeProvider.setThemeMode(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              onTap: () {
                  themeProvider.setThemeMode(ThemeMode.system);
                  Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Sistema'),
              leading: Radio<Locale?>(
                value: null,
                groupValue: languageProvider.currentLocale,
                onChanged: (value) {
                  languageProvider.setLanguage(null);
                  Navigator.of(context).pop();
                },
              ),
              onTap: () {
                  languageProvider.setLanguage(null);
                  Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Português (Brasil)'),
              leading: Radio<Locale?>(
                value: const Locale('pt', 'BR'),
                groupValue: languageProvider.currentLocale,
                onChanged: (value) {
                  if (value != null) {
                    languageProvider.setLanguage(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              onTap: () {
                  languageProvider.setLanguage(const Locale('pt', 'BR'));
                  Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('English (US)'),
              leading: Radio<Locale?>(
                value: const Locale('en', 'US'),
                groupValue: languageProvider.currentLocale,
                onChanged: (value) {
                  if (value != null) {
                    languageProvider.setLanguage(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              onTap: () {
                  languageProvider.setLanguage(const Locale('en', 'US'));
                  Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Español (España)'),
              leading: Radio<Locale?>(
                value: const Locale('es', 'ES'),
                groupValue: languageProvider.currentLocale,
                onChanged: (value) {
                  if (value != null) {
                    languageProvider.setLanguage(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              onTap: () {
                  languageProvider.setLanguage(const Locale('es', 'ES'));
                  Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da Conta'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (mounted) {
                Navigator.of(context).pop();
                await AuthService().signOut();
              }
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
