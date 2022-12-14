import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart' as rtc;
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/main.dart';
import 'package:mumbaiclinic/screen/video_call/video_call_screen.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';

enum ResponseType {
  answer,
  decline,
}

class PickUpScreen extends StatefulWidget {
  bool fromForeground = false;
  final String doctorName;
  final String appointmentID;
  final String imageUrl;
  PickUpScreen(
      {Key key,
      this.fromForeground,
      this.doctorName,
      this.appointmentID,
      this.imageUrl})
      : super(key: key);

  @override
  _PickUpScreenState createState() => _PickUpScreenState();
}

class _PickUpScreenState extends State<PickUpScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.fromForeground) FlutterRingtonePlayer.playRingtone();
  }

  @override
  void dispose() {
    FlutterRingtonePlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100.0),
            CircleAvatar(
              backgroundImage: NetworkImage(widget.imageUrl),
              radius: 40.0,
            ),
            const SizedBox(
              height: 20.0,
            ),
            AppText.getBoldText(
              widget.doctorName,
              20.0,
              Colors.black,
            ),
            AppText.getRegularText(
              'Video Consulting',
              15.0,
              Colors.black,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    button(type: ResponseType.answer),
                    button(type: ResponseType.decline),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget button({ResponseType type}) {
    return GestureDetector(
      onTap: () {
        FlutterRingtonePlayer.stop();
        if (type == ResponseType.answer) {
          Utils.log("Answer AppointmentId: ${widget.appointmentID}");
          Navigator.pushNamedAndRemoveUntil(
            context,
            VideoCallScreen.routeName,
            (route) => false,
            arguments: {
              "appointment_id": widget.appointmentID,
              "role": rtc.ClientRole.Broadcaster,
            },
            // arguments: ScreenArguments(
            //   appointment_id: widget.appointmentID,
            //   role: rtc.ClientRole.Broadcaster,
            // ),
          );
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        height: 60.0,
        width: 60.0,
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color:
              type == ResponseType.answer ? Colors.green : ColorTheme.darkRed,
        ),
        child: Icon(
          type == ResponseType.answer ? Icons.videocam : Icons.call_end,
          color: ColorTheme.white,
        ),
      ),
    );
  }
}
