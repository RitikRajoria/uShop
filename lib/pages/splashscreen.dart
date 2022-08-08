import 'package:drivool_assignment/pages/onBoarding.dart';
import 'package:drivool_assignment/pages/qr_scanner.dart';
import 'package:drivool_assignment/pages/webview.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  final fireMessage = FirebaseMessaging.instance;
  String fcmToken = "";

  User? user = FirebaseAuth.instance.currentUser;
  late DatabaseReference ref;

  Future<String?> getfcmToken() async {
    final fcmvalue = await fireMessage.getToken();

    return fcmvalue;
  }

  Future<String?> signInwithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print(e.message);
      throw e;
    }
  }

  void savingToDB() async {
    final _prefs = await prefs;
    String fcmToken = _prefs.getString('fcmToken')!;
    String email = '${user!.email}';
    var temp = email.split('@');
    var temp2 = temp[0].split('.');
    var name = temp2.join();

    var currTime = DateTime.now().millisecondsSinceEpoch;

    var data = {"f": fcmToken, "t": currTime};
    await ref.child(name).set(data);
    print(currTime);
  }

  @override
  void initState() {
    signInwithGoogle();
    getfcmToken().then((value) async {
      fcmToken = value!;
      final _prefs = await prefs;
      _prefs.setString('fcmToken', fcmToken);
      print(value);
      setState(() {});
    });
    ref = FirebaseDatabase.instance.ref().child('fcm');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
        logo: Image.asset('assets/images/logo.png'),
        navigator: widget.showWeb
            ? WebViewPage(url: widget.link!)
            : widget.tutorial
                ? QRScanPage(
                    popCheck: false,
                  )
                : OnBoarding(),
        durationInSeconds: 5,
        // showLoader: false,
      );
    
  }
}
