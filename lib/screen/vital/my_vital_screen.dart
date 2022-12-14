import 'package:audioplayer/audioplayer.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/model/BPModel.dart';
import 'package:mumbaiclinic/model/HeightModel.dart';
import 'package:mumbaiclinic/model/PulseModel.dart';
import 'package:mumbaiclinic/model/Spo2Model.dart';
import 'package:mumbaiclinic/model/TempModel.dart';
import 'package:mumbaiclinic/model/VitalIdModel.dart';
import 'package:mumbaiclinic/model/WeightModel.dart';
import 'package:mumbaiclinic/repository/message_repository.dart';
import 'package:mumbaiclinic/repository/patient_repo.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/chart/PointsLineChart.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

enum ViewType { weight, height, bmi, temperature, pluse, bp, spo, Sugar }

class MyVitalScreen extends StatefulWidget {
  @override
  _MyVitalScreenState createState() => _MyVitalScreenState();
}

class _MyVitalScreenState extends State<MyVitalScreen> {
  final patientRepo = PatientRepo();
  final _messageRepo = MessageRepository();

  VitalIdModel _idModel;
  List<dynamic> weightList = [];
  List<dynamic> heightList = [];
  List<dynamic> tempList = [];
  List<dynamic> bpList = [];
  List<dynamic> spoList = [];
  List<dynamic> pulseList = [];
  List<dynamic> sugar = [];
  List<dynamic> bmi = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    _idModel = await patientRepo.getVitals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'My Vitals',
          style: Theme.of(context).appBarTheme.textTheme.headline1,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AppText.getRegularText('Weight', 16, ColorTheme.darkGreen),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: ColorTheme.lightGreenOpacity,
                        ),
                        child: FutureBuilder(
                          future: patientRepo.getPatientWeightHistory(),
                          builder: (_, AsyncSnapshot<WeightModel> snapshot) {
                            if (snapshot.hasData) {
                              weightList = snapshot.data.weightData;

                              if (snapshot.data.weightData.length == 0)
                                return Center(
                                  child: AppText.getRegularText(
                                      'No Data', 14, Colors.grey),
                                );
                              else
                                return Container(
                                  child: ListView.separated(
                                      itemBuilder: (_, index) =>
                                          GestureDetector(
                                            child: Container(
                                              constraints: BoxConstraints(
                                                minWidth: 90,
                                              ),
                                              padding: EdgeInsets.all(4),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.only(top: 4),
                                                    child: AppText.getBoldText(
                                                        snapshot
                                                            .data
                                                            .weightData[index]
                                                            .weight
                                                            .toString(),
                                                        18,
                                                        ColorTheme.darkGreen),
                                                  ),
                                                  AppText.getLightText(
                                                      Utils.getReadableDate(
                                                          snapshot
                                                              .data
                                                              .weightData[index]
                                                              .date),
                                                      12,
                                                      ColorTheme.darkGreen,
                                                      maxLine: 2),
                                                  snapshot
                                                          .data
                                                          .weightData[index]
                                                          .comment
                                                          .isNotEmpty
                                                      ? AppText.getLightText(
                                                          '${snapshot.data.weightData[index].comment}',
                                                          12,
                                                          ColorTheme.darkGreen)
                                                      : SizedBox.shrink(),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              WeightDatum data = snapshot
                                                  .data.weightData[index];
                                              var type = "weight";
                                              _showDetailsDialog(
                                                  data.id,
                                                  _getVitalId(type),
                                                  type,
                                                  "kg",
                                                  data.comment,
                                                  data.date,
                                                  "${data.weight}");
                                            },
                                          ),
                                      separatorBuilder: (_, index) => Container(
                                            width: 1,
                                            color: Colors.grey,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 8),
                                          ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          snapshot.data.weightData.length),
                                );
                            } else if (snapshot.hasError)
                              return Center(
                                child: AppText.getRegularText(
                                    '${snapshot.error.toString()}',
                                    14,
                                    Colors.redAccent),
                              );
                            else
                              return Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                    getButtonView(() {
                      _showInputDialog('Add Weight', 'weight', 'in kg');
                    }, () {
                      if (weightList.length > 0)
                        _showDialog(weightList, ViewType.weight);
                    })
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AppText.getRegularText('Height', 16, ColorTheme.darkGreen),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: ColorTheme.lightGreenOpacity,
                        ),
                        child: FutureBuilder(
                          future: patientRepo.getPatientHeightHistory(),
                          builder: (_, AsyncSnapshot<HeightModel> snapshot) {
                            if (snapshot.hasData) {
                              heightList = snapshot.data.heightData;
                              if (snapshot.data.heightData.length == 0)
                                return Center(
                                  child: AppText.getRegularText(
                                      'No Data', 14, Colors.grey),
                                );
                              else
                                return Container(
                                  child: ListView.separated(
                                      itemBuilder: (_, index) =>
                                          GestureDetector(
                                            child: Container(
                                              constraints: BoxConstraints(
                                                minWidth: 90,
                                              ),
                                              padding: EdgeInsets.all(4),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 4),
                                                    child: AppText.getBoldText(
                                                        snapshot
                                                            .data
                                                            .heightData[index]
                                                            .height
                                                            .toString(),
                                                        18,
                                                        ColorTheme.darkGreen),
                                                  ),
                                                  AppText.getLightText(
                                                      Utils.getReadableDate(
                                                          snapshot
                                                              .data
                                                              .heightData[index]
                                                              .date),
                                                      12,
                                                      ColorTheme.darkGreen,
                                                      maxLine: 2),
                                                  snapshot
                                                          .data
                                                          .heightData[index]
                                                          .comment
                                                          .isNotEmpty
                                                      ? AppText.getLightText(
                                                          '${snapshot.data.heightData[index].comment}',
                                                          12,
                                                          ColorTheme.darkGreen)
                                                      : SizedBox.shrink(),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              HeightDatum data = snapshot
                                                  .data.heightData[index];
                                              var type = "height";
                                              _showDetailsDialog(
                                                  data.id,
                                                  _getVitalId(type),
                                                  type,
                                                  "cm",
                                                  data.comment,
                                                  data.date,
                                                  "${data.height}");
                                            },
                                          ),
                                      separatorBuilder: (_, index) => Container(
                                            width: 1,
                                            color: Colors.grey,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 15),
                                          ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          snapshot.data.heightData.length),
                                );
                            } else if (snapshot.hasError)
                              return Center(
                                child: AppText.getRegularText(
                                    '${snapshot.error.toString()}',
                                    14,
                                    Colors.redAccent),
                              );
                            else
                              return Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                    getButtonView(() {
                      _showInputDialog('Add Height', 'height', "in cm");
                    }, () {
                      if (heightList.length > 0)
                        _showDialog(heightList, ViewType.height);
                    })
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AppText.getRegularText('BMI', 16, ColorTheme.darkGreen),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: ColorTheme.lightGreenOpacity,
                        ),
                        child: FutureBuilder(
                          future: patientRepo.getPatientBMIHistory(),
                          builder: (_, AsyncSnapshot<HeightModel> snapshot) {
                            if (snapshot.hasData) {
                              bmi = snapshot.data.heightData;
                              if (snapshot.data.heightData.length == 0)
                                return Center(
                                  child: AppText.getRegularText(
                                      'No Data', 14, Colors.grey),
                                );
                              else
                                return Container(
                                  child: ListView.separated(
                                      itemBuilder: (_, index) => Container(
                                            constraints: BoxConstraints(
                                              minWidth: 90,
                                            ),
                                            padding: EdgeInsets.all(4),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 4),
                                                  child: AppText.getBoldText(
                                                      snapshot
                                                          .data
                                                          .heightData[index]
                                                          .height
                                                          .toString(),
                                                      18,
                                                      ColorTheme.darkGreen),
                                                ),
                                                AppText.getLightText(
                                                    Utils.getReadableDate(
                                                        snapshot
                                                            .data
                                                            .heightData[index]
                                                            .date),
                                                    12,
                                                    ColorTheme.darkGreen,
                                                    maxLine: 2),
                                                snapshot.data.heightData[index]
                                                        .comment.isNotEmpty
                                                    ? AppText.getLightText(
                                                        '${snapshot.data.heightData[index].comment}',
                                                        12,
                                                        ColorTheme.darkGreen)
                                                    : SizedBox.shrink(),
                                              ],
                                            ),
                                          ),
                                      separatorBuilder: (_, index) => Container(
                                            width: 1,
                                            color: Colors.grey,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 15),
                                          ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          snapshot.data.heightData.length),
                                );
                            } else if (snapshot.hasError)
                              return Center(
                                child: AppText.getRegularText(
                                    '${snapshot.error.toString()}',
                                    14,
                                    Colors.redAccent),
                              );
                            else
                              return Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                    getButtonView(() {
                      // _showInputDialog('Add Height','in cm','height');
                    }, () async {
                      //if(heightList.length>0)
                      _showDialog(bmi, ViewType.height);

                      if (bmi.length > 0) {
                        final message =
                            await _messageRepo.getPatientBMIMessage();
                        if (message != null) _showMessageDialog(message);
                      }
                    }, 'data')
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AppText.getRegularText(
                  'Temperature', 16, ColorTheme.darkGreen),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: ColorTheme.lightGreenOpacity,
                        ),
                        child: FutureBuilder(
                          future: patientRepo.getPatientTempHistory(),
                          builder: (_, AsyncSnapshot<TempModel> snapshot) {
                            if (snapshot.hasData) {
                              tempList = snapshot.data.tempData;
                              if (snapshot.data.tempData.length == 0)
                                return Center(
                                  child: AppText.getRegularText(
                                      'No Data', 14, Colors.grey),
                                );
                              else
                                return Container(
                                  child: ListView.separated(
                                      itemBuilder: (_, index) =>
                                          GestureDetector(
                                            child: Container(
                                              constraints: BoxConstraints(
                                                minWidth: 90,
                                              ),
                                              padding: EdgeInsets.all(4),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 4),
                                                    child: AppText.getBoldText(
                                                        snapshot
                                                            .data
                                                            .tempData[index]
                                                            .temp
                                                            .toString(),
                                                        18,
                                                        ColorTheme.darkGreen),
                                                  ),
                                                  AppText.getLightText(
                                                      Utils.getReadableDate(
                                                          snapshot
                                                              .data
                                                              .tempData[index]
                                                              .date),
                                                      12,
                                                      ColorTheme.darkGreen,
                                                      maxLine: 2),
                                                  snapshot.data.tempData[index]
                                                          .comment.isNotEmpty
                                                      ? AppText.getLightText(
                                                          '${snapshot.data.tempData[index].comment}',
                                                          12,
                                                          ColorTheme.darkGreen)
                                                      : SizedBox.shrink(),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              TempDatum data =
                                                  snapshot.data.tempData[index];
                                              var type = "temperature";
                                              _showDetailsDialog(
                                                  data.id,
                                                  _getVitalId(type),
                                                  type,
                                                  "Fahrenheit",
                                                  data.comment,
                                                  data.date,
                                                  "${data.temp}");
                                            },
                                          ),
                                      separatorBuilder: (_, index) => Container(
                                            width: 1,
                                            color: Colors.grey,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 15),
                                          ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data.tempData.length),
                                );
                            } else if (snapshot.hasError)
                              return Center(
                                child: AppText.getRegularText(
                                    '${snapshot.error.toString()}',
                                    14,
                                    Colors.redAccent),
                              );
                            else
                              return Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                    getButtonView(() {
                      _showInputDialog(
                          'Add Temperature', 'temperature', "in Fahrenheit");
                    }, () {
                      if (tempList.length > 0)
                        _showDialog(tempList, ViewType.temperature);
                    })
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AppText.getRegularText('Pulse', 16, ColorTheme.darkGreen),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: ColorTheme.lightGreenOpacity,
                        ),
                        child: FutureBuilder(
                          future: patientRepo.getPatientPulseHistory(),
                          builder: (_, AsyncSnapshot<PulseModel> snapshot) {
                            if (snapshot.hasData) {
                              pulseList = snapshot.data.pulseData;
                              if (snapshot.data.pulseData.length == 0)
                                return Center(
                                  child: AppText.getRegularText(
                                      'No Data', 14, Colors.grey),
                                );
                              else
                                return Container(
                                  child: ListView.separated(
                                      itemBuilder: (_, index) =>
                                          GestureDetector(
                                            child: Container(
                                              constraints: BoxConstraints(
                                                minWidth: 90,
                                              ),
                                              padding: EdgeInsets.all(4),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 4),
                                                    child: AppText.getBoldText(
                                                        snapshot
                                                            .data
                                                            .pulseData[index]
                                                            .pulse
                                                            .toString(),
                                                        18,
                                                        ColorTheme.darkGreen),
                                                  ),
                                                  AppText.getLightText(
                                                      Utils.getReadableDate(
                                                          snapshot
                                                              .data
                                                              .pulseData[index]
                                                              .date),
                                                      12,
                                                      ColorTheme.darkGreen,
                                                      maxLine: 2),
                                                  snapshot.data.pulseData[index]
                                                          .comment.isNotEmpty
                                                      ? AppText.getLightText(
                                                          '${snapshot.data.pulseData[index].comment}',
                                                          12,
                                                          ColorTheme.darkGreen)
                                                      : SizedBox.shrink(),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              PulseDatum data = snapshot
                                                  .data.pulseData[index];
                                              var type = "pulse";
                                              _showDetailsDialog(
                                                  data.id,
                                                  _getVitalId(type),
                                                  type,
                                                  "bpm",
                                                  data.comment,
                                                  data.date,
                                                  "${data.pulse}");
                                            },
                                          ),
                                      separatorBuilder: (_, index) => Container(
                                            width: 1,
                                            color: Colors.grey,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 15),
                                          ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          snapshot.data.pulseData.length),
                                );
                            } else if (snapshot.hasError)
                              return Center(
                                child: AppText.getRegularText(
                                    '${snapshot.error.toString()}',
                                    14,
                                    Colors.redAccent),
                              );
                            else
                              return Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                    getButtonView(() {
                      _showInputDialog('Add Pulse', 'pulse', "in bpm");
                    }, () async {
                      if (pulseList.length > 0)
                        _showDialog(pulseList, ViewType.pluse);

                      if (pulseList.length > 0) {
                        final message =
                            await _messageRepo.getPatientPulseMessage();
                        if (message != null) _showMessageDialog(message);
                      }
                    })
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AppText.getRegularText('BP', 16, ColorTheme.darkGreen),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: ColorTheme.lightGreenOpacity,
                        ),
                        child: FutureBuilder(
                          future: patientRepo.getPatientBPHistory(),
                          builder: (_, AsyncSnapshot<BpModel> snapshot) {
                            if (snapshot.hasData) {
                              bpList = snapshot.data.bpData;
                              if (snapshot.data.bpData.length == 0)
                                return Center(
                                  child: AppText.getRegularText(
                                      'No Data', 14, Colors.grey),
                                );
                              else
                                return Container(
                                  child: ListView.separated(
                                      itemBuilder: (_, index) =>
                                          GestureDetector(
                                            child: Container(
                                              constraints: BoxConstraints(
                                                minWidth: 90,
                                              ),
                                              padding: EdgeInsets.all(4),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 4),
                                                    child: AppText.getBoldText(
                                                        '${snapshot.data.bpData[index].bp1.toString()}/${snapshot.data.bpData[index].bp2.toString()}',
                                                        17,
                                                        ColorTheme.darkGreen),
                                                  ),
                                                  AppText.getLightText(
                                                      Utils.getReadableDate(
                                                          snapshot
                                                              .data
                                                              .bpData[index]
                                                              .date),
                                                      12,
                                                      ColorTheme.darkGreen,
                                                      maxLine: 2),
                                                  snapshot.data.bpData[index]
                                                          .comment.isNotEmpty
                                                      ? AppText.getLightText(
                                                          '${snapshot.data.bpData[index].comment}',
                                                          12,
                                                          ColorTheme.darkGreen)
                                                      : SizedBox.shrink(),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              BpDatum data =
                                                  snapshot.data.bpData[index];
                                              var type = "Blood Pressure";
                                              _showDetailsDialog(
                                                  data.id,
                                                  _getVitalId(type),
                                                  type,
                                                  "mmHg",
                                                  data.comment,
                                                  data.date,
                                                  "",
                                                  "${data.bp1}",
                                                  "${data.bp2}");
                                            },
                                          ),
                                      separatorBuilder: (_, index) => Container(
                                            width: 1,
                                            color: Colors.grey,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 6),
                                          ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data.bpData.length),
                                );
                            } else if (snapshot.hasError)
                              return Center(
                                child: AppText.getRegularText(
                                    '${snapshot.error.toString()}',
                                    14,
                                    Colors.redAccent),
                              );
                            else
                              return Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                    getButtonView(
                      () {
                        _showBpInputDialog();
                      },
                      () async {
                        if (bpList.length > 0) _showDialog(bpList, ViewType.bp);

                        if (bpList.length > 0) {
                          final message =
                              await _messageRepo.getPatientBPMessage();
                          if (message != null) _showMessageDialog(message);
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AppText.getRegularText('SPO2', 16, ColorTheme.darkGreen),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: ColorTheme.lightGreenOpacity,
                        ),
                        child: FutureBuilder(
                          future: patientRepo.getPatientSpo2History(),
                          builder: (_, AsyncSnapshot<Spo2Model> snapshot) {
                            if (snapshot.hasData) {
                              spoList = snapshot.data.spoData;
                              if (snapshot.data.spoData.length == 0)
                                return Center(
                                  child: AppText.getRegularText(
                                      'No Data', 14, Colors.grey),
                                );
                              else
                                return Container(
                                  child: ListView.separated(
                                      itemBuilder: (_, index) =>
                                          GestureDetector(
                                            child: Container(
                                              constraints: BoxConstraints(
                                                minWidth: 90,
                                              ),
                                              padding: EdgeInsets.all(4),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 4),
                                                    child: AppText.getBoldText(
                                                        '${snapshot.data.spoData[index].spo2.toString()}',
                                                        18,
                                                        ColorTheme.darkGreen),
                                                  ),
                                                  AppText.getLightText(
                                                      Utils.getReadableDate(
                                                          snapshot
                                                              .data
                                                              .spoData[index]
                                                              .date),
                                                      12,
                                                      ColorTheme.darkGreen,
                                                      maxLine: 2),
                                                  snapshot.data.spoData[index]
                                                          .comment.isNotEmpty
                                                      ? AppText.getLightText(
                                                          '${snapshot.data.spoData[index].comment}',
                                                          12,
                                                          ColorTheme.darkGreen)
                                                      : SizedBox.shrink(),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              SpoDatum data =
                                                  snapshot.data.spoData[index];
                                              var type = "SPO2";
                                              _showDetailsDialog(
                                                  data.id,
                                                  _getVitalId(type),
                                                  type,
                                                  "%",
                                                  data.comment,
                                                  data.date,
                                                  "${data.spo2}");
                                            },
                                          ),
                                      separatorBuilder: (_, index) => Container(
                                            width: 1,
                                            color: Colors.grey,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 15),
                                          ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data.spoData.length),
                                );
                            } else if (snapshot.hasError)
                              return Center(
                                child: AppText.getRegularText(
                                    '${snapshot.error.toString()}',
                                    14,
                                    Colors.redAccent),
                              );
                            else
                              return Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                    getButtonView(() {
                      _showInputDialog('Add SPO2', 'SPO2', "in %");
                    }, () async {
                      if (spoList.length > 0)
                        _showDialog(spoList, ViewType.spo);

                      if (spoList.length > 0) {
                        final message =
                            await _messageRepo.getPatientSPO2Message();
                        if (message != null) _showMessageDialog(message);
                      }
                    })
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: AppText.getRegularText(
                  'Blood sugar ', 16, ColorTheme.darkGreen),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 100,
                margin: const EdgeInsets.only(bottom: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: ColorTheme.lightGreenOpacity,
                        ),
                        child: FutureBuilder(
                          future: patientRepo.getPatientSugarHistory(),
                          builder: (_, AsyncSnapshot<Spo2Model> snapshot) {
                            if (snapshot.hasData) {
                              sugar = snapshot.data.spoData;
                              if (snapshot.data.spoData.length == 0)
                                return Center(
                                  child: AppText.getRegularText(
                                      'No Data', 14, Colors.grey),
                                );
                              else
                                return Container(
                                  child: ListView.separated(
                                      itemBuilder: (_, index) =>
                                          GestureDetector(
                                            child: Container(
                                              constraints: BoxConstraints(
                                                minWidth: 90,
                                              ),
                                              padding: EdgeInsets.all(4),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 4),
                                                    child: AppText.getBoldText(
                                                        '${snapshot.data.spoData[index].sugar.toString()}',
                                                        18,
                                                        ColorTheme.darkGreen),
                                                  ),
                                                  AppText.getLightText(
                                                      Utils.getReadableDate(
                                                          snapshot
                                                              .data
                                                              .spoData[index]
                                                              .date),
                                                      12,
                                                      ColorTheme.darkGreen,
                                                      maxLine: 2),
                                                  snapshot.data.spoData[index]
                                                          .comment.isNotEmpty
                                                      ? AppText.getLightText(
                                                          '${snapshot.data.spoData[index].comment}',
                                                          12,
                                                          ColorTheme.darkGreen)
                                                      : SizedBox.shrink(),
                                                ],
                                              ),
                                            ),
                                            onTap: () {
                                              SpoDatum data =
                                                  snapshot.data.spoData[index];
                                              var type = "Blood Sugar";
                                              _showDetailsDialog(
                                                  data.id,
                                                  _getVitalId(type),
                                                  type,
                                                  "mg/dL",
                                                  data.comment,
                                                  data.date,
                                                  "${data.sugar}");
                                            },
                                          ),
                                      separatorBuilder: (_, index) => Container(
                                            width: 1,
                                            color: Colors.grey,
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 15),
                                          ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data.spoData.length),
                                );
                            } else if (snapshot.hasError)
                              return Center(
                                child: AppText.getRegularText(
                                    '${snapshot.error.toString()}',
                                    14,
                                    Colors.redAccent),
                              );
                            else
                              return Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                    getButtonView(() {
                      _showInputDialog('Add Sugar', 'Blood Sugar', "in mg/dL");
                    }, () async {
                      if (spoList.length > 0)
                        _showDialog(sugar, ViewType.Sugar);

                      if (spoList.length > 0) {
                        final message =
                            await _messageRepo.getPatientSugarMessage();
                        if (message != null) _showMessageDialog(message);
                      }
                    })
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getButtonView(Function onAdd, Function onStatistics, [String data]) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              onStatistics();
            },
            child: Container(
              height: 44,
              width: 44,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: ColorTheme.buttonColor,
              ),
              child: Image.asset(AppAssets.view_vitals),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          if (data == null)
            InkWell(
              onTap: () {
                onAdd();
              },
              child: Container(
                height: 44,
                width: 44,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: ColorTheme.buttonColor,
                ),
                child: Image.asset(AppAssets.add),
              ),
            ),
        ],
      ),
    );
  }

  _showDialog(List<dynamic> list, ViewType viewType) {
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => statedialog(list, viewType),
    );
  }

  _showMessageDialog(Message message) {
    if (message.messageText.length > 0)
      showDialog(
        context: context,
        useRootNavigator: false,
        builder: (_) => MessageDialog(message),
      );
  }

  final inputcontroller = TextEditingController();
  final inputcontroller1 = TextEditingController();
  String _commentDropdownText;
  _showInputDialog(String title, String type, String suffixFallback,
      [int id, String value, String comment, DateTime date]) {
    if (_idModel == null) {
      Utils.showToast(message: 'Vital ID Not Available.');
    } else {
      _commentDropdownText =
          comment != null && comment.length > 0 ? comment : null;
      inputcontroller.text = id == null ? '' : value;
      var suffix = "in ${_getVitalSuffix(type)}" ?? suffixFallback;
      var comments = _idModel.vitalData
          .firstWhere((element) =>
              element.vitalName.toLowerCase() == '$type'.toLowerCase())
          .comments;
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: StatefulBuilder(
                  builder: ((context, setState) => Container(
                        padding: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText.getBoldText(
                                title, 16, ColorTheme.darkGreen),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: ColorTheme.lightGreenOpacity,
                              ),
                              child: TextField(
                                controller: inputcontroller,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    hintText: '$title',
                                    border: InputBorder.none,
                                    suffix: AppText.getLightText(
                                        suffix, 14, ColorTheme.darkGreen)),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: ColorTheme.lightGreenOpacity,
                              ),
                              child: comments.isNotEmpty
                                  ? DropdownButton<String>(
                                      isExpanded: true,
                                      style: TextStyle(
                                        fontSize: AppTextTheme.textSize13,
                                        fontWeight: FontWeight.normal,
                                        color: ColorTheme.darkGreen,
                                      ),
                                      underline: Container(
                                        height: 0,
                                        color: ColorTheme.darkGreen,
                                      ),
                                      onChanged: (String newValue) {
                                        setState(() {
                                          _commentDropdownText = newValue;
                                        });
                                      },
                                      hint: Text('Select comment'),
                                      value: _commentDropdownText,
                                      items: comments
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    )
                                  : SizedBox.shrink(),
                            ),
                            Container(
                              height: 40,
                              width: double.infinity,
                              child: AppButton(
                                text: id == null ? 'Add' : 'Update',
                                buttonTextColor: Colors.white,
                                color: ColorTheme.buttonColor,
                                onClick: () {
                                  if (inputcontroller.text
                                      .toString()
                                      .trim()
                                      .isEmpty) {
                                    Utils.showToast(
                                        message: 'Please enter $type');
                                  } else if (comments.isNotEmpty &&
                                      _commentDropdownText == null) {
                                    Utils.showToast(
                                        message: 'Please select comment');
                                  } else if (_idModel == null) {
                                    Utils.showToast(
                                        message: 'Vital ID Not Available.');
                                  } else {
                                    var ids = _idModel.vitalData
                                        .firstWhere((element) =>
                                            element.vitalName.toLowerCase() ==
                                            '$type'.toLowerCase())
                                        .vitalId;
                                    var value = inputcontroller.text.toString();
                                    var validationError = patientRepo
                                        .validateVitalValue(type, value);
                                    if (validationError != null) {
                                      Utils.showSingleButtonAlertDialog(
                                          context: context,
                                          message: validationError,
                                          onClick: () {
                                            setState(() {});
                                          });
                                    } else {
                                      FocusScope.of(context).unfocus();
                                      Navigator.of(context).pop();
                                      if (id == null) {
                                        _addData(
                                            ids, _commentDropdownText, value);
                                      } else {
                                        _editData(id, ids, date,
                                            _commentDropdownText, value);
                                      }
                                    }
                                  }
                                },
                                style: TextStyle(fontSize: 16),
                              ),
                            )
                          ],
                        ),
                      ))),
            );
          });
    }
  }

  _showBpInputDialog([int id, String value1, String value2, DateTime date]) {
    inputcontroller.text = value1 == null ? '' : value1;
    inputcontroller1.text = value2 == null ? '' : value2;
    var suffix = "in ${_getVitalSuffix('Blood Pressure')}" ?? "in mmHg";
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        child: Container(
          padding: const EdgeInsets.all(10),
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.getBoldText(
                  'Add Blood Pressure', 16, ColorTheme.darkGreen),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text: 'Systolic\n',
                              style: TextStyle(
                                fontSize: 14,
                                color: ColorTheme.darkGreen,
                              )),
                          TextSpan(
                              text: '(Upper Value)',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: ColorTheme.darkGreen,
                                  fontWeight: FontWeight.w400)),
                        ]),
                        textScaleFactor: 1.0,
                        textAlign: TextAlign.center,
                      ) /*Text('Systolic',style:TextStyle(fontSize: 14,color: ColorTheme.darkGreen,) ,),*/
                      ),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: ColorTheme.lightGreenOpacity,
                      ),
                      child: TextField(
                        controller: inputcontroller,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: '',
                            border: InputBorder.none,
                            suffix: AppText.getLightText(
                                suffix, 14, ColorTheme.darkGreen)),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text: 'Diastolic\n',
                              style: TextStyle(
                                fontSize: 14,
                                color: ColorTheme.darkGreen,
                              )),
                          TextSpan(
                              text: '(Lower Value)',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: ColorTheme.darkGreen,
                                  fontWeight: FontWeight.w400)),
                        ]),
                        textScaleFactor: 1.0,
                        textAlign: TextAlign.center,
                      ) //Text('Diastolic',style:TextStyle(fontSize: 14,color: ColorTheme.darkGreen,) ,),
                      ),
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: ColorTheme.lightGreenOpacity,
                      ),
                      child: TextField(
                        controller: inputcontroller1,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: '',
                            border: InputBorder.none,
                            suffix: AppText.getLightText(
                                suffix, 14, ColorTheme.darkGreen)),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 40,
                width: double.infinity,
                child: AppButton(
                  text: id == null ? 'Add' : 'Update',
                  buttonTextColor: Colors.white,
                  color: ColorTheme.buttonColor,
                  onClick: () {
                    if (inputcontroller.text.toString().trim().isEmpty ||
                        inputcontroller.text.toString().trim().isEmpty) {
                      Utils.showToast(message: 'Please enter BP');
                    }
                    if (_idModel == null) {
                      Utils.showToast(message: 'Vital ID Not Available.');
                    } else {
                      var ids = _idModel.vitalData
                          .firstWhere((element) =>
                              element.vitalName.toLowerCase() ==
                              'Blood Pressure'.toLowerCase())
                          .vitalId;
                      var value1 = inputcontroller.text.toString();
                      var value2 = inputcontroller1.text.toString();
                      var validationError = patientRepo.validateVitalValue(
                              'Blood Pressure', value1) ??
                          patientRepo.validateVitalValue(
                              'Blood Pressure', value2);

                      if (validationError != null) {
                        Utils.showSingleButtonAlertDialog(
                            context: context,
                            message: validationError,
                            onClick: () {
                              setState(() {});
                            });
                      } else {
                        FocusScope.of(context).unfocus();
                        Navigator.of(context).pop();
                        if (id == null) {
                          _addData(ids, '', null, value1, value2);
                        } else {
                          _editData(id, ids, date, '', null, value1, value2);
                        }
                      }
                    }
                  },
                  style: TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _showDetailsDialog(int id, int vitalId, String type, String suffixFallback,
      String comment, DateTime date,
      [String value, String bp1, String bp2]) {
    var suffix = _getVitalSuffix(type) ?? suffixFallback;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                  child: AppText.getBoldText(
                      type.toUpperCase(), 16, ColorTheme.darkGreen)),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: ColorTheme.lightGreenOpacity,
                ),
                child: Column(
                  children: [
                    AppText.getRegularText(
                        "${bp1 == null ? value : '$bp1 / $bp2'} $suffix",
                        18,
                        ColorTheme.darkGreen),
                    const SizedBox(
                      height: 4,
                    ),
                    AppText.getLightText(Utils.getReadableDateTime(date), 14,
                        ColorTheme.darkGreen),
                    comment.isNotEmpty
                        ? AppText.getLightText(
                            comment, 14, ColorTheme.darkGreen)
                        : SizedBox.shrink(),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      child: AppButton(
                        text: 'Delete',
                        buttonTextColor: Colors.white,
                        color: ColorTheme.buttonColor,
                        onClick: () {
                          FocusScope.of(context).unfocus();
                          Navigator.of(context).pop();
                          _deleteVitalValue(id);
                        },
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      height: 40,
                      child: AppButton(
                        text: 'Edit',
                        buttonTextColor: Colors.white,
                        color: ColorTheme.buttonColor,
                        onClick: () {
                          FocusScope.of(context).unfocus();
                          Navigator.of(context).pop();
                          if (bp1 == null) {
                            _showInputDialog("Edit $type", type, suffixFallback,
                                id, value, comment, date);
                          } else {
                            _showBpInputDialog(id, bp1, bp2, date);
                          }
                        },
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String _getVitalSuffix(String type) {
    String suffix;
    if (_idModel != null) {
      try {
        VitalDatum vitalDatum = _idModel.vitalData
            .firstWhere((e) => e.vitalName.toLowerCase() == type.toLowerCase());
        suffix = vitalDatum.units;
      } catch (e) {}
    }
    return suffix;
  }

  int _getVitalId(String type) {
    int vitalId = 0;
    if (_idModel != null) {
      try {
        VitalDatum vitalDatum = _idModel.vitalData
            .firstWhere((e) => e.vitalName.toLowerCase() == type.toLowerCase());
        vitalId = vitalDatum.vitalId;
      } catch (e) {}
    }
    return vitalId;
  }

  _addData(int ids, String comment,
      [String value, String bp1, String bp2]) async {
    final response = await patientRepo.addVitals(ids, comment, value, bp1, bp2);

    if (response == null) {
      inputcontroller.text = '';
      inputcontroller1.text = '';
      Utils.showSingleButtonAlertDialog(
          context: context,
          message: 'Vital Added successfully',
          onClick: () {
            setState(() {});
          });
    } else {
      Utils.showToast(message: response, isError: true);
    }
  }

  _editData(int id, int vitalId, DateTime date, String comment,
      [String value, String bp1, String bp2]) async {
    Loader.showProgress();
    final response = await patientRepo.editVitalValue(
        id, vitalId, date, comment, value, bp1, bp2);
    Loader.hide();

    if (response == null) {
      inputcontroller.text = '';
      inputcontroller1.text = '';
      setState(() {});
    } else {
      Utils.showToast(message: response, isError: true);
    }
  }

  _deleteVitalValue(int id) async {
    Loader.showProgress();
    final response = await patientRepo.deleteVitalValue(id);
    Loader.hide();

    if (response == null) {
      setState(() {});
    } else {
      Utils.showToast(message: response, isError: true);
    }
  }
}

class statedialog extends StatelessWidget {
  final List<dynamic> list;
  final ViewType type;
  statedialog(this.list, this.type);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        height: 300,
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: ColorTheme.white,
        ),
        child: Center(
          child: getView(list, type),
        ),
      ),
    );
  }

  Widget getView(List<dynamic> list, ViewType viewType) {
    switch (viewType) {
      case ViewType.weight:
        return PointsLineChart.forWeight(list);
      case ViewType.height:
        return PointsLineChart.forHeight(list);
      case ViewType.temperature:
        return PointsLineChart.forTemperature(list);
      case ViewType.pluse:
        return PointsLineChart.forPluse(list);
      case ViewType.bp:
        return PointsLineChart.forBP(list, true);
      case ViewType.spo:
        return PointsLineChart.forSpo2(list);
      case ViewType.Sugar:
        return PointsLineChart.forSugar(list);
      case ViewType.bmi:
        // TODO: Handle this case.
        break;
    }
  }
}

