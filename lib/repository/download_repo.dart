
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mumbaiclinic/utils/FileUtils.dart';
import 'package:mumbaiclinic/utils/utils.dart';

class DownloadRepo{

  final FileUtils _fileUtils = FileUtils.instance;

  DownloadRepo();

  Future<bool> downloadReport(String url)async{
    final data = await http.get(Uri.parse(url),headers: Utils.getHeaders());

    if(data.statusCode==201|| data.statusCode==200){

      String fileName = '${DateFormat('ddMMMyyyy').format(DateTime.now())}_${url.split('/').last}'.replaceAll('\\', '_');

     final result = await _fileUtils.save(fileName, data.bodyBytes);

      return data.statusCode==200;
    }else{
      return false;
    }

  }

  Future<bool> downloadPrescription(String url)async{
    final data = await http.get(Uri.parse(url),headers: Utils.getHeaders());

    if(data.statusCode==201|| data.statusCode==200){

      String fileName = '${url.split('/').last}'.replaceAll('\\', '_');

      final result = await _fileUtils.save(fileName, data.bodyBytes);

      return data.statusCode==200;
    }else{
      return false;
    }

  }

}