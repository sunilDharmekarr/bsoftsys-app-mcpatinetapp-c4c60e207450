import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  final bool needAppBar;
  HelpSupportScreen({this.needAppBar=true});
  @override
  _HelpSupportScreenState createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
    String email, contact;

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void dispose(){
    Loader.hide();
    super.dispose();
  }

  Future getData() async {
    Loader.showProgress();
    await MumbaiClinicNetworkCall.getRequest(
        endPoint: APIConfig.contactUs,
        context: context,
        header: Utils.getHeaders(),
        onSuccess: (response) {
          ResponseModel responseModel =
              ResponseModel.fromJson(json.decode(response));
          if (responseModel.success == 'true') {
            setState(() {
              email = json.decode(response)['payload'][0]['email'];
              contact = json.decode(response)['payload'][0]['phone'];
            });
          } else {
            Utils.showToast(message: 'Something went wrong!');
          }
        },
        onError: (error) {
          Utils.showToast(message: error.toString(), isError: true);
        },);
        Loader.hide();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:widget.needAppBar? AppBar(
        centerTitle: false,
        title: Text(
          'Help & Support',
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
      ):null,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: <Widget>[
                // Padding(
                //   padding: const EdgeInsets.all(20),
                //   child: TextView(
                //     text:
                //         'Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book',
                //     maxLine: 5,
                //     overflow: TextOverflow.ellipsis,
                //     textAlign: TextAlign.justify,
                //     style: AppTextTheme.textTheme12Light,
                //   ),
                // ),
                const SizedBox(
                  height: 10,
                ),
                // Container(
                //   margin: const EdgeInsets.symmetric(horizontal: 20),
                //   color: ColorTheme.darkGreen.withOpacity(0.1),
                //   height: 4,
                // ),
                const SizedBox(
                  height: 20,
                ),
                TextView(
                  text: email,
                  maxLine: 5,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                  style: AppTextTheme.textTheme14Light,
                ),

                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 40,vertical: 6),
                  child: AppButton(
                    text: 'Send Email',
                    onClick: () {
                      _sendEmail(email);
                    },
                    style: AppTextTheme.textTheme14Bold,
                    color: ColorTheme.lightGreen,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextView(
                  text: contact,
                  maxLine: 5,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.justify,
                  style: AppTextTheme.textTheme12Light,
                ),
                Container(
                  width: double.infinity,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 40,vertical: 6),
                  child: AppButton(
                    text: 'Contact',
                    onClick: () {
                      _makePhoneCall('tel:$contact');
                    },
                    style: AppTextTheme.textTheme14Bold,
                    color: ColorTheme.lightGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _sendEmail(String email) async {
    final url = 'mailto:$email?subject=Support';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
