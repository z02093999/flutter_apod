import 'package:flutter/material.dart';
import 'package:flutter_apod/page/apod_page.dart';
import 'package:flutter_apod/provider/apod_data_provider.dart';
import 'package:provider/provider.dart';

class ApodPageFuture extends StatefulWidget {
  const ApodPageFuture({super.key});

  @override
  State<ApodPageFuture> createState() => _ApodPageFutureState();
}

class _ApodPageFutureState extends State<ApodPageFuture> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<void>(
          //連線資料庫後get apod data
          future: context.read<ApodDataProvider>().getTodayData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text('Error：${snapshot.error.toString()}');
              } else {
                return ApodPage(context.watch<ApodDataProvider>().apodDbData);
              }
            } else {
              return const CircularProgressIndicator();
            }
          }),
    );
  }
}
