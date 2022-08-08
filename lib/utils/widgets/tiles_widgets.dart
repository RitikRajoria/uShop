import 'package:drivool_assignment/models/stores_model.dart';
import 'package:flutter/material.dart';

GridView gridViewStores(List<String> historyList, List<StoresModel> models) {
    return GridView.builder(
                          itemCount: historyList.length == 0
                              ? 1
                              : historyList.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                            childAspectRatio: 3 / 3,
                          ),
                          itemBuilder: (context, index) {
                            return Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.contain,
                                        image: NetworkImage(
                                            'https://www.iconpacks.net/icons/2/free-store-icon-2017-thumb.png'),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          '${models[index].name}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
  }