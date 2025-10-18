import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:mealtime/models/household_model.dart';
import 'package:mealtime/models/cat_model.dart';
import 'package:mealtime/models/feeding_model.dart';
import 'package:mealtime/models/weight_entry_model.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ========== HOUSEHOLD METHODS ==========

  Future<String> createHousehold(String name, {String? description}) async {
    try {
      final householdId = _uuid.v4();
      final inviteCode = _generateInviteCode();
      
      final household = Household(
        id: householdId,
        name: name,
        createdBy: uid,
        createdAt: DateTime.now(),
        inviteCode: inviteCode,
        members: [
          HouseholdMember(
            userId: uid,
            role: 'admin',
            joinedAt: DateTime.now(),
          ),
        ],
        description: description,
      );

      await _firestore.collection('households').doc(householdId).set(household.toMap());
      
      // Add household to user's householdIds
      await _firestore.collection('users').doc(uid).update({
        'householdIds': FieldValue.arrayUnion([householdId]),
        'lastActiveAt': DateTime.now().toIso8601String(),
      });

      return householdId;
    } catch (e) {
      throw Exception('Erro ao criar household: $e');
    }
  }

  Future<bool> joinHouseholdByCode(String inviteCode) async {
    try {
      final householdQuery = await _firestore
          .collection('households')
          .where('inviteCode', isEqualTo: inviteCode)
          .limit(1)
          .get();

      if (householdQuery.docs.isEmpty) {
        return false; // Código inválido
      }

      final householdDoc = householdQuery.docs.first;
      final household = Household.fromMap(householdDoc.data());

      // Check if user is already a member
      if (household.isMember(uid)) {
        return true; // Já é membro
      }

      // Add user to household
      final newMember = HouseholdMember(
        userId: uid,
        role: 'member',
        joinedAt: DateTime.now(),
      );

      await _firestore.collection('households').doc(household.id).update({
        'members': FieldValue.arrayUnion([newMember.toMap()]),
      });

      // Add household to user's householdIds
      await _firestore.collection('users').doc(uid).update({
        'householdIds': FieldValue.arrayUnion([household.id]),
        'lastActiveAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      throw Exception('Erro ao entrar no household: $e');
    }
  }

  Stream<List<Household>> getUserHouseholds() {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .asyncMap((userDoc) async {
      if (!userDoc.exists) return <Household>[];
      
      final userData = userDoc.data()!;
      final householdIds = List<String>.from(userData['householdIds'] ?? []);
      
      if (householdIds.isEmpty) return <Household>[];
      
      final households = <Household>[];
      for (final householdId in householdIds) {
        final householdDoc = await _firestore.collection('households').doc(householdId).get();
        if (householdDoc.exists) {
          households.add(Household.fromMap(householdDoc.data()!));
        }
      }
      
      return households;
    });
  }

  Future<Household?> getHousehold(String householdId) async {
    try {
      final doc = await _firestore.collection('households').doc(householdId).get();
      if (doc.exists) {
        return Household.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar household: $e');
    }
  }

  Future<void> updateMemberRole(String householdId, String memberId, String role) async {
    try {
      final household = await getHousehold(householdId);
      if (household == null) throw Exception('Household não encontrado');

      if (!household.isAdmin(uid)) {
        throw Exception('Apenas admins podem alterar roles');
      }

      final updatedMembers = household.members.map((member) {
        if (member.userId == memberId) {
          return member.copyWith(role: role);
        }
        return member;
      }).toList();

      await _firestore.collection('households').doc(householdId).update({
        'members': updatedMembers.map((m) => m.toMap()).toList(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar role: $e');
    }
  }

  // ========== CAT METHODS ==========

  Future<String> addCat(String householdId, Map<String, dynamic> catData) async {
    try {
      final catId = _uuid.v4();
      final schedule = FeedingSchedule.fromMap(catData['schedule'] ?? {});
      
      final cat = Cat(
        id: catId,
        householdId: householdId,
        name: catData['name'],
        photoUrl: catData['photoUrl'],
        birthdate: catData['birthdate'] != null ? DateTime.parse(catData['birthdate']) : null,
        currentWeight: catData['currentWeight']?.toDouble(),
        dietaryRestrictions: catData['dietaryRestrictions'],
        medicalNotes: catData['medicalNotes'],
        groups: catData['groups'] != null ? List<String>.from(catData['groups']) : null,
        schedule: schedule,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection('cats').doc(catId).set(cat.toMap());
      return catId;
    } catch (e) {
      throw Exception('Erro ao adicionar gato: $e');
    }
  }

  Future<void> updateCat(String catId, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = DateTime.now().toIso8601String();
      await _firestore.collection('cats').doc(catId).update(data);
    } catch (e) {
      throw Exception('Erro ao atualizar gato: $e');
    }
  }

  Future<void> deleteCat(String catId) async {
    try {
      await _firestore.collection('cats').doc(catId).delete();
    } catch (e) {
      throw Exception('Erro ao deletar gato: $e');
    }
  }

  Stream<List<Cat>> getCatsByHousehold(String householdId) {
    return _firestore
        .collection('cats')
        .where('householdId', isEqualTo: householdId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cat.fromMap(doc.data()))
            .toList());
  }

  Future<Cat?> getCat(String catId) async {
    try {
      final doc = await _firestore.collection('cats').doc(catId).get();
      if (doc.exists) {
        return Cat.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar gato: $e');
    }
  }

  // ========== FEEDING METHODS ==========

  Future<String> logFeeding(String catId, String householdId, {double? portionSize, String? notes, String? foodType}) async {
    try {
      final feedingId = _uuid.v4();
      
      final feeding = Feeding(
        id: feedingId,
        catId: catId,
        householdId: householdId,
        fedBy: uid,
        timestamp: DateTime.now(),
        portionSize: portionSize,
        notes: notes,
        foodType: foodType,
      );

      await _firestore.collection('feedings').doc(feedingId).set(feeding.toMap());
      return feedingId;
    } catch (e) {
      throw Exception('Erro ao registrar alimentação: $e');
    }
  }

  Stream<List<Feeding>> getFeedingsByCat(String catId, {int limit = 50}) {
    return _firestore
        .collection('feedings')
        .where('catId', isEqualTo: catId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Feeding.fromMap(doc.data()))
            .toList());
  }

  Stream<List<Feeding>> getFeedingsByHousehold(String householdId, {DateTime? startDate, DateTime? endDate, int limit = 100}) {
    Query query = _firestore
        .collection('feedings')
        .where('householdId', isEqualTo: householdId)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (startDate != null) {
      query = query.where('timestamp', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      query = query.where('timestamp', isLessThanOrEqualTo: endDate);
    }

    return query.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Feeding.fromMap(doc.data()))
        .toList());
  }

  // ========== WEIGHT TRACKING METHODS ==========

  Future<String> logWeight(String catId, double weight, {String? notes, String? measurementType}) async {
    try {
      final weightId = _uuid.v4();
      
      final weightEntry = WeightEntry(
        id: weightId,
        catId: catId,
        weight: weight,
        timestamp: DateTime.now(),
        loggedBy: uid,
        notes: notes,
        measurementType: measurementType ?? 'manual',
      );

      await _firestore.collection('weight_entries').doc(weightId).set(weightEntry.toMap());
      
      // Update cat's current weight
      await _firestore.collection('cats').doc(catId).update({
        'currentWeight': weight,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return weightId;
    } catch (e) {
      throw Exception('Erro ao registrar peso: $e');
    }
  }

  Stream<List<WeightEntry>> getWeightHistory(String catId, {int limit = 100}) {
    return _firestore
        .collection('weight_entries')
        .where('catId', isEqualTo: catId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WeightEntry.fromMap(doc.data()))
            .toList());
  }

  Future<void> setWeightGoal(String catId, {double? targetWeight, String? goalType, String? reminderFrequency, String? notes}) async {
    try {
      final weightGoal = WeightGoal(
        catId: catId,
        targetWeight: targetWeight,
        goalType: goalType ?? 'maintain',
        reminderFrequency: reminderFrequency,
        startDate: DateTime.now(),
        notes: notes,
      );

      await _firestore.collection('weight_goals').doc(catId).set(weightGoal.toMap());
    } catch (e) {
      throw Exception('Erro ao definir meta de peso: $e');
    }
  }

  Future<WeightGoal?> getWeightGoal(String catId) async {
    try {
      final doc = await _firestore.collection('weight_goals').doc(catId).get();
      if (doc.exists) {
        return WeightGoal.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao buscar meta de peso: $e');
    }
  }

  // ========== UTILITY METHODS ==========

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final code = StringBuffer();
    
    for (int i = 0; i < 6; i++) {
      code.write(chars[(random + i) % chars.length]);
    }
    
    return code.toString();
  }

  // ========== LEGACY METHODS (to be removed) ==========
  
  @Deprecated('Use new feeding methods instead')
  Future<void> addMeal(String name, int calories) async {
    // Legacy method - keeping for compatibility during transition
  }

  @Deprecated('Use new feeding methods instead')
  Stream<QuerySnapshot> get meals {
    // Legacy method - keeping for compatibility during transition
    return _firestore.collection('meals').where('uid', isEqualTo: uid).snapshots();
  }
}
