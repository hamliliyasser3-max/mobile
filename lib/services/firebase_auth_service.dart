import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/user_settings_model.dart';
import '../core/constants/app_constants.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        final doc = await _db.collection(AppConstants.colUsers).doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromFirestore(doc.data()!, user.uid);
        } else {
          // Initialize user record if not present
          final newUser = UserModel(
            uid: user.uid,
            fullName: user.displayName ?? email.split('@').first,
            email: user.email ?? email,
            preferredLanguage: 'en',
            createdAt: DateTime.now(),
          );
          await _db.collection(AppConstants.colUsers).doc(user.uid).set(newUser.toFirestore());
          return newUser;
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> registerWithEmail({
    required String email,
    required String password,
    required String fullName,
    String preferredLanguage = 'en',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(fullName);

        final userModel = UserModel(
          uid: user.uid,
          fullName: fullName,
          email: email.trim(),
          preferredLanguage: preferredLanguage,
          createdAt: DateTime.now(),
        );

        final initialSettings = UserSettingsModel(
          ownerUid: user.uid,
          language: preferredLanguage,
          notificationsEnabled: true,
          theme: 'dark',
          electricityPrice: AppConstants.defaultPricePerKwh,
          dailyTarget: AppConstants.defaultDailyTargetKwh,
          monthlyBudget: AppConstants.defaultMonthlyBudgetCash,
          updatedAt: DateTime.now(),
        );

        // Batch initialize user and user_settings
        final batch = _db.batch();
        batch.set(_db.collection(AppConstants.colUsers).doc(user.uid), userModel.toFirestore());
        batch.set(_db.collection(AppConstants.colSettings).doc(user.uid), initialSettings.toFirestore());
        await batch.commit();

        return userModel;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection(AppConstants.colUsers).doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromFirestore(doc.data()!, user.uid);
    }
    return null;
  }
}
