import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/chat_model.dart';
import 'package:mumbaiclinic/model/question_answers_model.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/model/symptom_model.dart';
import 'package:mumbaiclinic/repository/image_upload_repo.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/bottomsheet/both_chat.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class PatientSummary extends StatefulWidget {
  final List<Symptom> symptom;
  final List<ChatModel> chatModel;
  final List<QuestionAnswer> questionAns;

  PatientSummary({this.symptom, this.chatModel, this.questionAns});

  @override
  _PatientSummaryState createState() => _PatientSummaryState();
}

class _PatientSummaryState extends State<PatientSummary> {
  int counter = 1;
  String fname = '';

  @override
  void initState() {
    super.initState();
    counter = 1;
    loadData();
  }

  loadData() async {
    Datum user = await AppDatabase.db.getUser(PreferenceManager.getUserId());
    fname = user.fullName;
  }

  @override
  Widget build(BuildContext context) {
    counter = 1;
    var sym = '';
    var des = '';
    widget.symptom.forEach((element) {
      sym += element.symptom + ',';
      des += element.sympDescription + '\n';
    });
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextView(
            text: fname,
            style: AppTextTheme.textTheme16Bold,
          ),
          TextView(
            text: sym,
            style: AppTextTheme.textTheme14Light,
          ),
          const SizedBox(
            height: 10,
          ),
          TextView(
            text: des,
            textAlign: TextAlign.justify,
            style: AppTextTheme.textTheme12Light,
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (_, index) {
              return Container(
                color: ColorTheme.lightGreenOpacity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextView(
                      text:
                          '${(counter++)} : ${widget.chatModel[index].questionText}',
                      color: ColorTheme.darkGreen,
                      style: TextStyle(fontSize: AppTextTheme.textSize14),
                    ),
                    Column(
                      children: [
                        if (widget.chatModel[index].attchment != null &&
                            widget.chatModel[index].attchment.isNotEmpty)
                          Container(
                            height: 120,
                            width: 120,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                File(widget.chatModel[index].attchment),
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: TextView(
                                text:
                                    'Ans: ${widget.chatModel[index].answerText}',
                                color: ColorTheme.buttonColor,
                                style: TextStyle(
                                    fontSize: AppTextTheme.textSize14),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (cnx) {
                                    return Padding(
                                      padding: MediaQuery.of(cnx).viewInsets,
                                      child: BotChat(
                                        onAction: (ChatModel model) {
                                          widget.chatModel[index] = model;
                                          _submit(widget.chatModel[index]);
                                          setState(() {});
                                        },
                                        questionAnswer: getQuestion(
                                            widget.chatModel[index].questionId),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: ColorTheme.buttonColor,
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      AppAssets.edit,
                                      width: 14,
                                      height: 14,
                                    ),
                                    TextView(
                                      text: 'Edit',
                                      color: ColorTheme.white,
                                      style: AppTextTheme.textTheme10Light,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              );
            },
            itemCount: widget.chatModel.length,
          )),
          Container(
            width: double.infinity,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: ElevatedButton(
              child: TextView(
                text: "Submit",
                style: AppTextTheme.textTheme12Regular,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                primary: ColorTheme.buttonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Utils.showAppointmentSuccessDialog(
                  context,
                  PreferenceManager.getAppoint,
                  () {
                    MyApplication.navigateAndClear('/home');
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }

  QuestionAnswer getQuestion(int id) {
    return widget.questionAns.firstWhere((element) => element.questionNo == id);
  }

  final ImageUploadRepo imageUploadRepo = ImageUploadRepo();

  _submit(ChatModel model) async {
    ChatModel bodyModel;
    Loader.showProgress();
    if (model.attchment != null && model.attchment.isNotEmpty) {
      final profileImage = await imageUploadRepo.uploadQAImage(
          model.attchment,
          PreferenceManager.getappointment_id.toString(),
          model.questionId.toString(),
          model.attType.toString());
      if (profileImage != null) {
        bodyModel = ChatModel(
          patid: int.parse(PreferenceManager.getUserId()),
          speciliazationId: PreferenceManager.specializationId,
          symptomId: model.symptomId,
          appointmentId: PreferenceManager.getappointment_id,
          questionId: model.questionId,
          answerText: model.answerText,
          answerId: model.answerId ?? '',
          questionText: model.questionText ?? '',
          attType: model.attType ?? '',
          attchment: profileImage,
        );
        _update(bodyModel);
      }
    } else {
      bodyModel = ChatModel(
        patid: int.parse(PreferenceManager.getUserId()),
        speciliazationId: PreferenceManager.specializationId,
        symptomId: model.symptomId,
        appointmentId: PreferenceManager.getappointment_id,
        questionId: model.questionId,
        answerText: model.answerText,
        answerId: model.answerId ?? '',
        questionText: model.questionText ?? '',
        attType: model.attType ?? '',
        attchment: '',
      );
      _update(bodyModel);
    }
    Loader.hide();
  }

  _update(ChatModel bodyModel) async {
    await MumbaiClinicNetworkCall.postRequest(
      endPoint: APIConfig.addAppointmentQuestionAnswer,
      header: Utils.getHeaders(),
      encoded: true,
      body: bodyModel.toJson(),
      onSuccess: (_) {},
      onError: (error) {
        Utils.showToast(message: 'Update failed: $error', isError: true);
      },
    );
  }
}
