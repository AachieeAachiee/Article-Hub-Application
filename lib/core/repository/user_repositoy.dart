import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rimes_interview_projects/core/features/register_screen/model/register_models.dart';

class UserRepository {
  final _usersRef = FirebaseFirestore.instance.collection("users");

  Stream<List<RegisterModels>> usersStream() {
    return _usersRef.snapshots().map((snap) =>
        snap.docs.map((doc) => RegisterModels.fromFirestore(doc)).toList());
  }

  Future<List<RegisterModels>> getUsersOnce() async {
    final snap = await _usersRef.get();
    return snap.docs.map((doc) => RegisterModels.fromFirestore(doc)).toList();
  }

  Future<RegisterModels?> getUserById(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (!doc.exists) return null;
    return RegisterModels.fromFirestore(doc);
  }
}



