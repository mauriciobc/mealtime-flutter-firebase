import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MealDetailScreen extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> meal;

  const MealDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(meal['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calories: ${meal['calories']}', style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
