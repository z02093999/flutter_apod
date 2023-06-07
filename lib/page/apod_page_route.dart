import 'package:flutter/material.dart';
import 'package:flutter_apod/model/apod_db_data.dart';
import 'package:flutter_apod/page/apod_page.dart';

class ApodPageRoute extends StatefulWidget {
  const ApodPageRoute(this.dbData, {super.key});
  final ApodDbData dbData;

  @override
  State<StatefulWidget> createState() => _ApodPageRouteState();
}

class _ApodPageRouteState extends State<ApodPageRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.dbData.date), backgroundColor: Colors.grey),
      body: ApodPage(widget.dbData),
    );
  }
}
