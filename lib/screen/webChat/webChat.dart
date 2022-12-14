import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/screen/home/home_screen.dart';
import 'package:mumbaiclinic/screen/termscondition/mumbai_web_view.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';

class WebChat extends StatefulWidget {
  String title, url, appointmentId;
  bool isVideo;

  WebChat(this.title, this.url, this.appointmentId, {this.isVideo = false});
  @override
  _WebChatState createState() => _WebChatState();
}

class _WebChatState extends State<WebChat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          widget.title,
          style: Theme.of(context).appBarTheme.textTheme.headline1,
        ),
        leading: IconButton(
          onPressed: () {
            widget.isVideo
                ? Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen()))
                : Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
          ),
        ),
        actions: [
          widget.appointmentId.isNotEmpty
              ? Container(
                  margin: EdgeInsets.only(right: 10.0),
                  child: Center(
                    child: AppText.getBoldText(
                        'Appointemnt ID: ${widget.appointmentId}',
                        16.0,
                        ColorTheme.darkGreen),
                  ),
                )
              : SizedBox(),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: MumbaiWebView(
            actionBar: false,
            url: widget.url,
          ),
        ),
      ]),
    );
  }
}
