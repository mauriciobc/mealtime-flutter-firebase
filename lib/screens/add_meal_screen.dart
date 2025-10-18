import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/services/database_service.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String calories = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Meal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Meal Name'),
                validator: (val) => val!.isEmpty ? 'Enter a meal name' : null,
                onChanged: (val) {
                  setState(() => name = val);
                },
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Enter calories' : null,
                onChanged: (val) {
                  setState(() => calories = val);
                },
              ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                child: const Text('Add Meal'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final navigator = Navigator.of(context);
                    await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid).addMeal(name, int.parse(calories));
                    if (mounted) {
                      navigator.pop();
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
