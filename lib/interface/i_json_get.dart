import 'package:http/http.dart' as http;

class IJsonGetter {
  Future<List<Map<String, dynamic>>> getJson(http.Client client,
          List<String> parameter, List<String> value) async =>
      [];
}
