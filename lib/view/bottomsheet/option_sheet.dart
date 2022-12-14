import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';

class OptionSheet extends StatefulWidget {
  @override
  _OptionSheetState createState() => _OptionSheetState();
}

class _OptionSheetState extends State<OptionSheet> {
  @override
  Widget build(BuildContext context) {
    return  BottomSheet(
      onClosing: (){
        Navigator.pop(context);
      },
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (ctx){
        return Container(
          padding: const EdgeInsets.all(8),
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Column(
            children: <Widget>[
              Container(
                height: 40,
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                child: TextView(text: 'test',style: AppTextTheme.textTheme16Bold,),
              )
            ],
          ),
        );
      },
    );
  }
}
