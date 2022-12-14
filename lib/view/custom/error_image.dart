import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';

class ErrorImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child:Image.asset(AppAssets.lab_parameters,color: Colors.lightGreen,),
    );
  }
}
