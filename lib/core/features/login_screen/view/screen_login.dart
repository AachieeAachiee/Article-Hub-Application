
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rimes_interview_projects/core/features/article_list/view/article_home_screen.dart';
import 'package:rimes_interview_projects/core/features/login_screen/viewmodel/Login_view_model.dart';
import 'package:rimes_interview_projects/utilities/auth_status.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LoginViewModell>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9), // light background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        title: const Text(
          "Welcome Back",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Icon(Icons.lock_outline,
                  size: 80, color: Colors.blue.shade700),
              const SizedBox(height: 20),
              Text(
                "Login to your account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) =>
                    val != null && val.contains("@") ? null : "Invalid email",
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) =>
                    val != null && val.length >= 6 ? null : "Password too short",
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: viewModel.isLoading ? null : _loginUser,
                child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Login",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Contact Admin for Registration")),
                  );
                },
                child: const Text("Don’t have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = Provider.of<LoginViewModell>(context, listen: false);
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();

    final status = await vm.login(email, password);

    if (!mounted) return;

    if (status == AuthStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text("Login Successful")),

      );

      await saveFCMToken(currentUser!.uid);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ArticleHomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Failed !")),
      );
    }
  }
}

Future<void> saveFCMToken(String uid) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fcmToken': token,
    }, SetOptions(merge: true));
    print("Fcm token : $token --- for User: $uid");
  }
}