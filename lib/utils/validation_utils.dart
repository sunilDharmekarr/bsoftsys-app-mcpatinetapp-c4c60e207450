import 'package:flutter/material.dart';

class ValidationUtils {
  ValidationUtils._();

  static String emailPatter=r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
  static String alpha  = "[a-zA-Z]";
  static String number = "[0-9]";

  static bool validateEmail(String email) {

    if(email==null)
    return false;
    if(email.isEmpty)
    return false;
  
    RegExp regExp = new RegExp(emailPatter);
   
    return regExp.hasMatch(email);

  }

  static bool validateOnlyAlpha(String input){
    if(input==null)
    return false;
    if(input.isEmpty)
    return false;
  
    RegExp regExp = new RegExp(r'^[a-zA-Z]');
   
    return regExp.hasMatch(input);
  }

  

  static bool validateOnlyNumber(String input){
    if(input==null)
    return false;
    if(input.isEmpty)
    return false;
  
    RegExp regExp = new RegExp('[0-9]');
   
    return regExp.hasMatch(input);
  }
}
