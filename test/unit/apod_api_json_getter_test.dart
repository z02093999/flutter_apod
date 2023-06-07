import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_apod/Instance/apod_api_json_getter.dart';

@GenerateMocks([http.Client])
void main() {
  group('ApodApiJsonGetter Test', () {
    test('ApodApiJsonGetter Today Data Test 200', () async {
      final client = MockClient((_) async {
        final paraMap = _.url.queryParameters;
        if (paraMap.containsKey('thumbs') && paraMap['thumbs'] == 'true') {
          if (paraMap.containsKey('api_key') && paraMap['api_key'] == 'key') {
            return http.Response(
                '{"copyright": "copyright","date": "date","explanation": "explanation","hdurl": "hdurl","media_type": "mediaType","service_version": "serviceVersion","title": "true","url": "url"}',
                200);
          }
        }

        return http.Response(
            '{"copyright": "copyright","date": "date","explanation": "explanation","hdurl": "hdurl","media_type": "mediaType","service_version": "serviceVersion","title": "false","url": "url"}',
            200);
      });

      final getter = ApodApiJsonGetter();
      final maps =
          await getter.getJson(client, ['thumbs', 'api_key'], ['true', 'key']);

      expect(maps[0]['title'], 'true');
    });

    test('ApodApiJsonGetter By Date Test 200', () async {
      final client = MockClient((_) async {
        final paraMap = _.url.queryParameters;
        if (paraMap.containsKey('thumbs') && paraMap['thumbs'] == 'true') {
          if (paraMap.containsKey('api_key') && paraMap['api_key'] == 'key') {
            if (paraMap.containsKey('start_date') &&
                paraMap['start_date'] == '2023-01-01') {
              if (paraMap.containsKey('end_date') &&
                  paraMap['end_date'] == '2023-01-05') {
                return http.Response(
                    '[{"copyright": "copyright","date": "date","explanation": "explanation","hdurl": "hdurl","media_type": "mediaType","service_version": "serviceVersion","title": "true","url": "url"},{"copyright": "copyright","date": "date","explanation": "explanation","hdurl": "hdurl","media_type": "mediaType","service_version": "serviceVersion","title": "true","url": "url"},{"copyright": "copyright","date": "date","explanation": "explanation","hdurl": "hdurl","media_type": "mediaType","service_version": "serviceVersion","title": "true","url": "url"},{"copyright": "copyright","date": "date","explanation": "explanation","hdurl": "hdurl","media_type": "mediaType","service_version": "serviceVersion","title": "true","url": "url"},{"copyright": "copyright","date": "date","explanation": "explanation","hdurl": "hdurl","media_type": "mediaType","service_version": "serviceVersion","title": "true","url": "url"}]',
                    200);
              }
            }
          }
        }

        return http.Response(
            '{"copyright": "copyright","date": "date","explanation": "explanation","hdurl": "hdurl","media_type": "mediaType","service_version": "serviceVersion","title": "false","url": "url"}',
            200);
      });

      final getter = ApodApiJsonGetter();
      final maps = await getter.getJson(
          client,
          ['thumbs', 'start_date', 'end_date', 'api_key'],
          ['true', '2023-01-01', '2023-01-05', 'key']);

      expect(maps.length, 5);
    });

    test('ApodApiJsonGetter Test 200 Error', () async {
      final client = MockClient((_) async =>
          http.Response('{"error":{"code":"api","message":"not found"}}', 200));

      final getter = ApodApiJsonGetter();
      final maps =
          await getter.getJson(client, ['thumbs', 'api_key'], ['true', 'key']);

      expect(maps, isA<List<Map<String, dynamic>>>());
    });

    test('ApodApiJsonGetter Test other Error', () async {
      final client = MockClient((_) async => http.Response("Not Found", 404));

      final getter = ApodApiJsonGetter();
      final maps =
          await getter.getJson(client, ['thumbs', 'api_key'], ['true', 'key']);

      expect(maps, isA<List<Map<String, dynamic>>>());
    });
  });
}
