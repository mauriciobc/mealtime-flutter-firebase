import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:myapp/screens/add_meal_screen.dart';
import 'package:myapp/screens/meal_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    final user = Provider.of<User?>(context);

    return StreamProvider<QuerySnapshot?>.value(
      value: DatabaseService(uid: user!.uid).meals,
      initialData: null,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MealTime'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await auth.signOut();
              },
            )
          ],
        ),
        body: const MealList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddMealScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class MealList extends StatefulWidget {
  const MealList({super.key});

  @override
  State<MealList> createState() => _MealListState();
}

class _MealListState extends State<MealList> {
  @override
  Widget build(BuildContext context) {
    final meals = Provider.of<QuerySnapshot?>(context);

    if (meals == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: meals.docs.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(meals.docs[index]['name']),
          subtitle: Text('${meals.docs[index]['calories']} calories'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MealDetailScreen(meal: meals.docs[index]),
              ),
            );
          },
        );
      },
    );
  }
}
