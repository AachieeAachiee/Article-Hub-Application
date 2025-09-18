import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:rimes_interview_projects/core/features/login_screen/view/screen_login.dart';
import 'package:rimes_interview_projects/core/features/register_screen/view/screen_register.dart';
import 'package:rimes_interview_projects/utilities/auth_storage.dart';

class ScreenSplash extends StatefulWidget {
  const ScreenSplash({super.key});

  @override
  State<ScreenSplash> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<ScreenSplash> {
  @override
  void initState() {
    gotologincheck();
    debugPrint("SplashScreen initState called ");

    super.initState();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            Lottie.asset(
              "assets/animation/shopping cart.json",
              fit: BoxFit.contain,
              width: 200,
              height: 300,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> gotologincheck() async {
   
    final registered = await AuthStorage.userExist();

 await Future.delayed(Duration(seconds: 5));
 if (!mounted) return;

    Navigator.pushReplacement(
      context,
    (MaterialPageRoute(builder: (ctx) =>registered ? const LoginScreen() : const ScreenRegister())));
  }


}