class MessageDialog extends StatelessWidget {
  ConfettiController _controllerBottomCenter;
  final Message message;
  AudioPlayer audioPlugin = AudioPlayer();
  MessageDialog(this.message);

  _play() {
    try {
      audioPlugin.play(message.soundPath, isLocal: false);
    } catch (e) {}
  }

  _hide(BuildContext cntx) {
    Future.delayed(Duration(seconds: 6), () {
      audioPlugin.stop();
      if (message.animation) _controllerBottomCenter.dispose();
      Navigator.of(cntx).pop();
    });
  }

  _playAnim() {
    Future.delayed(Duration(seconds: 1), () {
      _controllerBottomCenter.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (message.soundPath.length > 0) _play();

    if (message.animation)
      _controllerBottomCenter = ConfettiController(
        duration: const Duration(seconds: 6),
      );
    //_play();
    _hide(context);
    if (message.animation) _playAnim();
    return GestureDetector(
      onTap: () {
        audioPlugin.stop();
        if (message.animation) _controllerBottomCenter.dispose();
        Navigator.of(context).pop();
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.all(24),
        child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Colors.transparent,
              /* image: DecorationImage(
              fit: BoxFit.contain,
              image: NetworkImage(message.imagePath,headers: Utils.getHeaders())
            )*/
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  if (message.animation)
                    Align(
                      alignment: Alignment.center,
                      child: ConfettiWidget(
                        confettiController: _controllerBottomCenter,
                        blastDirectionality: BlastDirectionality
                            .explosive, // don't specify a direction, blast randomly
                        shouldLoop: true,
                        // start again as soon as the animation is finished
                        colors: const [
                          Colors.green,
                          Colors.blue,
                          Colors.pink,
                          Colors.orange,
                          Colors.purple,
                          Colors.yellow,
                          Colors.orangeAccent,
                          Colors.amber,
                        ], // manually specify the colors to be used
                      ),
                    ),
                  Expanded(child: Container()),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          message.messageText ?? '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.redAccent,
                              fontFamily: 'comicz'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
