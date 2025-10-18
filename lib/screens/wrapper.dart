import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mealtime/screens/main_screen.dart';
import 'package:mealtime/screens/login_screen.dart';
import 'package:mealtime/screens/household_selection_screen.dart';
import 'package:mealtime/providers/household_provider.dart';
import 'package:mealtime/services/database_service.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  bool _isLoading = true;
  bool _hasLoadedHouseholds = false;

  @override
  void initState() {
    super.initState();
    _loadUserHouseholds();
  }

  Future<void> _loadUserHouseholds() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final databaseService = DatabaseService(uid: user.uid);
      final households = await databaseService.getUserHouseholds().first;

      if (mounted) {
        context.read<HouseholdProvider>().setUserHouseholds(households);
        setState(() {
          _isLoading = false;
          _hasLoadedHouseholds = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasLoadedHouseholds = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    // Show loading while checking authentication and loading households
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando...'),
            ],
          ),
        ),
      );
    }

    // User not authenticated - show login
    if (user == null) {
      return const LoginScreen();
    }

    // User authenticated but no households loaded yet - show loading
    if (!_hasLoadedHouseholds) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando casas...'),
            ],
          ),
        ),
      );
    }

    // User authenticated and households loaded - check if has households
    final householdProvider = context.watch<HouseholdProvider>();

    if (householdProvider.userHouseholds.isEmpty) {
      // No households - show household selection (which will show create/join options)
      return const HouseholdSelectionScreen();
    }

    if (householdProvider.currentHousehold == null) {
      // Has households but none selected - show selection
      return const HouseholdSelectionScreen();
    }

    // Has selected household - show main app
    return const MainScreen();
  }
}
