import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getPictureSaveFolder() async {
  final directory = await getApplicationDocumentsDirectory(); //取得文件儲存路徑
  final folderPath = join(directory.path, 'images'); //apod圖片save路徑

  return folderPath;
}
