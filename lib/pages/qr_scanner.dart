import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:drivool_assignment/pages/webview.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class QRScanPage extends StatefulWidget {
  final bool popCheck;
  QRScanPage({Key? key, required this.popCheck}) : super(key: key);

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final qrKey = GlobalKey(debugLabel: 'QR');
  final qrShowcase = GlobalKey();

  QRViewController? controller;
  Barcode? barcode;
  String url = "";
  BuildContext? mycontext;

  bool isflashOn = false;
  bool enableButton = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(milliseconds: 500), () async {
      await controller!.flipCamera();
      await controller!.flipCamera();
      print('timer');
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller?.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  void linkChecker() {
    if (barcode != null) {
      var str = barcode!.code;
      var parts = str!.split('//');

      log(parts[0]);

      if ((parts[0] == 'https:' || parts[0] == "http:") &&
          str.contains('?id=')) {
        setState(() {
          enableButton = true;
        });
      } else {
        setState(() {
          enableButton = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        if (widget.popCheck) {
          return pagePopper();
        } else {
          return showExitPopup();
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: size.height,
              width: size.width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  qrView(context),
                  Positioned(
                    bottom: 155,
                    child: _buttons(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttons() => Container(
        decoration: BoxDecoration(
            color: Colors.white24, borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            IconButton(
              onPressed: () async {
                await controller!.toggleFlash();
                isflashOn = !isflashOn;
                setState(() {});
              },
              icon: Icon(
                isflashOn ? Icons.flash_on : Icons.flash_off,
                size: 20,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: () async {
                await controller!.flipCamera();
              },
              icon: Icon(
                Icons.switch_camera,
                size: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );

  // Widget _scanResult(Size size) => Container(
  //       width: (size.width) * 0.8,
  //       decoration: BoxDecoration(
  //         color: Colors.white24,
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(12.0),
  //         child: Center(
  //           child: Text(
  //             barcode != null ? '${barcode!.code}' : 'Scan a code',
  //             style: TextStyle(fontSize: 16, color: Colors.white),
  //             maxLines: 3,
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ),
  //       ),
  //     );

  Widget qrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.tealAccent,
          borderRadius: 12,
          borderWidth: 5,
          borderLength: 28,
          cutOutSize: MediaQuery.of(context).size.width * 0.65,
        ),
      );

  String linkToData(String link) {
    var temp = link.split('id=');
    var storeIdName = temp[1].split('&u');
    var temp2 = storeIdName[0].substring(0, storeIdName[0].length - 3);
    var name = temp2.replaceAll("_", " ");
    print(storeIdName[0]);
    print(name);
    return storeIdName[0].toLowerCase();
  }

  void onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);

    controller.scannedDataStream.listen((barcode) {
      setState(() {
        this.barcode = barcode;
        linkChecker();
        final link = barcode.code;
        if (link != null) {
          if (enableButton) {
            final storeId = linkToData(link);
            storeHistory(storeId);
            url = link;
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: ((context) => WebViewPage(
                          url: link,
                        ))),
                (route) => false);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
              'Not a valid link!',
              style: TextStyle(color: Colors.white),
            )));
          }
        }
      });
    });
  }

  void storeHistory(String storeId) async {
    SharedPreferences prefsdata = await SharedPreferences.getInstance();
    List<String> historyList = [];
    List<String> historyLinks = [];
    final bool check = prefsdata.containsKey('historyData');
    final bool check2 = prefsdata.containsKey('historyData');
    if (check && check2) {
      historyList = prefsdata.getStringList('historyData')!;
      historyLinks = prefsdata.getStringList('historyLinks')!;
      if (historyList.contains(storeId) && historyLinks.contains(url)) {
        print('already in history');
      } else {
        historyList.add(storeId);
        historyLinks.add(url);
      }
    } else {
      historyList.add(storeId);
      historyLinks.add(url);
    }

    prefsdata.setStringList('historyData', historyList);
    prefsdata.setStringList('historyLinks', historyLinks);
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

  Future<bool> pagePopper() async {
    return await true;
  }
}
