
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/utils/utils.dart';


MessageModel messageModelFromJson(String str) => MessageModel.fromJson(json.decode(str));


class MessageRepository{

  MessageRepository();


  Future<Message> getPatientBMIMessage()async{

    final response = await get(Uri.parse('${APIConfig.BASE_URL}Patient/getPatientBMIMessage?patientID=${PreferenceManager.getUserId()}'),headers: Utils.getHeaders());
    log(response.body);
    if(response.statusCode==200 || response.statusCode==201){
      final model = messageModelFromJson(response.body);
      if(model.message.length>0)
        return model.message.first;
      else
        return null;
    }else{
      return null;
    }

  }


  Future<Message> getPatientBPMessage()async{

    final response = await get(Uri.parse('${APIConfig.BASE_URL}Patient/getPatientBPMessage?patientID=${PreferenceManager.getUserId()}'),headers: Utils.getHeaders());
    log(response.body);
    if(response.statusCode==200 || response.statusCode==201){
      final model = messageModelFromJson(response.body);
      if(model.message.length>0)
        return model.message.first;
      else
        return null;
    }else{
      return null;
    }

  }


  Future<Message> getPatientSugarMessage()async{

    final response = await get(Uri.parse('${APIConfig.BASE_URL}Patient/getPatientSugarMessage?patientID=${PreferenceManager.getUserId()}'),headers: Utils.getHeaders());

    log(response.body);
    if(response.statusCode==200 || response.statusCode==201){
      final model = messageModelFromJson(response.body);
      if(model.message.length>0)
        return model.message.first;
      else
        return null;
    }else{
      return null;
    }


  }


  Future<Message> getPatientPulseMessage()async{

    final response = await get(Uri.parse('${APIConfig.BASE_URL}Patient/getPatientPulseMessage?patientID=${PreferenceManager.getUserId()}'),headers: Utils.getHeaders());
    log(response.body);
    if(response.statusCode==200 || response.statusCode==201){
      final model = messageModelFromJson(response.body);
      if(model.message.length>0)
        return model.message.first;
      else
        return null;
    }else{
      return null;
    }

  }


  Future<Message> getPatientSPO2Message()async{

    final response = await get(Uri.parse('${APIConfig.BASE_URL}Patient/getPatientSPO2Message?patientID=${PreferenceManager.getUserId()}'),headers: Utils.getHeaders());
    log(response.body);
    if(response.statusCode==200 || response.statusCode==201){
      final model = messageModelFromJson(response.body);
      if(model.message.length>0)
        return model.message.first;
      else
        return null;
    }else{
      return null;
    }

  }



}


class MessageModel {
  MessageModel({
    this.success,
    this.message,
    this.error,
  });

  String success;
  List<Message> message;
  String error;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    success: json["success"],
    message: List<Message>.from(json["payload"].map((x) => Message.fromJson(x))),
    error: json["error"],
  );

}

class Message {
  Message({
    this.messageText,
    this.imagePath,
    this.soundPath,
    this.animation,
  });

  String messageText;
  String imagePath;
  String soundPath;
  bool animation;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    messageText: json["message_text"],
    imagePath: json["image_path"],
    soundPath: json["sound_path"],
    animation: json["show_animation"]==1,
  );

  Map<String,dynamic> toJson()=>{
    "message_text":messageText,
    "image_path":imagePath,
    "sound_path":soundPath,
    "show_animation":animation,
  };

}

