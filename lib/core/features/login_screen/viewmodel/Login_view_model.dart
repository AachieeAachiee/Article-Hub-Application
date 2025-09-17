import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rimes_interview_projects/core/features/register_screen/model/register_models.dart';
import 'package:rimes_interview_projects/core/netwoks/db_helper.dart';
import 'package:rimes_interview_projects/utilities/auth_status.dart';

class LoginViewModell extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final DBHelper _dbHelper = DBHelper();

  bool isLoading = false;
  AuthStatus? status;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  
  Future<AuthStatus> _loginOnline(String email, String password) async {
    final cred = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    final user = cred.user;
    if (user == null) throw Exception("User not found");

    final token = await user.getIdToken();
    if (token?.isEmpty == true) throw Exception("Token empty");

   
    await _storage.write(key: "jwt_token", value: token);
    await _storage.write(key: "uid", value: user.uid);

    
    final userDoc = await FirebaseFirestore.instance
        .collection("Rimes-Users")
        .doc(user.uid)
        .get();

    if (userDoc.exists) {
      final userData = RegisterModels.fromMap(userDoc.data()!);

      try {
        await _dbHelper.insertUser(userData); 
      } catch (e) {
        print("SQLite insert error: $e");
      }
    }

    return AuthStatus.success;
  }

  
  Future<AuthStatus> _loginOffline(String email, String password) async {
    final users = await _dbHelper.getUsers();
    final match =
        users.firstWhere((u) => u.email == email, orElse: () => RegisterModels(
          uid: "",
          username: "",
          email: "",
          phone: "",
          position: "",
          country: "",
          createAt: DateTime.now(),
        ));

    if (match.email.isEmpty) {
      return AuthStatus.userNotFound;
    }

    
    final dummyToken = "offline_token_${DateTime.now().millisecondsSinceEpoch}";
    await _storage.write(key: "jwt_token", value: dummyToken);
    await _storage.write(key: "uid", value: match.uid ?? "offline_uid");

    return AuthStatus.success;
  }

  
  Future<AuthStatus> login(String email, String password) async {
    setLoading(true);
    try {
   
      final result = await InternetAddress.lookup("google.com");
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        status = await _loginOnline(email, password);
      } else {
        status = await _loginOffline(email, password);
      }
    } catch (_) {
     
      status = await _loginOffline(email, password);
    } finally {
      setLoading(false);
    }
    return status!;
  }

  Future<String?> getToken() async => await _storage.read(key: "jwt_token");
}