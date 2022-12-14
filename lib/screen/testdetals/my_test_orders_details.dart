import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/model/MyTestModel.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';

class MyTestOrdersDetailScreen extends StatefulWidget {
  final Payload  _payload;

  MyTestOrdersDetailScreen(this._payload);

  @override
  _MyTestOrdersDetailScreenState createState() => _MyTestOrdersDetailScreenState();
}

class _MyTestOrdersDetailScreenState extends State<MyTestOrdersDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        centerTitle: true,
        title: Text(
          'Test Order Details',
          style: Theme.of(context).appBarTheme.textTheme.headline1,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(10),
        child: Container(
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Container(
               alignment: Alignment.center,
               padding: const EdgeInsets.all(14),
               decoration: BoxDecoration(
                 color: ColorTheme.buttonColor,
                 borderRadius: BorderRadius.only(topLeft: Radius.circular(8),topRight: Radius.circular(8),)
               ),
               child: AppText.getBoldText('${widget._payload.invoiceNumber}', 20, ColorTheme.white),
             ),
             Container(
               width: double.infinity,
               color: ColorTheme.lightGreenOpacity,
               child: ListView(
                 shrinkWrap: true,
                 physics: NeverScrollableScrollPhysics(),
                 children: widget._payload.tests.map<Widget>((e) => Container(
                   padding: const EdgeInsets.all(12),
                   color: ColorTheme.lightGreenOpacity,
                   child: AppText.getRegularText('${e.testName} : ${e.status}', 16, ColorTheme.darkGreen),
                 ),
                 ).toList(),
               )
             ),
             Container(
               alignment: Alignment.center,
               padding: const EdgeInsets.all(14),
               decoration: BoxDecoration(
                   color: ColorTheme.buttonColor,
                   borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8),bottomRight: Radius.circular(8),)
               ),
               child:Row(
                 children: [
                   Expanded(child: AppText.getBoldText('Total Amount', 16, ColorTheme.white),),
                   Container(child: AppText.getBoldText('Rs.${widget._payload.amountPaid}', 16, ColorTheme.white),)
                 ],
               )
             ),
           ],
         ),
        ),
      ),
    );
  }
}
