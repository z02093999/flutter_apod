import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_apod/page/apod_page_route.dart';
import 'package:flutter_apod/provider/apod_data_provider.dart';
import 'package:provider/provider.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: FutureBuilder(
            future: context.watch<ApodDataProvider>().getFavorite(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text('${tr('error')}：${snapshot.error.toString()}');
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return Card(
                          child: InkWell(
                        splashColor: Colors.blueGrey,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) {
                                    return ApodPageRoute(snapshot.data![index]);
                                  },
                                  maintainState: false //false is 無用時釋放資源
                                  ));
                        },
                        child: ListTile(
                          leading: Image.file(
                            File(snapshot.data![index].smallImagePath),
                            width: 50,
                            height: 50,
                          ),
                          title: Text(snapshot.data![index].title),
                        ),
                      ));
                    },
                  );
                }
              } else {
                return const CircularProgressIndicator();
              }
            }));
  }
}
