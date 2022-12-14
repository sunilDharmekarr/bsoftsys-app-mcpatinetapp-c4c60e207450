import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/doc_by_specialization.dart';
import 'package:mumbaiclinic/model/symptom_model.dart';
import 'package:mumbaiclinic/screen/summary/doctor_summary_screen.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/bottomsheet/skip_chat_sheet.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/search_view.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class SymptomScreen extends StatefulWidget {
  final Doctor doctor;

  SymptomScreen(this.doctor);

  @override
  _SymptomScreenState createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  final _controller = TextEditingController();

  List<Symptom> _symptoms = [];
  List<Symptom> _filterList = [];
  List<Symptom> selectedIds = [];

  @override
  void initState() {
    super.initState();
    _getSymptomsBySpecialisation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            'Select Symptoms',
            style: Theme.of(context).appBarTheme.textTheme.headline1,
          ),
          leading: IconButton(
            onPressed: () {
              // Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).primaryColor,
            ),
          )),
      body: Column(
        children: [
          SearchView(
            controller: _controller,
            hint: 'Search Symptoms',
            onSubmit: (searchKey) {
              FocusScope.of(context).unfocus();
              print(searchKey);
              _onSearch(searchKey);
            },
            onChange: (key) {
              _onSearch(key);
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: (_filterList.length == 0 && selectedIds.length == 0)
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText.getErrorText('No Symptom Available', 16),
                        TextButton(
                            onPressed: () {
                              Future.delayed(Duration(milliseconds: 200),
                                  _showSkipSheet());
                            },
                            child: AppText.getBoldText(
                                'DONE', 14, ColorTheme.darkGreen))
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 2,
                      children: _filterList
                          .map((e) => GestureDetector(
                                onTap: () {
                                  if (selectedIds.contains(e)) {
                                    selectedIds.remove(e);
                                  } else {
                                    selectedIds.add(e);
                                  }
                                  setState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: selectedIds.contains(e)
                                        ? ColorTheme.buttonColor
                                        : ColorTheme.lightGreenOpacity,
                                  ),
                                  child: Center(
                                    child: TextView(
                                      text: e.symptom,
                                      maxLine: 2,
                                      textAlign: TextAlign.center,
                                      color: selectedIds.contains(e)
                                          ? ColorTheme.white
                                          : ColorTheme.darkGreen,
                                      style: AppTextTheme.textTheme12Light,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
          ),
          if (selectedIds.length > 0)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) =>
                        DoctorSummaryScreen(widget.doctor, selectedIds),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.all(14),
                width: double.infinity,
                height: 44,
                decoration: BoxDecoration(
                  color: ColorTheme.buttonColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: Utils.getShadow(shadow: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Center(
                    child: TextView(
                      text: 'Next',
                      color: Colors.white,
                      style: AppTextTheme.textTheme14Bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  _showSkipSheet() {
    Utils.showAppointmentSuccessDialog(
      context,
      PreferenceManager.getAppoint,
      () {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        });
      },
    );
  }

  _onSearch(String key) {
    _filterList.clear();
    _symptoms.forEach((element) {
      if (element.symptom.toLowerCase().contains(key.trim().toLowerCase())) {
        _filterList.add(element);
      }
    });

    if (key.length == 0) {
      _filterList.clear();
      _filterList.addAll(_symptoms);
    }
    setState(() {});
  }

  _getSymptomsBySpecialisation() async {
    final token = PreferenceManager.getToken();
    Map<String, String> body = {
      "specialization_id": PreferenceManager.specializationId.toString(),
    };
    // EasyLoading.show(status: '',indicator: CircularProgressIndicator());
    Loader.showProgress();
    await MumbaiClinicNetworkCall.postRequest(
      endPoint: APIConfig.GetSymptomsBySpecialisation,
      header: Utils.getHeaders(token: token),
      body: body,
      onSuccess: (response) {
        //EasyLoading.dismiss();
        Loader.hide();
        if (response != null) {
          final model = symptomModelFromJson(response);
          if (model.success == 'true') {
            _symptoms.clear();
            _symptoms.addAll(model.symptom);
            _filterList.clear();
            _filterList.addAll(model.symptom);
          } else {
            Utils.showToast(
                message: 'Failed to load symptoms: ${model.error}',
                isError: true);
          }
        } else {
          Utils.showToast(message: 'Failed to load symptoms', isError: true);
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      },
      onError: (error) {
        Loader.hide();
        Utils.showToast(
            message: 'Failed to load symptoms: $error', isError: true);
      },
    );
  }
}
