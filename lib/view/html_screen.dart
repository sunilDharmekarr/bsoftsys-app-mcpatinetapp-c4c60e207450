import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/model/call_back_model.dart';
import 'package:mumbaiclinic/repository/call_back_repo.dart';
import 'package:mumbaiclinic/screen/termscondition/mumbai_web_view.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';
import 'package:url_launcher/url_launcher.dart';

enum CallBackType {
  AdultImmunization,
  HomeCare,
  Packages,
  COVIDConcierge,
  PlanSurgery,
  VIPConcierge,
  immunization,
  GeneralEnquiry,
}

class HtmlScreen extends StatefulWidget {
  final CallBackType callBackType;
  final String url;
  final String title;
  final String buttonText;
  final bool visible;
  HtmlScreen(
      {@required this.callBackType,
      this.url,
      this.title,
      this.buttonText,
      this.visible = true});

  @override
  _HtmlScreenState createState() => _HtmlScreenState();
}

class _HtmlScreenState extends State<HtmlScreen> {
  final callbackRepo = CallBackRepo();
  Callback _callback;

  @override
  void initState() {
    super.initState();
    _getCallBack();
  }

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
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
          ),
        ),
        actions: [
          (widget.url.contains('vip'.toLowerCase()))
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FloatingActionButton(
                    onPressed: () => _launchInBrowser(
                        'http://www.thegrandconciergehealthcare.com/'),
                    backgroundColor: ColorTheme.buttonColor,
                    child: Text(
                      'Know more',
                      style: TextStyle(fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                    isExtended: true,
                    mini: false,
                  ),
                )
              : SizedBox(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MumbaiWebView(
              actionBar: false,
              url: widget.url,
            ),
          ),
          if (widget.visible)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              child: Container(
                width: double.infinity,
                height: 44,
                child: AppButton(
                  text: 'Request Call Back',
                  onClick: () {
                    if (_callback != null) _call(_callback.callbackTypeId);
                  },
                  style: AppTextTheme.textTheme12Regular,
                  color: ColorTheme.buttonColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  _getCallBack() async {
    final response = await callbackRepo.getCallBackType();
    switch (widget.callBackType) {
      case CallBackType.HomeCare:
        _callback = response.callback
            .firstWhere((element) => element.callbackType == 'Home Care');
        break;
      case CallBackType.VIPConcierge:
        _callback = response.callback
            .firstWhere((element) => element.callbackType == 'VIP Concierge');
        break;
      case CallBackType.PlanSurgery:
        _callback = response.callback
            .firstWhere((element) => element.callbackType == 'Plan a Surgery');
        break;
      case CallBackType.immunization:
        _callback = response.callback
            .firstWhere((element) => element.callbackType == 'Home Care');
        break;
      case CallBackType.GeneralEnquiry:
      default:
        _callback = response.callback
            .firstWhere((element) => element.callbackType == 'General Enquiry');
        break;
    }
  }

  _call(id) async {
    Loader.showProgress();
    final response = await callbackRepo.logCallBack(id.toString());
    Loader.hide();
    if (response != null) {
      Utils.showSingleButtonAlertDialog(
          context: context,
          message: '${Utils.fixNewLines(response)}',
          onClick: () => Navigator.of(context).pop());
    }
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
