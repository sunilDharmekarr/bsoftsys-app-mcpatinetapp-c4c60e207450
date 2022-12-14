import 'package:flutter/material.dart';
import 'package:mumbaiclinic/screen/helpsupport/help_support_screen.dart';

class ConsultNowFragment extends StatefulWidget {
  @override
  _ConsultNowFragmentState createState() => _ConsultNowFragmentState();
}

class _ConsultNowFragmentState extends State<ConsultNowFragment> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: HelpSupportScreen(needAppBar: false,),
    );
  }
}
