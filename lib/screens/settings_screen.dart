import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtime/providers/theme_provider.dart';
import 'package:mealtime/providers/language_provider.dart';
import 'package:mealtime/providers/household_provider.dart';
import 'package:mealtime/screens/household_settings_screen.dart';
import 'package:mealtime/screens/household_selection_screen.dart';
import 'package:mealtime/services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          // User profile section
          _buildUserSection(context),
          
          // Household section
          _buildHouseholdSection(context),
          
          // App preferences section
          _buildPreferencesSection(context),
          
          // Notifications section
          _buildNotificationsSection(context),
          
          // About section
          _buildAboutSection(context),
          
          // Danger zone
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
            Text(
              'Perfil',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(user?.displayName ?? 'Usuário'),
              subtitle: Text(user?.email ?? ''),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Navigate to profile edit screen
              },
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
            Text(
              'Casa',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Consumer<HouseholdProvider>(
              builder: (context, householdProvider, child) {
                final household = householdProvider.currentHousehold;
                
                return ListTile(
                  leading: const Icon(Icons.home),
                  title: Text(household?.name ?? 'Nenhuma casa selecionada'),
                  subtitle: household != null
                      ? Text('${household.members.length} membro${household.members.length != 1 ? 's' : ''}')
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
                          builder: (context) => const HouseholdSelectionScreen(),
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
            
            // Theme
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
            
            // Language
            Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Idioma'),
                  subtitle: Text(_getLanguageText(languageProvider.currentLocale)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    _showLanguageDialog(context, languageProvider);
                  },
                );
              },
            ),
            
            const Divider(),
            
            // Timezone
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Fuso Horário'),
              subtitle: const Text('Automático (Brasil)'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Implement timezone selection
              },
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
              subtitle: const Text('Receber notificações quando for hora de alimentar'),
              value: true, // TODO: Get from settings
              onChanged: (value) {
                // TODO: Update notification settings
              },
            ),
            
            const Divider(),
            
            SwitchListTile(
              secondary: const Icon(Icons.warning),
              title: const Text('Alertas de Atraso'),
              subtitle: const Text('Notificar quando alimentação estiver atrasada'),
              value: true, // TODO: Get from settings
              onChanged: (value) {
                // TODO: Update notification settings
              },
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
            Text(
              'Sobre',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Versão do App'),
              subtitle: const Text('1.0.0'),
              onTap: () {
                // TODO: Show app info
              },
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Ajuda'),
              subtitle: const Text('Central de ajuda e suporte'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Navigate to help screen
              },
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacidade'),
              subtitle: const Text('Política de privacidade e termos'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Navigate to privacy screen
              },
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
                  color: Theme.of(context).colorScheme.onErrorContainer.withOpacity(0.7),
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

  String _getLanguageText(Locale? locale) {
    if (locale == null) return 'Sistema';
    
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
            RadioListTile<ThemeMode>(
              title: const Text('Claro'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Escuro'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Sistema'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Idioma'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Sistema'),
              value: 'system',
              groupValue: languageProvider.currentLocale?.languageCode ?? 'system',
              onChanged: (value) {
                if (value == 'system') {
                  languageProvider.setLanguage('system');
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Português (Brasil)'),
              value: 'pt',
              groupValue: languageProvider.currentLocale?.languageCode ?? 'system',
              onChanged: (value) {
                if (value != null) {
                  languageProvider.setLanguage('pt-BR');
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('English (US)'),
              value: 'en',
              groupValue: languageProvider.currentLocale?.languageCode ?? 'system',
              onChanged: (value) {
                if (value != null) {
                  languageProvider.setLanguage('en-US');
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Español (España)'),
              value: 'es',
              groupValue: languageProvider.currentLocale?.languageCode ?? 'system',
              onChanged: (value) {
                if (value != null) {
                  languageProvider.setLanguage('es-ES');
                  Navigator.of(context).pop();
                }
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
              Navigator.of(context).pop();
              await AuthService().signOut();
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}
