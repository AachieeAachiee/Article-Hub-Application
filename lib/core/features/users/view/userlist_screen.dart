import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rimes_interview_projects/core/features/login_screen/view/screen_login.dart';
import 'package:rimes_interview_projects/core/features/users/view/user_profilescreen.dart';
import 'package:rimes_interview_projects/core/netwoks/api.dart';
import '../../register_screen/model/register_models.dart';
import '../viewmodel/user_viewmodel.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {


  @override
  void initState() {
    super.initState();
  firebaseApi().requestNotification();
  initNotificationListeners(context);
}


  
  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("All Users")),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: vm.users.length,
              itemBuilder: (context, i) {
                final u = vm.users[i];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                        u.username.isNotEmpty ? u.username[0].toUpperCase() : "?"),
                  ),
                  title: Text(u.username),
                  subtitle: Text(u.email),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UserProfileScreen(user: u),
                    ),
                  ),
                );
              },
            ),
    );
  }
}




void initNotificationListeners(BuildContext context) {
  
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${notification.title}: ${notification.body}")),
      );
    }
  });

  
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    final articleId = message.data['articleId'];
    if (articleId != null) {
      Navigator.pushNamed(context, '/articleDetail', arguments: articleId);
    }
  });
}





