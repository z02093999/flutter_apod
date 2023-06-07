import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_apod/model/apod_db_data.dart';
import 'package:flutter_apod/page/favorite_page.dart';
import 'package:flutter_apod/provider/apod_data_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

@GenerateNiceMocks([MockSpec<ApodDataProvider>()])
import 'favorite_page_widget_test.mocks.dart';

void main() {
  final mockApodDataProvider = MockApodDataProvider();
  when(mockApodDataProvider.getFavorite()).thenAnswer((realInvocation) async {
    return [
      ApodDbData(
          '2023-01-01',
          'title1',
          'test\\picture\\Black_hole_M87.jpg;test\\picture\\Black_hole_M87.jpg',
          '',
          'image',
          'copyright1',
          'explanation1',
          1),
      ApodDbData(
          '2023-01-02',
          'title2',
          'test\\picture\\Black_hole_M87.jpg;test\\picture\\Black_hole_M87.jpg',
          '',
          'image',
          'copyright2',
          'explanation2',
          1),
      ApodDbData(
          '2023-01-03',
          'title3',
          'test\\picture\\Black_hole_M87.jpg;test\\picture\\Black_hole_M87.jpg',
          '',
          'image',
          'copyright3',
          'explanation3',
          1),
      ApodDbData(
          '2023-01-04',
          'title4',
          'test\\picture\\Black_hole_M87.jpg;test\\picture\\Black_hole_M87.jpg',
          'https://youtu.be/8GnSFAZD8YY',
          'video',
          'copyright4',
          'explanation4',
          1)
    ];
  });

  final page = ChangeNotifierProvider<ApodDataProvider>.value(
    value: mockApodDataProvider,
    child: MaterialApp(
      title: 'Favorite Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Favorite Test'),
        ),
        body: const FavoritePage(),
      ),
    ),
  );

  group('Favorite Page Test', () {
    testWidgets('Favorite Test', (widgetTester) async {
      await widgetTester.pumpWidget(page);
      await widgetTester.pumpAndSettle();

      //會產生4張favorite card
      expect(find.byType(Card), findsNWidgets(4));

      //4張卡片的title
      expect(find.text('title1'), findsOneWidget);
      expect(find.text('title2'), findsOneWidget);
      expect(find.text('title3'), findsOneWidget);
      expect(find.text('title4'), findsOneWidget);

      //會找到4張M78 block hole 圖片
      expect(find.image(FileImage(File('test\\picture\\Black_hole_M87.jpg'))),
          findsNWidgets(4));

      //點擊轉跳到詳細內容page
      await widgetTester.tap(find.text('title1'));
      await widgetTester.pumpAndSettle();

      //找到date:2023-01-01的日期
      expect(find.text('2023-01-01'), findsNWidgets(2));
      //找到date:2023-01-01的說明
      expect(find.text('explanation1'), findsOneWidget);
    });
  });
}
