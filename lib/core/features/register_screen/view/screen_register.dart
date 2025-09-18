import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rimes_interview_projects/core/features/login_screen/view/screen_login.dart';
import 'package:rimes_interview_projects/core/features/register_screen/model/register_models.dart';
import 'package:rimes_interview_projects/core/features/register_screen/viewmodel/register_view_model.dart';
import 'package:rimes_interview_projects/core/netwoks/db_helper.dart';
import 'package:rimes_interview_projects/utilities/auth_status.dart';
import 'package:rimes_interview_projects/utilities/auth_storage.dart';

class ScreenRegister extends StatefulWidget {
  const ScreenRegister({super.key});

  @override
  State<ScreenRegister> createState() => _ScreenRegisterState();
}

class _ScreenRegisterState extends State<ScreenRegister> {
  final _formKey = GlobalKey<FormState>();

  final usernameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final positionCtrl = TextEditingController();
  final countryCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RegisterViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor:  Colors.blue,),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(usernameCtrl, "Username", Icons.person,
                  validator: (val) =>
                      val!.isEmpty ? "Enter your username" : null),
              const SizedBox(height: 15),
              _buildTextField(emailCtrl, "Email", Icons.email,
                  validator: (val) =>
                      val!.contains("@") ? null : "Enter valid email"),
              const SizedBox(height: 15),
              _buildTextField(phoneCtrl, "Phone", Icons.phone,
                  validator: (val) =>
                      val!.length < 10 ? "Enter valid phone" : null),
              const SizedBox(height: 15),
              _buildTextField(positionCtrl, "Position", Icons.work,
                  validator: (val) =>
                      val!.isEmpty ? "Enter your position" : null),
              const SizedBox(height: 15),
              _buildTextField(countryCtrl, "Country", Icons.flag,
                  validator: (val) =>
                      val!.isEmpty ? "Enter your country" : null),
              const SizedBox(height: 15),
              _buildTextField(passwordCtrl, "Password", Icons.lock,
                  obscureText: true,
                  validator: (val) =>
                      val!.length < 6 ? "Password too short" : null),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          final user = RegisterModels(
                            uid: "",
                            username: usernameCtrl.text.trim(),
                            email: emailCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            position: positionCtrl.text.trim(),
                            country: countryCtrl.text.trim(),
                            createAt: DateTime.now(),
                          );

                          final status = await viewModel.registerFun(
                              user, passwordCtrl.text.trim());

                          if (status == AuthStatus.success) {


                            if (!mounted) return;

                            await AuthStorage.setuserExist();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Registered Successfully!")),
                            );
                            
                            
                           

                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                          } else {
                            if (!mounted) return;
                            String message = "Registration Failed";
                            if (status == AuthStatus.emailAlreadyInUse) {
                              message = "Email already in use";
                            } else if (status == AuthStatus.weakPassword) {
                              message = "Weak password";
                            } else if (status == AuthStatus.invalidEmail) {
                              message = "Invalid email";
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: viewModel.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label,
          IconData icon,
          {String? Function(String?)? validator, bool obscureText = false}) =>
      TextFormField(
        controller: ctrl,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
}