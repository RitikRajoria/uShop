import 'dart:convert';

import 'package:drivool_assignment/pages/webview.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TilesPage extends StatefulWidget {
  const TilesPage({Key? key}) : super(key: key);

  @override
  State<TilesPage> createState() => _TilesPageState();
}

class _TilesPageState extends State<TilesPage> {
  late SharedPreferences sharedPreferences;
  List<String> historyList = [];

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
            child: GridView.builder(
                itemCount: historyList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  childAspectRatio: 3 / 2.5,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WebViewPage(
                                    url: historyList[index],
                                  )),
                          (route) => false);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border:
                            Border.all(width: 1, color: Colors.grey.shade300),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  'Website Name',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  historyList[index],
                                  style: TextStyle(
                                    color: Colors.grey.shade300,
                                  ),
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  softWrap: false,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          )),
    );
  }

  void initialGetSaved() async {
    sharedPreferences = await SharedPreferences.getInstance();

    List<String> data = sharedPreferences.getStringList('historyData')!;
    historyList = data;
    print(historyList);
    setState(() {});
  }
}
