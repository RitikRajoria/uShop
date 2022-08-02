import 'package:drivool_assignment/pages/onBoarding.dart';
import 'package:drivool_assignment/pages/qr_scanner.dart';
import 'package:drivool_assignment/pages/splashscreen.dart';

import 'package:drivool_assignment/pages/webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

class MyApp extends StatelessWidget {
  final bool showWeb;
  final String? link;
  final bool onboard;

  const MyApp(
      {super.key,
      required this.showWeb,
      required this.link,
      required this.onboard});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(
        link: link,
        showWeb: showWeb,
        tutorial: onboard,
      ),
    );
  }
}
