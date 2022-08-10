import 'package:drivool_assignment/firebase_options.dart';
import 'package:drivool_assignment/pages/onBoarding.dart';
import 'package:drivool_assignment/pages/qr_scanner.dart';
import 'package:drivool_assignment/pages/splashscreen.dart';

import 'package:drivool_assignment/pages/webview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // new code for firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseDatabase database = FirebaseDatabase.instance;

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin fltNotification;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });
  //new code end

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  final prefs = await SharedPreferences.getInstance();
  final showWeb = prefs.containsKey('savedLink');
  String? link = prefs.getString('savedLink');
  final tutorialFlag = prefs.containsKey('tutorial');
  bool tutorial;
  if (tutorialFlag) {
    tutorial = prefs.getBool('tutorial')!;
    print('$tutorial is tutorial');
  } else {
    tutorial = false;
  }

  runApp(MyApp(
    showWeb: showWeb,
    link: link,
    onboard: tutorial,
  ));
}

class MyApp extends StatefulWidget {
  final bool showWeb;
  final String? link;
  final bool onboard;

  const MyApp(
      {super.key,
      required this.showWeb,
      required this.link,
      required this.onboard});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? fltNotification;

  void pushFCMtoken() async {
    String? token = await messaging.getToken();
    print(token);
  }

  void initMessaging() {
    var androiInit =
        AndroidInitializationSettings('@mipmap/ic_launcher'); //for logo
    var iosInit = IOSInitializationSettings();
    var initSetting = InitializationSettings(android: androiInit, iOS: iosInit);
    fltNotification = FlutterLocalNotificationsPlugin();
    fltNotification!.initialize(initSetting);
    var androidDetails = AndroidNotificationDetails('1', 'channelName',
        channelDescription: 'channelDescription',
        importance: Importance.high,
        playSound: true,
        priority: Priority.high);
    var iosDetails = IOSNotificationDetails();
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        fltNotification!.show(notification.hashCode, notification.title,
            notification.body, generalNotificationDetails);
      }
    });
  }

  @override
  void initState() {
    pushFCMtoken();
    initMessaging();

    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(
        link: widget.link,
        showWeb: widget.showWeb,
        tutorial: widget.onboard,
      ),
    );
  }
}
