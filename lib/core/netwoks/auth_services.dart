import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rimes_interview_projects/core/features/register_screen/model/register_models.dart';
import 'package:rimes_interview_projects/utilities/auth_status.dart';


class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<AuthStatus> saveUsertoFirebase(RegisterModels user, String password) async {
    try {

      if(user.uid == null|| user.uid !.isEmpty){
        return AuthStatus.failure;
      }
      await _firestore.collection('Rimes-Users').doc(user.uid).set(user.toMap());
      return AuthStatus.success;
      
     } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') return AuthStatus.emailAlreadyInUse;
      if (e.code == 'weak-password') return AuthStatus.weakPassword;
      if (e.code == 'invalid-email') return AuthStatus.invalidEmail;
      return AuthStatus.unknownError;
    } catch (e) {
      debugPrint("Firestore save error: $e");
      return AuthStatus.failure;
    }
  }
}