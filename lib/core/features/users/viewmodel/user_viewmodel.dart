import 'package:flutter/material.dart';
import '../../../repository/user_repositoy.dart';
import '../../register_screen/model/register_models.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _repo = UserRepository();
  List<RegisterModels> users = [];
  bool isLoading = false;

  UserViewModel() {
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    isLoading = true;
    notifyListeners();
    try {
      users = await _repo.getUsersOnce();
    } catch (e) {
      debugPrint("Error loading users: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

