import 'package:drivool_assignment/pages/qr_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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

  User? user = FirebaseAuth.instance.currentUser;
  late DatabaseReference ref;
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                height: 100,
              ),
              Container(
                height: 200,
                width: 200,
                child: Image.asset('assets/images/scanner.gif'),
              ),
              Column(
                children: [
                  Text(
                    'Hyperlocal',
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: 1.2,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Text(
                    'Scan the store QR code of your local stores to access them online. If the store owner has never been on hyperlocal, do them a favor and help him to be online.',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.2,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(
                height: 58,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        // to demo page
                      },
                      child: Text(
                        'DEMO',
                        style: TextStyle(
                          fontSize: 16,
                          letterSpacing: 1.2,
                          color: Colors.green.shade500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_auth.currentUser != null) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setBool('tutorial', true);
                          print('user logged in');

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QRScanPage(
                                popCheck: false,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Login First!')));

                          signInwithGoogle();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green.shade500,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      child: Container(
                        height: 50,
                        child: Row(
                          children: [
                            Text(
                              'CONTINUE  ',
                              style: TextStyle(
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
