import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/PrescriptionModel.dart';
import 'package:mumbaiclinic/repository/medicine_repo.dart';
import 'package:mumbaiclinic/screen/view_prescription_screen.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class MyPrescriptionScreen extends StatefulWidget {
  @override
  _MyPrescriptionScreenState createState() => _MyPrescriptionScreenState();
}

class _MyPrescriptionScreenState extends State<MyPrescriptionScreen> {
  final medicineRepo = MedicineRepo();
  List<Prescription> _prescriptions = [];
  String message = '';
  @override
  void initState() {
    super.initState();
    _getPrescription();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar('My Prescriptions'),
      body: CustomScrollView(
        slivers: [
          if (_prescriptions.length == 0)
            SliverFillRemaining(
              child: Center(
                child: AppText.getErrorText('$message', 16),
              ),
            ),
          SliverList(
              delegate: SliverChildListDelegate(
            _prescriptions
                .map((e) => Container(
                      decoration: BoxDecoration(
                        color: ColorTheme.lightGreenOpacity,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              AppText.getBoldText(
                                  e.doctorName, 14, ColorTheme.darkGreen),
                              Expanded(
                                  child: Container(
                                alignment: Alignment.centerRight,
                                child: AppText.getLightText(
                                    Utils.getReadableDateTime(
                                        e.appointmentDate),
                                    14,
                                    ColorTheme.darkGreen),
                              ))
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(CupertinoPageRoute(
                                    builder: (_) => ViewPrescriptionScreen(
                                        e.prescriptionPath)));
                              },
                              style: ElevatedButton.styleFrom(
                                primary: ColorTheme.buttonColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6)),
                              ),
                              child: AppText.getRegularText(
                                  'View', 14, ColorTheme.white),
                            ),
                          )
                        ],
                      ),
                    ))
                .toList(),
          ))
        ],
      ),
    );
  }

  _getPrescription() async {
    Loader.showProgress();
    final response =
        await medicineRepo.getPrescription(PreferenceManager.getUserId());
    Loader.hide();

    if (response != null) {
      _prescriptions = response.prescriptions;
      if (_prescriptions.length == 0) {
        message = 'No Data';
      }
    }
    setState(() {});
  }
}
