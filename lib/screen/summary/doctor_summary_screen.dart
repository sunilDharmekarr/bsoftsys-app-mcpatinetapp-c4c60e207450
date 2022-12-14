import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/chat_model.dart';
import 'package:mumbaiclinic/model/doc_by_specialization.dart';
import 'package:mumbaiclinic/model/question_answers_model.dart';
import 'package:mumbaiclinic/model/symptom_model.dart';
import 'package:mumbaiclinic/repository/image_upload_repo.dart';
import 'package:mumbaiclinic/screen/myappointment/my_appointment_screen.dart';
import 'package:mumbaiclinic/services/address_service.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/bottomsheet/both_chat.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';
import 'package:mumbaiclinic/screen/summary/patient_summary.dart';
import 'package:mumbaiclinic/screen/chat/chat_screen.dart';

class DoctorSummaryScreen extends StatefulWidget {
  final Doctor doctor;
  final List<Symptom> symptomId;

  DoctorSummaryScreen(this.doctor, this.symptomId);

  @override
  _DoctorSummaryScreenState createState() => _DoctorSummaryScreenState();
}

class _DoctorSummaryScreenState extends State<DoctorSummaryScreen>
    with TickerProviderStateMixin {
  TabController _tabController;

  List<QuestionAnswer> _questionAns = [];
  List<ChatModel> _chatModel = [];
  int currentIndex = 0;
  String token = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    getAppointmentQuestionsWithAnswers();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/home', (Route<dynamic> route) => false);
        });
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorTheme.lightGreenOpacity,
          leading: IconButton(
            onPressed: () {
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home', (Route<dynamic> route) => false);
              });
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).primaryColor,
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextView(
                  text: getAddress(),
                  style: TextStyle(
                      fontSize: AppTextTheme.textSize14,
                      color: ColorTheme.darkGreen,
                      fontFamily: TextFont.poppinsLight),
                ),
                Image.asset(
                  AppAssets.location,
                  width: 24,
                  height: 24,
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      color: ColorTheme.lightGreenOpacity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 2),
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: 80,
                            width: 80,
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                fit: BoxFit.fill,
                                image: NetworkImage(
                                  '${widget.doctor.photopath}',
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  TextView(
                                    text: widget.doctor.name,
                                    style: AppTextTheme.textTheme14Bold,
                                  ),
                                  TextView(
                                    text: widget.doctor.specializationName +
                                        '/' +
                                        widget.doctor.qualification,
                                    style: AppTextTheme.textTheme10Light,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      color: ColorTheme.lightGreenOpacity,
                      height: 36,
                      child: TabBar(
                        controller: _tabController,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 0),
                        isScrollable: false,
                        unselectedLabelColor: ColorTheme.darkGreen,
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: ColorTheme.lightGreenOpacity,
                        indicator: BoxDecoration(
                          color: ColorTheme.buttonColor,
                        ),
                        onTap: (index) {
                          currentIndex = 1;
                          setState(() {});
                        },
                        tabs: ['Chat', 'Summary']
                            .map((e) => Tab(
                                  child: Container(
                                    height: 36,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          width: 0.5,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        e,
                                        maxLines: 1,
                                        textScaleFactor: 1.0,
                                        style: TextStyle(
                                          fontSize: AppTextTheme.textSize12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          TabBarView(
                            physics: NeverScrollableScrollPhysics(),
                            controller: _tabController,
                            children: [
                              ChatScreen(
                                  _chatModel, widget.doctor, UniqueKey()),
                              PatientSummary(
                                symptom: widget.symptomId,
                                chatModel: _chatModel,
                                questionAns: _questionAns,
                              )
                            ],
                          ),
                          Positioned(
                            child: GestureDetector(
                              onTap: () {
                                Utils.showAppointmentSuccessDialog(
                                  context,
                                  PreferenceManager.getAppoint,
                                  () {
                                    // MyApplication.navigateAndClear('/home');
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MyAppointmentScreen()),
                                        (route) => false);
                                  },
                                );
                              },
                              child: Card(
                                elevation: 8,
                                color: ColorTheme.buttonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: AppText.getRegularText(
                                      'Skip', 14, ColorTheme.white),
                                ),
                              ),
                            ),
                            top: 8,
                            right: 10,
                          ),
                        ],
                      ),
                    ),
                    if (home)
                      GestureDetector(
                        onTap: () {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/home', (Route<dynamic> route) => false);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          color: ColorTheme.darkGreen,
                          child: Center(
                            child: TextView(
                              text: 'Home',
                              color: ColorTheme.white,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ColorTheme.white,
                                fontSize: AppTextTheme.textSize16,
                              ),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  getAppointmentQuestionsWithAnswers() async {
    List<String> ids = [];

    widget.symptomId.forEach((element) {
      ids.add(element.symptomId.toString());
    });

    Map<String, String> body = {
      "symptom_id": ids.join(','),
      "appointment_id": PreferenceManager.getappointment_id.toString(),
    };
    // EasyLoading.show(status: '',indicator: CircularProgressIndicator());
    Loader.showProgress();
    await MumbaiClinicNetworkCall.postRequest(
      endPoint: APIConfig.getAppointmentQuestionsWithAnswers,
      header: Utils.getHeaders(token: token),
      body: body,
      onSuccess: (response) {
        //EasyLoading.dismiss();
        Loader.hide();
        if (response != null) {
          final model = questionAnswersModelFromJson(response);
          if (model.success == 'true') {
            _questionAns.clear();
            _questionAns.addAll(model.questionAnswers);
            _startChat();
          } else {
            Utils.showToast(
                message: 'Failed to load questionaire: ${model.error}',
                isError: true);
          }
        } else {
          Utils.showToast(
              message: 'Failed to load questionaire', isError: true);
        }
      },
      onError: (error) {
        // EasyLoading.dismiss();
        Loader.hide();
        Utils.showToast(
            message: 'Failed to load questionaire: $error', isError: true);
      },
    );
  }

  _startChat() async {
    if (_questionAns.length > 0) {
      if (currentIndex == _questionAns.length) {
        Future.delayed(Duration(seconds: 1), _navigate);
      } else {
        QuestionAnswer data = _questionAns[currentIndex];
        _chatModel.add(ChatModel(
          symptomId: data.symptomId,
          questionId: data.questionNo,
          questionText: data.question,
          attType: data.attType,
        ));
        Future.delayed(Duration(seconds: 4), _start);
      }
    } else {
      Utils.showAppointmentSuccessDialog(
        context,
        PreferenceManager.getAppoint,
        () {
          MyApplication.navigateAndClear('/home');
        },
      );
    }
    setState(() {});
  }

  bool home = false;
  final ImageUploadRepo imageUploadRepo = ImageUploadRepo();

  _navigate() {
    setState(() {
      currentIndex = 1;
      _tabController.index = currentIndex;
    });
  }

  _start() {
    showChatBot(_questionAns[currentIndex]);
  }

  showChatBot(question) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (cnx) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: BotChat(
            onAction: (ChatModel model) {
              _chatModel[currentIndex] = model;
              currentIndex = currentIndex + 1;
              _addAppointmentQuestionAnswer(model);
              _startChat();
            },
            questionAnswer: question,
          ),
        );
      },
    );
  }

  _addAppointmentQuestionAnswer(ChatModel model) async {
    ChatModel bodyModel;
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
          attchment: profileImage,
        );
        _submit(bodyModel);
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
        attchment: '',
      );
      print("Body Model: ${bodyModel.attType}");
      _submit(bodyModel);
    }
  }

  _submit(ChatModel bodyModel) async {
    await MumbaiClinicNetworkCall.postRequest(
      endPoint: APIConfig.addAppointmentQuestionAnswer,
      header: Utils.getHeaders(),
      encoded: true,
      body: bodyModel.toJson(),
      onSuccess: (_) {},
      onError: (error) {},
    );
  }

  String getAddress() {
    final addressService = AddressService.instance;
    final data = addressService.place;
    if (data != null) {
      return data.administrativeArea + '-' + data.locality;
    }
    return 'Loading..';
  }
}
