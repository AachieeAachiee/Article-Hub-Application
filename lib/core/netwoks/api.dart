import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rimes_interview_projects/core/features/login_screen/view/screen_login.dart';

Future<void>handlerBackgroundMessage(RemoteMessage message) async{

  print('Title : ${message.notification?.title}');
  print('Body : ${message.notification?.body}');
  

}


class firebaseApi {
  
FirebaseMessaging messaging = FirebaseMessaging.instance;

Future<void> requestNotification() async {
  
  

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
   final fCmToken = await messaging.getToken();
    print( 'Token : $fCmToken');

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');

     final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await saveFCMToken(user.uid);
      FirebaseMessaging.onBackgroundMessage(handlerBackgroundMessage);
    }
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
}

}