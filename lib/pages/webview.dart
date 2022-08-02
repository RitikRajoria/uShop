import 'dart:developer';
import 'dart:io';

import 'package:drivool_assignment/pages/qr_scanner.dart';
import 'package:drivool_assignment/pages/tiles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  var menuItems = <String>['Tiles', 'Scan QR'];

  String? link;

  @override
  void initState() {
    link = widget.url;
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
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            actions: [
              PopupMenuButton<String>(
                itemBuilder: (BuildContext context) {
                  return menuItems.map((String choice) {
                    return PopupMenuItem<String>(
                      child: Text(choice),
                      value: choice,
                    );
                  }).toList();
                },
                onSelected: onMenuSelect,
              ),
            ],
            title: Padding(
              padding: EdgeInsets.only(left: (size.width) * 0.39),
              child: Text('Appbar'),
            ),
          ),
          body: WillPopScope(
            onWillPop: () async {
              if (await controller.canGoBack()) {
                controller.goBack();
                return false;
              } else {
                return true;
              }
            },
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
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('savedLink', "$link");
                String? prefTemp = prefs.getString('savedLink');
                log(prefTemp!);
                print("New website: $newLink");
              },
            ),
          ),
        ),
      ),
    );
  }

  void onMenuSelect(item) {
    switch (item) {
      case 'Tiles':
        print('Tiles clicked');
        Navigator.push(
            context, MaterialPageRoute(builder: ((context) => TilesPage())));
        break;
      case 'Scan QR':
        Navigator.push(
            context, MaterialPageRoute(builder: ((context) => QRScanPage(popCheck: true,))));
        break;
    }
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
