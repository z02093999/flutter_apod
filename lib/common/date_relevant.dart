import 'package:intl/intl.dart';

final formater = DateFormat('yyyy-MM-dd');

/// list index 0 is first day; index 1 is last day
List<String> getMonthFirstDayAndLastDay(int year, int month) {
  final firstDay = DateTime(year, month); //當月第一天
  final lastDay =
      DateTime(year, month + 1).subtract(const Duration(days: 1)); //當月最後一天
  final firstDayStr = formater.format(firstDay);
  final lastDayStr = formater.format(lastDay);

  return [firstDayStr, lastDayStr];
}
