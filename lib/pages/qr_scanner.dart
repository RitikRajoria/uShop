import 'dart:developer';
import 'dart:io';
import 'package:drivool_assignment/pages/webview.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRScanPage extends StatefulWidget {
  final bool popCheck;
  QRScanPage({Key? key, required this.popCheck}) : super(key: key);

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? controller;
  Barcode? barcode;
  String url = "";

  bool isflashOn = false;
  bool enableButton = false;

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

      if (parts[0] == 'https:' || parts[0] == "http:") {
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
              height: (size.height) * 0.92,
              width: size.width,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  qrView(context),
                  Positioned(
                    bottom: 20,
                    child: _scanResult(size),
                  ),
                  Positioned(
                    bottom: 155,
                    child: _buttons(),
                  ),
                ],
              ),
            ),
            Container(
              height: (size.height) * 0.08,
              width: size.width,
              color: Colors.grey.shade800,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.grey.shade800,
                  ),
                ),
                onPressed: () {
                  final link = barcode!.code;
                  if (link != null) {
                    if (enableButton) {
                      storeHistory();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: ((context) => WebViewPage(
                                    url: link,
                                  ))),
                          (route) => false);
                      url = link;
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                        'Not a valid link!',
                        style: TextStyle(color: Colors.white),
                      )));
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.link,
                        color: Colors.teal.shade200,
                        size: 33,
                      ),
                      Text(
                        'Open Link',
                        style: TextStyle(
                            color: Colors.teal.shade200, fontSize: 14),
                      ),
                    ],
                  ),
                ),
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

  Widget _scanResult(Size size) => Container(
        width: (size.width) * 0.8,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              barcode != null ? '${barcode!.code}' : 'Scan a code',
              style: TextStyle(fontSize: 16, color: Colors.white),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

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

  void onQRViewCreated(QRViewController controller) {
    setState(() => this.controller = controller);

    controller.scannedDataStream.listen((barcode) {
      setState(() {
        this.barcode = barcode;
        linkChecker();
      });
    });
  }

  void storeHistory() async {
    SharedPreferences prefsdata = await SharedPreferences.getInstance();
    List<String> historyList = [];
    final bool check = prefsdata.containsKey('historyData');
    if (check) {
      historyList = prefsdata.getStringList('historyData')!;
      if (historyList.contains(url)) {
        print('already in history');
      } else {
        historyList.add(url);
      }
    } else {
      historyList.add(url);
    }

    prefsdata.setStringList('historyData', historyList);
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
