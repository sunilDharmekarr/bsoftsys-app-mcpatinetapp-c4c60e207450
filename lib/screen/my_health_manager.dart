import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/MyHealthModel.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/repository/patient_repo.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:url_launcher/url_launcher.dart';

class MyHealthManagerScreen extends StatefulWidget {
  @override
  _MyHealthManagerScreenState createState() => _MyHealthManagerScreenState();
}

class _MyHealthManagerScreenState extends State<MyHealthManagerScreen> {
  String username = '';
  String mobile = '';
  String email = '';
  String profile = '';

  @override
  void initState() {
    super.initState();
   // loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar('My Health Manager'),
      body: Container(
        margin: const EdgeInsets.all(10),
        color: Colors.white,
        child:Container(
          child: FutureBuilder(
            future: _patientRepo.getHealthManagerDetails(PreferenceManager.getUserId()),
            key: PageStorageKey("health"),
            builder: (contex,AsyncSnapshot<MyHealthModel> snapshot){
             if(snapshot.hasData){

               if(snapshot.data.health.length>0){
                 final health = snapshot.data.health[0];
                 return  Container(
                   padding: const EdgeInsets.all(10),
                   color: ColorTheme.lightGreenOpacity,
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.start,
                         crossAxisAlignment: CrossAxisAlignment.center,
                         children: <Widget>[
                           Expanded(
                               child:AppText.getBoldText('${health.name}', 14 , ColorTheme.darkGreen)
                           ),
                           Container(
                             width: 70,
                             height: 70,
                             child: ClipRRect(
                               borderRadius: BorderRadius.circular(35),
                               child: health.profilePhoto.isNotEmpty
                                   ? Image.network(
                                 health.profilePhoto,
                                 fit: BoxFit.contain,
                                 headers: Utils.getHeaders(),
                               )
                                   : Container(),
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 10,),
                       Row(
                         children: [
                           Container(
                             child: AppText.getRegularText('Email : ', 14, ColorTheme.darkGreen),
                           ),Expanded(child: AppText.getBoldText('${health.email}', 14, ColorTheme.darkGreen),),
                           IconButton(icon: Icon(Icons.email), onPressed: (){
                             _sendEmail('${health.email}');
                           },color: ColorTheme.iconColor  ,)
                         ],
                       ),
                       const SizedBox(height: 20,),
                       Row(
                         children: [
                           Container(
                             child: AppText.getRegularText('Mobile : ', 14, ColorTheme.darkGreen),
                           ),Expanded(child: AppText.getBoldText('${health.mobile}', 14, ColorTheme.darkGreen),),
                           IconButton(icon: Icon(Icons.phone), onPressed: (){
                             _makePhoneCall('tel:${health.mobile}');
                           },color: ColorTheme.iconColor  ,)
                         ],
                       ),
                       const SizedBox(height: 20,),
                       Row(
                         children: [
                           Container(
                             child: AppText.getRegularText('Office Number : ', 14, ColorTheme.darkGreen),
                           ),
                           Expanded(child: AppText.getBoldText('${health.officeNumber}', 14, ColorTheme.darkGreen),),
                           IconButton(icon: Icon(Icons.phone), onPressed: (){
                             _makePhoneCall('tel:${health.officeNumber}');
                           },color: ColorTheme.iconColor  ,)
                         ],
                       ),
                     ],
                   ),
                 );
               }

               else
                 return Center(child: AppText.getErrorText('No data.'.toString(), 16),);
             }
             else if(snapshot.hasError){
                return Center(child: AppText.getErrorText(snapshot.error.toString(), 16),);
              }else{
               return Center(child: CircularProgressIndicator(),);
             }
            },
          ),
        )
      ),
    );
  }

 /* void loadData() async {
    final userId = PreferenceManager.getUserId();
    final userData = await AppDatabase.db.getUser(userId) as Datum;
    username = userData.fullName;
    email = userData.email??'-';
    mobile = userData.mobile??'';
    profile = userData.profile_pic;
    setState(() {});



  }*/

  final PatientRepo _patientRepo = PatientRepo();

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
