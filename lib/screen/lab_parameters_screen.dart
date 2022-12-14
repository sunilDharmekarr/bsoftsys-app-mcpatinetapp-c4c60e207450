import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/CommonLabTest.dart';
import 'package:mumbaiclinic/model/ParameterDetailModel.dart';
import 'package:mumbaiclinic/repository/lab_test_repo.dart';
import 'package:mumbaiclinic/screen/lab_parameter_search_screen.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/chart/PointsLineChart.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/family_vertical_view.dart';
//import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class LabParameterScreen extends StatefulWidget {
  @override
  _LabParameterScreenState createState() => _LabParameterScreenState();
}

class _LabParameterScreenState extends State<LabParameterScreen> {
  final _searchController = TextEditingController();
  final _searchPController = TextEditingController();
  final labRepo = LabTestRepo();
  List<CommonDatum> _commonList = [];
  bool firstY = true;
  bool secondY = false;
  DateTime fromDate;
  DateTime toDate = DateTime.now();
  String pId = '';
  String groupId = '';
  String testName = '';

  bool data = false;

  @override
  void initState() {
    super.initState();
    pId = PreferenceManager.getUserId();
    fromDate = _fromDate();
    _getCommonLabParameter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar('Lab Parameters',
          color: ColorTheme.lightGreenOpacity),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: FamilyHorizontalView((id) {
              setState(() {
                groupId = '';
                testName = '';
                _searchController.text = '';
                _searchPController.text = '';
                data = false;
                pId = id.toString();
                // _getLabParametersDetails();
              });
            }),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 20,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: AppText.getBoldText(
                  'Select Parameters', 16, ColorTheme.darkGreen),
            ),
          ),
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(CupertinoPageRoute(
                    builder: (_) => LabParameterSearchScreen(
                          mode: LabParameterSearchScreen.group,
                          title: 'Search Test Group',
                          onSelected: (data, id) {
                            setState(() {
                              _searchController.text = data.toString();
                              groupId = id.toString();
                              testName = '';
                              _searchPController.text = '';
                            });
                          },
                        )));
              },
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.only(left: 14),
                decoration: BoxDecoration(
                  color: ColorTheme.lightGreenOpacity,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  enabled: false,
                  controller: _searchController,
                  onChanged: (value) {},
                  onSubmitted: (value) {},
                  style: TextStyle(
                      fontSize: 14,
                      color: ColorTheme.darkGreen,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search Test Group',
                      hintStyle: TextStyle(
                          fontSize: 14,
                          color: ColorTheme.darkGreen,
                          fontWeight: FontWeight.bold),
                      suffixIcon: Icon(
                        Icons.search_outlined,
                        color: ColorTheme.darkGreen,
                      )),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () {
                if (groupId.isEmpty) {
                  Utils.showToast(message: 'Select Group fist');
                } else {
                  Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) => LabParameterSearchScreen(
                            mode: LabParameterSearchScreen.parameter,
                            id: groupId,
                            title: 'Search Test Parameter',
                            onSelected: (data, id) {
                              setState(() {
                                testName = data.toString();
                                _searchPController.text = data.toString();
                              });
                            },
                          )));
                }
              },
              child: Container(
                height: 40,
                margin:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                padding: const EdgeInsets.only(left: 14),
                decoration: BoxDecoration(
                  color: ColorTheme.lightGreenOpacity,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  enabled: false,
                  controller: _searchPController,
                  onChanged: (value) {},
                  onSubmitted: (value) {},
                  style: TextStyle(
                      fontSize: 14,
                      color: ColorTheme.darkGreen,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search Test Parameter',
                      hintStyle: TextStyle(
                          fontSize: 14,
                          color: ColorTheme.darkGreen,
                          fontWeight: FontWeight.bold),
                      suffixIcon: Icon(
                        Icons.search_outlined,
                        color: ColorTheme.darkGreen,
                      )),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 1,
              color: ColorTheme.darkGreen,
              margin: const EdgeInsets.symmetric(
                vertical: 10,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
              ),
              child: AppText.getBoldText(
                  'Common Parameters', 14, ColorTheme.darkGreen),
            ),
          ),
          if (_commonList.length > 0)
            SliverToBoxAdapter(
              child: Container(
                height: 130,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                ),
                child: GridView.count(
                  scrollDirection: Axis.horizontal,
                  crossAxisCount: 3,
                  childAspectRatio: 0.45,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  children: _commonList
                      .map<Widget>(
                        (e) => GestureDetector(
                          onTap: () {
                            setState(() {
                              testName = e.test;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: testName == '${e.test}'
                                  ? ColorTheme.darkGreen
                                  : ColorTheme.lightGreenOpacity,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.center,
                            child: AppText.getRegularText(
                                e.test,
                                14,
                                testName == '${e.test}'
                                    ? ColorTheme.white
                                    : ColorTheme.darkGreen,
                                maxline: 2),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Container(
              height: 1,
              color: ColorTheme.darkGreen,
              margin: const EdgeInsets.symmetric(
                vertical: 10,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: ColorTheme.lightGreenOpacity,
              padding: const EdgeInsets.all(
                10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.getBoldText(
                      'Select Duration', 14, ColorTheme.darkGreen),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          firstY = true;
                          secondY = false;
                          _fromDate();

                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: firstY
                                  ? ColorTheme.buttonColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: ColorTheme.buttonColor,
                              )),
                          alignment: Alignment.center,
                          child: AppText.getRegularText(
                            '1 Year ',
                            14,
                            firstY ? ColorTheme.white : ColorTheme.darkGreen,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      GestureDetector(
                        onTap: () {
                          firstY = false;
                          secondY = true;
                          _fromDate();
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: secondY
                                  ? ColorTheme.buttonColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: ColorTheme.buttonColor,
                              )),
                          alignment: Alignment.center,
                          child: AppText.getRegularText(
                            '5 Years',
                            14,
                            secondY ? ColorTheme.white : ColorTheme.darkGreen,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _showDateRangePicker();
                        },
                        icon: Image.asset(
                          AppAssets.calander,
                          width: 24,
                          height: 24,
                          color: ColorTheme.iconColor,
                        ),
                      ),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text: 'From: \n',
                              style: TextStyle(
                                  fontFamily: TextFont.poppinsLight,
                                  fontSize: 12)),
                          TextSpan(
                              text: 'To Date: ',
                              style: TextStyle(
                                  fontFamily: TextFont.poppinsLight,
                                  fontSize: 12)),
                        ]),
                      ),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text: '${Utils.getReadableDate(fromDate)}\n',
                              style: TextStyle(
                                  fontFamily: TextFont.poppinsLight,
                                  fontSize: 12)),
                          TextSpan(
                              text: '${Utils.getReadableDate(toDate)}',
                              style: TextStyle(
                                  fontFamily: TextFont.poppinsLight,
                                  fontSize: 12)),
                        ]),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.6,
              color: ColorTheme.white,
              margin: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  if (testName.isEmpty) {
                    Utils.showToast(message: 'Select Lab Parameters');
                  } else {
                    _getLabParametersDetails();
                  }
                },
                child: AppText.getBoldText(
                  'Get Lab Parameters',
                  16,
                  ColorTheme.white,
                ),
                style: ElevatedButton.styleFrom(
                  primary: ColorTheme.buttonColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ),
          if (data)
            SliverList(
              delegate: SliverChildListDelegate(
                _parameters.length == 0
                    ? [
                        Container(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          child: AppText.getErrorText('No Data', 16),
                        )
                      ]
                    : _parameters.map((element) {
                        return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: ColorTheme.darkGreen,
                                        width: 0.5))),
                            child: Row(
                              children: [
                                Expanded(
                                    child: AppText.getBoldText(
                                        Utils.getReadableDate(element.testDate),
                                        14,
                                        ColorTheme.darkGreen)),
                                Container(
                                    color: ColorTheme.darkGreen,
                                    height: 30,
                                    width: 1),
                                Expanded(
                                    child: Center(
                                        child: AppText.getBoldText(
                                  '${element.testValue}',
                                  14,
                                  ColorTheme.darkGreen,
                                )))
                              ],
                            ));
                      }).toList(),
              ),
            ),
          if (_parameters.length > 0)
            SliverToBoxAdapter(
              child: Container(
                  height: 320,
                  margin:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                  child: PointsLineChart.parameters(_parameters)),
            )
        ],
      ),
    );
  }

  _fromDate() {
    fromDate = DateTime.now().subtract(Duration(days: firstY ? 365 : 1827));
    return fromDate;
  }

  _showDateRangePicker() async {
    var pickedRange = await showDateRangePicker(
      context: context,
      //initialEntryMode: DatePickerEntryMode.input,
      initialDateRange: DateTimeRange(start: fromDate, end: toDate),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      saveText: 'Apply',
      builder: (context, Widget child) => Theme(
        data: Theme.of(context).copyWith(
            dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBarTheme: Theme.of(context).appBarTheme.copyWith(
                iconTheme:
                    IconThemeData(color: Theme.of(context).primaryColor)),
            colorScheme: Theme.of(context).colorScheme.copyWith(
                onPrimary: Theme.of(context).primaryColor,
                primary: Theme.of(context).colorScheme.primary)),
        child: child,
      ),
    );
    if (pickedRange != null) {
      setState(() {
        //print("ANAMOY: From: ${pickedRange.start}, ${pickedRange.end}");
        fromDate = pickedRange.start;
        toDate = pickedRange.end;
      });
    }

    /* final List<DateTime> picked = await DateRagePicker.showDatePicker(
        context: context,
        initialFirstDate:
            DateTime.now().subtract(Duration(days: firstY ? 365 : 1827)),
        initialLastDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now());
    print("From DAte" + picked[1].toString());
    // if (picked != null ) {

    setState(() {
      fromDate = picked[0];
      toDate = picked[1];
    });
    //  } */
  }

  _getCommonLabParameter() async {
    final response = await labRepo.getCommonLabParameter();

    _commonList.clear();
    if (response != null) {
      _commonList.addAll(response.heightData);
    }
    setState(() {});
  }

  List<Parameter> _parameters = [];
  _getLabParametersDetails() async {
    Loader.showProgress();
    final result =
        await labRepo.getLabParameterDetails(fromDate, toDate, pId, testName);
    Loader.hide();
    this.data = true;
    var error = 'Failed to load data';
    if (result != null) {
      if (result.success == 'true') {
        error = null;
        _parameters = result.parameters;
      } else {
        error = 'Failed to load data: ${result.error}';
      }
    }
    if (error != null) {
      Utils.showToast(message: error, isError: true);
    }
    setState(() {});
  }
}
