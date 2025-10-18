import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference mealCollection = FirebaseFirestore.instance.collection('meals');

  Future<void> addMeal(String name, int calories) async {
    await mealCollection.add({
      'name': name,
      'calories': calories,
      'uid': uid,
    });
  }

  Stream<QuerySnapshot> get meals {
    return mealCollection.where('uid', isEqualTo: uid).snapshots();
  }
}
