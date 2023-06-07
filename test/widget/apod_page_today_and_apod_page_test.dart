import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_apod/model/apod_db_data.dart';
import 'package:flutter_apod/page/apod_page_today.dart';
import 'package:flutter_apod/provider/apod_data_provider.dart';
import 'package:flutter_apod/provider/apod_setting_open_url_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

@GenerateNiceMocks(
    [MockSpec<ApodDataProvider>(), MockSpec<ApodSettingOpenUrlProvider>()])
import 'apod_page_today_and_apod_page_test.mocks.dart';

void main() {
  const imgPath = 'test\\picture\\Black_hole_M87.jpg';
  final todayImageApodData = ApodDbData('2023-01-01', 'title-today-image',
      '$imgPath;$imgPath', '', 'image', 'copyright', 'explanation', 0);

  final todayVideoApodData = ApodDbData(
      '2023-01-01',
      'title-today-video',
      '$imgPath;$imgPath',
      'https://youtu.be/8GnSFAZD8YY',
      'video',
      'copyright',
      'explanation',
      0);

  final mockApodDataProvider = MockApodDataProvider();
  when(mockApodDataProvider.getTodayData()).thenAnswer((_) async {});

  when(mockApodDataProvider.changeFavorite(any))
      .thenAnswer((realInvocation) async {
    if (todayImageApodData.favorite == 0) {
      todayImageApodData.favorite = 1;
    } else {
      todayImageApodData.favorite = 0;
    }
    if (todayVideoApodData.favorite == 0) {
      todayVideoApodData.favorite = 1;
    } else {
      todayVideoApodData.favorite = 0;
    }
  });

  final mockApodSettingOpenUrlProvider = MockApodSettingOpenUrlProvider();
  when(mockApodSettingOpenUrlProvider.launchApiUrl(todayVideoApodData.videoUrl))
      .thenAnswer((realInvocation) async {});

  final page = MultiProvider(
    providers: [
      ChangeNotifierProvider<ApodDataProvider>.value(
          value: mockApodDataProvider),
      ChangeNotifierProvider<ApodSettingOpenUrlProvider>.value(
          value: mockApodSettingOpenUrlProvider)
    ],
    child: MaterialApp(
      title: 'Today Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Today'),
        ),
        body: const ApodPageFuture(),
      ),
    ),
  );

  group('Apod today and Apod Page Test', () {
    testWidgets('Image Today Test', (widgetTester) async {
      await widgetTester.pumpWidget(page);
      when(mockApodDataProvider.apodDbData).thenReturn(todayImageApodData);
      await widgetTester.pumpAndSettle();

      //base verify
      //favorite icon
      expect(find.byIcon(Icons.star), findsOneWidget);
      //no favorite icon color grey
      var icon = find.byIcon(Icons.star).evaluate().single.widget as Icon;

      expect(icon.color, Colors.grey);

      //date
      expect(find.text(todayImageApodData.date), findsOneWidget);
      //image
      expect(find.image(FileImage(File(imgPath))), findsOneWidget);
      //title
      expect(find.text(todayImageApodData.title), findsOneWidget);
      //copyright
      expect(find.text('copyright：${todayImageApodData.copyright}'),
          findsOneWidget);
      //explanation
      expect(find.text(todayImageApodData.explanation), findsOneWidget);
      //image type no have show video button
      expect(find.byType(TextButton), findsNothing);

      //set favorite
      await widgetTester.tap(find.byIcon(Icons.star));
      await widgetTester.pumpAndSettle();

      //icons.star is yellow color
      icon = find.byIcon(Icons.star).evaluate().single.widget as Icon;
      expect(icon.color, Colors.amber);
    });

    testWidgets('Video Today Test', (widgetTester) async {
      todayVideoApodData.favorite = 0;

      await widgetTester.pumpWidget(page);
      when(mockApodDataProvider.apodDbData).thenReturn(todayVideoApodData);
      await widgetTester.pumpAndSettle();

      //base verify
      //favorite icon
      expect(find.byIcon(Icons.star), findsOneWidget);
      //no favorite icon color grey
      var icon = find.byIcon(Icons.star).evaluate().single.widget as Icon;

      expect(icon.color, Colors.grey);

      //date
      expect(find.text(todayVideoApodData.date), findsOneWidget);
      //image
      expect(find.image(FileImage(File(imgPath))), findsOneWidget);
      //title
      expect(find.text(todayVideoApodData.title), findsOneWidget);
      //copyright
      expect(find.text('copyright：${todayVideoApodData.copyright}'),
          findsOneWidget);
      //explanation
      expect(find.text(todayVideoApodData.explanation), findsOneWidget);

      //video type have show video button
      expect(find.text('showVideo'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);

      //tap textbutton
      await widgetTester.tap(find.text('showVideo'));
      await widgetTester.pumpAndSettle();
      verify(mockApodSettingOpenUrlProvider
              .launchApiUrl(todayVideoApodData.videoUrl))
          .called(1);

      //set favorite
      await widgetTester.tap(find.byIcon(Icons.star));
      await widgetTester.pumpAndSettle();

      //icons.star is yellow color
      icon = find.byIcon(Icons.star).evaluate().single.widget as Icon;
      expect(icon.color, Colors.amber);
    });
  });
}
