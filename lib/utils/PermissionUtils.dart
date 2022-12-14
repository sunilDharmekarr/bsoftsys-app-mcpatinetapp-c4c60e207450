import 'package:permission_handler/permission_handler.dart';

class PermissionUtils{

  PermissionUtils._internal();

  static final PermissionUtils _instance = PermissionUtils._internal();

  static PermissionUtils get instance => _instance;


  Future<bool> requestPermission(Permission permission)async{
      // var status = await permission.status;
      //
      // if (status.isUndetermined || status.isDenied) {
      //  final result =  await permission.request();
      //  if(result.isGranted)
      //    return true;
      //  else return false;
      // }
      // if (status.isGranted) {
      //   return true;
      // }
    return true;
  }
}