import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_apod/interface/i_picture_saver.dart';
import 'package:path/path.dart';

///實作IPictureSaver
class PictureSaver implements IPictureSaver {
  @override
  Future<void> save(String filePathWithName, Uint8List bytes) async {
    final folderPath = dirname(filePathWithName); //資料夾路徑
    await Directory(folderPath).create(recursive: true); //創建資料夾
    final pictureFile = File(filePathWithName); //建立 file 實例
    await pictureFile.writeAsBytes(bytes); //寫入圖片bytes
  }
}
