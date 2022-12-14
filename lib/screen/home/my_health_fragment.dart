import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/repository/patient_repo.dart';
import 'package:mumbaiclinic/screen/alert/alert_screen.dart';
import 'package:mumbaiclinic/screen/lab_parameters_screen.dart';
import 'package:mumbaiclinic/screen/emr/mediacal_emr_screen.dart';
import 'package:mumbaiclinic/screen/my_medicine_screen.dart';
import 'package:mumbaiclinic/screen/myappointment/my_appointment_screen.dart';
import 'package:mumbaiclinic/screen/register/user_form_screen.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/bottomsheet/family_members.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/dialog/select_member_dialog.dart';

import '../my_prescription_screen.dart';

class MyHealthFragment extends StatefulWidget {
  @override
  _MyHealthFragmentState createState() => _MyHealthFragmentState();
}

class _MyHealthFragmentState extends State<MyHealthFragment> {
  final patientRepo = PatientRepo();

  String username = '-';
  String gender = '-';
  String age = '-';
  var height = '-';
  var weight = '-';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Flexible(
                flex: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(6),
                      child: FittedBox(
                        child: Text(
                          'Hi $username ($gender/$age)',
                          textScaleFactor: 1.0,
                          style: AppTextTheme.textThemeNameLabel,
                        ),
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        'Height : $height cm  Weight : $weight Kg',
                        textScaleFactor: 1.0,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (ctx) {
                          return SelectMemberDialog(
                            selectionType: SelectionType.chooseMember,
                            onSelected: (_) {
                              loadData();
                            },
                          );
                        });
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Image.asset(
                              AppAssets.change_member,
                              width: 28,
                              height: 28,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          Text(
                            'Change Member',
                            textScaleFactor: 1.0,
                            style: AppTextTheme.textTheme12Light,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          getView(AppAssets.my_family, 'My Family', onclick: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (_) => FamilyMembers(() {
                          loadData();
                        })));
          }),
          getView(AppAssets.my_medicines, 'My Medicines', onclick: () {
            Navigator.push(context,
                CupertinoPageRoute(builder: (_) => MyMedicineScreen()));
          }),
          getView(AppAssets.my_precription, 'My Prescriptions', onclick: () {
            Navigator.push(context,
                CupertinoPageRoute(builder: (_) => MyPrescriptionScreen()));
          }),
          getView(AppAssets.my_medical_reports, 'My Medical Reports',
              onclick: () {
            Navigator.push(context,
                CupertinoPageRoute(builder: (_) => MedicalEMRScreen()));
          }),
          getView(AppAssets.my_appointments, 'My Appointments', onclick: () {
            Navigator.push(context,
                CupertinoPageRoute(builder: (_) => MyAppointmentScreen()));
          }),
          getView(AppAssets.lab_parameters, 'Blood Reports', onclick: () {
            Navigator.push(context,
                CupertinoPageRoute(builder: (_) => LabParameterScreen()));
          }),
          getView(AppAssets.alert_green, 'My Reminders', onclick: () {
            Navigator.push(
                context, CupertinoPageRoute(builder: (_) => MyAlertScreen()));
          }),
          getView(AppAssets.edit_profile, 'Edit Profile', onclick: () {
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (_) => UserFormScreen(
                      true,
                      pId: PreferenceManager.getUserId(),
                    )));
          }),
        ],
      ),
    );
  }

  loadData() async {
    final pid = PreferenceManager.getUserId();
    Datum model = await AppDatabase.db.getUser(pid);
    username = model.fullName;
    gender = model.sex.toUpperCase();
    var date = model.dob;
    age = Utils.getYears(date: date);
    height = model.height;
    weight = model.weight;
    setState(() {});
    // _getData();
  }

  Widget getView(String assets, String title, {Function onclick}) {
    return InkWell(
      onTap: () => onclick?.call(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: ColorTheme.lightGreenOpacity,
          borderRadius: BorderRadius.circular(10),
          boxShadow: Utils.getShadow(),
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 28,
              width: 28,
              child: Image.asset(
                assets,
                width: 30,
                height: 30,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: TextView(
                text: title,
                style: AppTextTheme.textTheme13Bold,
              ),
            ),
            SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child: Image.asset(
                  AppAssets.arrow_right,
                  width: 18,
                  height: 18,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _getData() async {
    final model = await patientRepo.getPatientLastVitals();

    if (model != null) {
      try {
        var data = model.vitalData[0];
        height = data['height'];
        weight = data['weight'];
        setState(() {});
      } catch (e) {
        print(e);
      }
    }
  }
}
