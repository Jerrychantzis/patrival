// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, avoid_print, unused_import
import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// start of the app
import 'package:carnival_app1/features/app/splash_screen/splash_screen.dart';

// admin authority
import 'package:carnival_app1/features/host_auth/admin_home.dart';
import 'package:carnival_app1/features/host_auth/group_edit.dart';

// captain authority
import 'package:carnival_app1/features/captain_auth/captain_home.dart';

// user authority
import 'package:carnival_app1/features/user_auth/presentation/pages/groups_list_page.dart';
import 'package:carnival_app1/features/user_auth/presentation/pages/login_page.dart';
import 'features/user_auth/presentation/pages/home_menu/profile.dart';
import 'features/user_auth/presentation/pages/home_page.dart';
import 'features/user_auth/presentation/pages/signup_page.dart';
import 'features/user_auth/presentation/pages/start_page.dart';
import 'package:dcdg/dcdg.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid || kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyA3AoUjmUIwuR8t1w72yp73HaPZL0tWq0o",
        appId: "1:415818325388:android:9835439896e28f50b8caa9",
        messagingSenderId: "415818325388",
        projectId: "carnivaldatabase-1f814",
        storageBucket: "carnivaldatabase-1f814.appspot.com",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _setupFirebaseMessaging(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase',
      routes: {
        '/': (context) => SplashScreen(
          child: StartPage(),
        ),
        '/login': (context) => LoginPage(),
        '/signUp': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/admin_home': (context) => AdminHomePage(),
        '/group_edit': (context) => GroupsEdit(),
        '/start': (context) => StartPage(),
        '/groups': (context) => GroupsList(),
        '/profile': (context) => ProfileScreen(),
        '/captain_home': (context) => CaptainHomePage(),
      },
    );
  }

  void _setupFirebaseMessaging(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission to receive notifications
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Subscribe to the 'all' topic
      await messaging.subscribeToTopic('all');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(message.notification?.title ?? 'Notification'),
            content: Text(message.notification?.body ?? 'No body'),
          ),
        );
      });

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        Navigator.pushNamed(context, '/notifications');
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }
}
