import 'dart:convert';

import 'package:drivool_assignment/pages/webview.dart';
import 'package:drivool_assignment/utils/widgets/tiles_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firestore_ui/firestore_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/stores_model.dart';

class TilesPage extends StatefulWidget {
  const TilesPage({Key? key}) : super(key: key);

  @override
  State<TilesPage> createState() => _TilesPageState();
}

class _TilesPageState extends State<TilesPage> {
  late SharedPreferences sharedPreferences;
  List<String> historyList = [];
  List<String> historyLinks = [];

  User? user = FirebaseAuth.instance.currentUser;
  late DatabaseReference ref;

  List<StoresModel> models = [];

  final loadRef = FirebaseDatabase.instance.ref();

  Future<List<StoresModel>> extractdata() async {
    models = [];
    historyList.forEach((element) async {
      final snapshot = await loadRef.child('icon/$element').get();
      if (snapshot.exists) {
        final data = snapshot.value;

        Map<String, dynamic> dataMap = jsonDecode(jsonEncode(data));

        models.add(StoresModel.fromJson(dataMap));
        setState(() {});
      } else {
        print("$element not found");
      }
    });

    return models;
  }

  @override
  void initState() {
    initialGetSaved();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text('History'),
        ),
      ),
      body: Container(
          height: size.height,
          width: size.width,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: (size.height) * 0.9,
                    child: models.isEmpty
                        ? Center(
                            child: Container(
                            child: CircularProgressIndicator(),
                          ))
                        : gridViewStores(historyList, models),
                  ),
                ],
              ),
            ),
          )),
    );
  }

  void initialGetSaved() async {
    sharedPreferences = await SharedPreferences.getInstance();

    List<String> data = sharedPreferences.getStringList('historyData')!;
    List<String> linkData = sharedPreferences.getStringList('historyLinks')!;
    historyList = data;
    historyLinks = linkData;

    print(historyList);
    setState(() {});
    extractdata();
  }
}
