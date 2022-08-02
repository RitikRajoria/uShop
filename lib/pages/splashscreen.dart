import 'package:drivool_assignment/pages/onBoarding.dart';
import 'package:drivool_assignment/pages/qr_scanner.dart';
import 'package:drivool_assignment/pages/webview.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  final bool showWeb;
  final String? link;
  final bool tutorial;

  SplashScreen(
      {Key? key,
      required this.showWeb,
      required this.link,
      required this.tutorial})
      : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image.asset('assets/images/logo.png'),
      navigator: widget.showWeb
          ? WebViewPage(url: widget.link!)
          : widget.tutorial
              ? QRScanPage(popCheck: false,)
              : OnBoarding(),
      durationInSeconds: 5,
      // showLoader: false,
    );
  }
}
