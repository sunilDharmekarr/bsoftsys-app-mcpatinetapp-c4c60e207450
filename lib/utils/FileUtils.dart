import 'dart:io';
import 'dart:typed_data';

import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:path_provider/path_provider.dart';

class FileUtils {
  FileUtils._internal();

  static FileUtils _instance = FileUtils._internal();

  static FileUtils get instance => _instance;

  Future<String> getSavePath() async {
    String localDirectory = '';
    // if (Platform.isAndroid) {
    //  localDirectory = '/sdcard/download/MumbaiClinic';
    //  await Directory(localDirectory).create(recursive: true);
    // } else {
    localDirectory = (await getApplicationDocumentsDirectory()).path;
    PreferenceManager.setFilePath('$localDirectory');
    //}

    return localDirectory;
  }

  Future<bool> save(String fileName, Uint8List data) async {
    final localDirectory = await getSavePath();

    File savedPath = File('${localDirectory}/$fileName');

    if (await savedPath.exists()) {
      Utils.showToast(message: 'File already exists');
      return true;
    } else if (data != null) {
      savedPath.createSync(recursive: false);
      await savedPath.writeAsBytes(data, mode: FileMode.write);
      Utils.showToast(message: 'Downloaded successfully.');
      return true;
    } else {
      Utils.showToast(message: 'Failed to process request');
      return false;
    }
  }
}
