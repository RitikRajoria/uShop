import 'dart:developer';
import 'dart:io';

import 'package:drivool_assignment/pages/qr_scanner.dart';
import 'package:drivool_assignment/pages/tiles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController controller;
  TextEditingController linkField = TextEditingController();

  String? link;
  User? user = FirebaseAuth.instance.currentUser;
  late DatabaseReference ref;
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  late bool showcaseCheck;

  BuildContext? myContext;
  final _key1 = GlobalKey();

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

  void onShowcaseFinish() async {
    final _prefs = await prefs;
    _prefs.setBool('showcaseWebView', true);
  }

  Future<void> checkShowcase() async {
    final _prefs = await prefs;
    bool temp = _prefs.containsKey('showcaseWebView');
    if (temp == true) {
      showcaseCheck = _prefs.getBool('showcaseWebView')!;
    } else {
      showcaseCheck = false;
    }
  }

//converting link to name and
  void linkToData() {
    String link =
        "https://bhola-kirana.web.app/store.html?id=Bhola_Kirana_Store0uh&uid=a5usOw6zLbWDlzibJgJd6h8uEVO2";
    var temp = link.split('id=');
    var storeIdName = temp[1].split('&u');
    var temp2 = storeIdName[0].substring(0, storeIdName[0].length - 3);
    var name = temp2.replaceAll("_", " ");
    print(storeIdName[0]);
    print(name);
  }

  someEvent() {
    if (!showcaseCheck) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ShowCaseWidget.of(myContext!).startShowCase([_key1]);
      });
    }

    setState(() {});
  }

  @override
  void initState() {
    link = widget.url;
    ref = FirebaseDatabase.instance.ref().child('fcm');

    savingToDB();
    checkShowcase().then((value) {
      someEvent();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: WillPopScope(
        onWillPop: showExitPopup,
        child: ShowCaseWidget(
          onFinish: () {
            onShowcaseFinish();
          },
          builder: Builder(builder: (context) {
            myContext = context;
            return Scaffold(
              backgroundColor: Colors.black,
              extendBodyBehindAppBar: true,
              body: WillPopScope(
                onWillPop: () async {
                  if (await controller.canGoBack()) {
                    controller.goBack();
                    return false;
                  } else {
                    return true;
                  }
                },
                child: SafeArea(
                  child: WebView(
                    userAgent: 'Chrome/80.0.3987.106',
                    initialUrl: link,
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (controller) {
                      this.controller = controller;
                    },
                    onPageStarted: (newLink) async {
                      setState(() {
                        link = newLink;
                        linkField.text = newLink;
                      });
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      prefs.setString('savedLink', "$link");
                      String? prefTemp = prefs.getString('savedLink');
                      log(prefTemp!);
                      print("New website: $newLink");
                    },
                  ),
                ),
              ),
              floatingActionButton: Showcase(
                title: "Menu",
                key: _key1,
                description: "Tap Here!",
                descTextStyle: TextStyle(color: Colors.white),
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                shapeBorder: CircleBorder(),
                showcaseBackgroundColor: Colors.black,
                overlayPadding: EdgeInsets.all(5),
                contentPadding: EdgeInsets.all(10),
                child: SpeedDial(
                  backgroundColor: Colors.black,
                  overlayColor: Colors.black,
                  overlayOpacity: 0.5,
                  animatedIcon: AnimatedIcons.menu_close,
                  children: [
                    SpeedDialChild(
                      child: Icon(Icons.store),
                      label: 'Store',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => TilesPage())));
                      },
                    ),
                    SpeedDialChild(
                      child: Icon(Icons.qr_code_scanner),
                      label: 'QR Scan',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: ((context) => QRScanPage(
                                      popCheck: true,
                                    ))));
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          //show confirm dialogue
          //the return value will be from "Yes" or "No" options
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Exit App'),
            content: Text('Do you want to exit an App?'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                //return false when click on "NO"
                child: Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                //return true when click on "Yes"
                child: Text('Yes'),
              ),
            ],
          ),
        ) ??
        false; //if showDialouge had returned null, then return false
  }
}
