import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mealtime/providers/household_provider.dart';
import 'package:mealtime/screens/cats_list_screen.dart';
import 'package:mealtime/screens/feed_cats_screen.dart';
import 'package:mealtime/screens/analytics_screen.dart';
import 'package:mealtime/screens/settings_screen.dart';
import 'package:mealtime/widgets/bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    CatsListScreen(),
    FeedCatsScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HouseholdProvider>(
      builder: (context, householdProvider, child) {
        final household = householdProvider.currentHousehold;
        
        if (household == null) {
          return const Scaffold(
            body: Center(
              child: Text('Nenhuma casa selecionada'),
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions,
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          ),
        );
      },
    );
  }
}
