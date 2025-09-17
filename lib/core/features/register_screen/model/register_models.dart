import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RegisterModels {
  String? uid;
  String username;
  String email;
  String phone;
  String position;
  String country;
  final DateTime createAt;

  RegisterModels({
    this.uid,
    required this.username,
    required this.email,
    required this.phone,
    required this.position,
    required this.country,
    required this.createAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'username': username,
        'email': email,
        'phone': phone,
        'position': position,
        'country': country,
        'createAt': createAt.toIso8601String(),
      };

       Map<String, dynamic> toJson() => {
        'uid': uid,
        'username': username,
        'email': email,
        'phone': phone,
        'position': position,
        'country': country,
        'createAt': createAt.toIso8601String(),
      };

      factory RegisterModels.fromMap(Map<String, dynamic> map) {
    return RegisterModels(
      uid: map["uid"] ?.toString(),
      username: map["username"] ?? "",
      email: map["email"] ?? "",
      phone: map["phone"] ?? "",
      position: map["position"] ?? "",
      country: map["country"] ?? "",
      createAt: DateTime.tryParse(map['createAt']?.toString() ?? "")?? DateTime.now() ,
    );
  }

  factory RegisterModels.fromFirestore(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>;
    return RegisterModels.fromMap({
      ...data,
      "uid":doc.id,
    });
}
}
