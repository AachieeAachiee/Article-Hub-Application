
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rimes_interview_projects/core/features/article_list/viewmodel/article_viewmodel.dart';
import 'package:rimes_interview_projects/core/features/login_screen/viewmodel/Login_view_model.dart';
import 'package:rimes_interview_projects/core/features/register_screen/viewmodel/register_view_model.dart';
import 'package:rimes_interview_projects/core/features/splash_screen/view/screen_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rimes_interview_projects/core/netwoks/api.dart';

Future<void> main() async {

   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.instance.requestPermission();
  await firebaseApi().requestNotification();
  runApp(const MyApp());
  
}

class MyApp extends StatefulWidget {


  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(

      providers: [
      ChangeNotifierProvider(create: (_) => RegisterViewModel()),
      ChangeNotifierProvider(create: (_) => LoginViewModell()),
      ChangeNotifierProvider(create: (_) => ArticlesViewModel()),
    ],
      child: MaterialApp(
      
        title: 'Rimes_Interview_Task_App',
        debugShowCheckedModeBanner: false,
        builder: (context,child){
          return CallbackShortcuts(bindings: const<ShortcutActivator,VoidCallback>{}, child: child!);
        },
        theme: ThemeData(
          
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home:  ScreenSplash(),
      ),
    );
  }
}

  





