import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rimes_interview_projects/core/features/register_screen/model/register_models.dart';
import 'package:rimes_interview_projects/core/netwoks/db_helper.dart';
import 'package:rimes_interview_projects/utilities/auth_status.dart';

class RegisterViewModel extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final DBHelper _dbHelper = DBHelper();

  bool isLoading = false;
  AuthStatus? status;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<AuthStatus> registerFun(RegisterModels user, String password) async {
    setLoading(true);
    try {
      final email = user.email.trim().toLowerCase();
      if (email.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: "Email cannot be empty",
        );
      }

     
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = cred.user?.uid;
      if (uid == null) throw Exception("Firebase UID is null");
      user.uid = uid;

      
      try {
        await FirebaseFirestore.instance
            .collection('Rimes-Users')
            .doc(user.uid)
            .set(user.toMap());
      } catch (e) {
        print("Firestore error: $e");
        status = AuthStatus.failure;
        return status!;
      }

    
      await _storage.write(key: 'uid', value: uid);

      
      try {
        await _dbHelper.insertUser(user);
        print("User saved in local DB: ${user.email}");
      } catch (e) {
        print("SQLite error (ignored): $e");
      }

      status = AuthStatus.success;
      return status!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        status = AuthStatus.emailAlreadyInUse;
      } else if (e.code == 'weak-password') {
        status = AuthStatus.weakPassword;
      } else if (e.code == 'invalid-email') {
        status = AuthStatus.invalidEmail;
      } else {
        status = AuthStatus.failure;
      }
      print("FirebaseAuthException: ${e.code} - ${e.message}");
      return status!;
    } catch (e) {
      print("Register error: $e");
      status = AuthStatus.failure;
      return status!;
    } finally {
      setLoading(false);
    }
  }
}