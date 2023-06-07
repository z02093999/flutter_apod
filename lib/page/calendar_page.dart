import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_apod/common/date_relevant.dart';
import 'package:flutter_apod/model/apod_db_data.dart';
import 'package:flutter_apod/page/apod_page_route.dart';
import 'package:flutter_apod/provider/apod_calendar_provider.dart';
import 'package:flutter_apod/provider/apod_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? _selectedDay;
  DateTime _focuseDay = DateTime.now();
  List<dynamic> _selectedEvent = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;

  List<dynamic> _getEvent(BuildContext context, DateTime? day) {
    String dateStr = formater.format(day!);
    final map = context.read<ApodCalendarProvider>().apodDataMap;
    if (map.containsKey(dateStr)) {
      return [map[dateStr]];
    } else {
      return [];
    }
  }

  Widget _getEventWidget() {
    if (_selectedEvent.isEmpty) return Container();

    ApodDbData data = _selectedEvent[0] as ApodDbData;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Card(
        child: InkWell(
            splashColor: Colors.blueGrey,
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) {
                        return ApodPageRoute(data);
                      },
                      maintainState: false //false is 無用時釋放資源
                      ));
            },
            child: Row(
              children: [
                Image.file(File(data.smallImagePath), width: 100, height: 100),
                Expanded(
                    child: Text(
                  data.title,
                  style: const TextStyle(fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ))
              ],
            )),
      ),
    );
  }

  Future<void> _showDialog(String title, String msg) async {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(msg),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(tr('calendarPage.close')))
          ],
        );
      },
    );
  }

  @override
  void deactivate() {
    context.read<ApodCalendarProvider>().showDialogFunc = null;
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ApodDbData>>(
      future: context.watch<ApodDataProvider>().getAllData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('${tr('error')}：${snapshot.error}');
          } else {
            context.read<ApodCalendarProvider>().addEventData(snapshot.data!);
            context.read<ApodCalendarProvider>().showDialogFunc = _showDialog;
            return SingleChildScrollView(
              child: Builder(builder: (context) {
                return Column(
                  children: [
                    LinearProgressIndicator(
                        value: context
                            .watch<ApodCalendarProvider>()
                            .progressValue),
                    TableCalendar(
                        focusedDay: _focuseDay,
                        firstDay: DateTime.utc(1995, 06, 16),
                        lastDay: DateTime.utc(2099, 12, 31),
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          _selectedDay = selectedDay;
                          _focuseDay = focusedDay;
                          _selectedEvent = _getEvent(context, _selectedDay);
                          (context as Element)
                              .markNeedsBuild(); //限縮在Bulider範圍rebuild
                        },
                        calendarFormat: _calendarFormat,
                        onFormatChanged: (format) {
                          _calendarFormat = format;
                          (context as Element)
                              .markNeedsBuild(); //限縮在Bulider範圍rebuild
                        },
                        onPageChanged: (focusedDay) {
                          _focuseDay = focusedDay;
                        },
                        eventLoader: (day) {
                          return _getEvent(context, day);
                        }),
                    TextButton(
                      onPressed: () {
                        if (context.read<ApodCalendarProvider>().goGetMonthData(
                            _focuseDay.year, _focuseDay.month)) {
                          _showDialog(tr('calendarPage.downloadMsg'),
                              tr('calendarPage.startDownload'));
                        } else {
                          _showDialog(tr('calendarPage.downloadMsg'),
                              tr('calendarPage.downloading'));
                        }
                      },
                      child: Text(tr('calendarPage.downloadMonth')),
                    ),
                    _getEventWidget(),
                  ],
                );
              }),
            );
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
