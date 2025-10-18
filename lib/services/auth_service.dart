import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mealtime/models/user_model.dart';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // create user obj based on firebase user
  User? _userFromFirebaseUser(User? user) {
    return user;
  }

  // auth change user stream
  Stream<User?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  // sign in with email and password
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (error) {
      developer.log('Error signing in', error: error);
      return null;
    }
  }

  // register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      
      if (user != null) {
        // Update display name
        await user.updateDisplayName(displayName);
        
        // Create user document in Firestore
        await _createUserDocument(user, displayName);
      }
      
      return _userFromFirebaseUser(user);
    } catch (error) {
      developer.log('Error registering', error: error);
      return null;
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(User user, String displayName) async {
    final userModel = UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (error) {
      developer.log('Error getting user data', error: error);
      return null;
    }
  }

  // Update user preferences
  Future<void> updateUserPreferences({
    String? preferredLanguage,
    String? timezone,
    String? displayName,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final updateData = <String, dynamic>{};
      if (preferredLanguage != null) updateData['preferredLanguage'] = preferredLanguage;
      if (timezone != null) updateData['timezone'] = timezone;
      if (displayName != null) {
        updateData['displayName'] = displayName;
        await user.updateDisplayName(displayName);
      }
      updateData['lastActiveAt'] = DateTime.now().toIso8601String();

      await _firestore.collection('users').doc(user.uid).update(updateData);
    } catch (error) {
      developer.log('Error updating user preferences', error: error);
    }
  }

  // Add household to user
  Future<void> addHouseholdToUser(String householdId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'householdIds': FieldValue.arrayUnion([householdId]),
        'lastActiveAt': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      developer.log('Error adding household to user', error: error);
    }
  }

  // Remove household from user
  Future<void> removeHouseholdFromUser(String householdId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('users').doc(user.uid).update({
        'householdIds': FieldValue.arrayRemove([householdId]),
        'lastActiveAt': DateTime.now().toIso8601String(),
      });
    } catch (error) {
      developer.log('Error removing household from user', error: error);
    }
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (error) {
      developer.log('Error signing out', error: error);
      return null;
    }
  }
}
