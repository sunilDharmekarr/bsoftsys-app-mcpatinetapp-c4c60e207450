import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/global/CartData.dart';
import 'package:mumbaiclinic/model/LabTestModel.dart';
import 'package:mumbaiclinic/model/lab_model.dart';
import 'package:mumbaiclinic/model/profile_details_model.dart';
import 'package:mumbaiclinic/repository/lab_test_repo.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class TestDetailScreen extends StatefulWidget {
  final bool istest;
  final Lab lab;
  final Labtest labtest;

  TestDetailScreen({this.istest, this.lab, this.labtest});

  @override
  _TestDetailScreenState createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends State<TestDetailScreen>
    with TickerProviderStateMixin {
  final tab = [];
  TabController _tabController;
  List<String> prescription = [];
  int currentIndex = 0;
  String radioItem = '1';
  ProfileDetail profileDetail;

  @override
  void initState() {
    super.initState();
    if (widget.istest) {
      tab.add("Preparation");
    } else {
      _getProfileData();
      tab.add("Tests included");
      tab.add("Preparation");
    }
    prescription.add(widget.labtest.preparation ?? '');
    _tabController =
        TabController(vsync: this, length: tab.length, initialIndex: 0);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(0),
                child: TextView(
                  text: widget.istest
                      ? widget.labtest.testName
                      : widget.labtest.profileName,
                  style: AppTextTheme.textTheme16Regular,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextView(
                  text: widget.istest
                      ? _validateText(
                          'Description: ${widget.labtest.testDetails}')
                      : _validateText(
                          'Description: ${profileDetail?.profileDetails}'),
                  style: AppTextTheme.textTheme12Light,
                ),
              ),
              Container(
                color: ColorTheme.darkGreen.withOpacity(0.1),
                height: 4,
              ),
              const SizedBox(
                height: 8,
              ),
              if (widget.lab != null)
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextView(
                        text: 'Lab :',
                        style: AppTextTheme.textTheme14Light,
                      ),
                    ),
                    Expanded(
                      child: TextView(
                        text: widget.lab.labName,
                        style: AppTextTheme.textTheme14Bold,
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextView(
                      text: 'Price :',
                      style: AppTextTheme.textTheme14Light,
                    ),
                  ),
                  Expanded(
                    child: TextView(
                      text: widget.istest
                          ? 'Rs.${widget.labtest.price.toString()}'
                          : 'Rs.${profileDetail?.price.toString()}',
                      style: AppTextTheme.textTheme14Bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextView(
                      text: 'Discounted price :',
                      style: AppTextTheme.textTheme14Light,
                    ),
                  ),
                  Expanded(
                    child: TextView(
                      text: widget.istest
                          ? 'Rs.${widget.labtest.discountedPrice.toString()}'
                          : 'Rs.${profileDetail?.discountedPrice.toString()}',
                      style: AppTextTheme.textTheme14Bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextView(
                      text: 'Age Detail :',
                      style: AppTextTheme.textTheme14Light,
                    ),
                  ),
                  Expanded(
                    child: TextView(
                      text: widget.istest
                          ? _validateText(widget.labtest.ageDetails)
                          : _validateText(profileDetail?.ageDetails),
                      style: AppTextTheme.textTheme14Bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextView(
                      text: 'Gender :',
                      style: AppTextTheme.textTheme14Light,
                    ),
                  ),
                  Expanded(
                    child: TextView(
                      text: widget.istest
                          ? _validateText(widget.labtest.gender)
                          : _validateText(profileDetail?.gender),
                      style: AppTextTheme.textTheme14Bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextView(
                      text: 'Collection Method :',
                      style: AppTextTheme.textTheme14Light,
                    ),
                  ),
                  Expanded(
                    child: TextView(
                      text: widget.istest
                          ? _validateText(widget.labtest.collectionMethod)
                          : _validateText(profileDetail?.collectionMethod),
                      style: AppTextTheme.textTheme14Bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: ColorTheme.lightGreenOpacity,
                    boxShadow: Utils.getShadow()),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 42,
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          topLeft: Radius.circular(8),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 0),
                          isScrollable: false,
                          unselectedLabelColor: ColorTheme.darkGreen,
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: ColorTheme.darkGreen,
                          indicator: BoxDecoration(
                            color: ColorTheme.darkGreen.withOpacity(0.4),
                          ),
                          onTap: (index) {
                            currentIndex = index;
                            setState(() {});
                          },
                          tabs: tab
                              .map((e) => Tab(
                                    child: Container(
                                      height: 44,
                                      margin:
                                          const EdgeInsets.only(bottom: 1.5),
                                      decoration: BoxDecoration(
                                        color: ColorTheme.lightGreenOpacity,
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
                    ),
                    Container(
                      child: Container(
                        child: Container(
                          child: _getTabView(currentIndex),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 40,
                margin: const EdgeInsets.only(top: 12),
                child: AppButton(
                  text: 'Add to cart',
                  style: AppTextTheme.textTheme12Light,
                  onClick: () {
                    if (widget.istest) {
                      CartData.addItems(widget.labtest);
                      Navigator.of(context).pop(true);
                    } else {
                      final data = Labtest(
                        price: profileDetail?.price,
                        preparation: profileDetail?.preparation,
                        profileCode: profileDetail?.profileCode,
                        profileName: profileDetail?.profileName,
                        discountedPrice: profileDetail?.discountedPrice,
                        profileId: widget.labtest.profileId,
                        testCode: null,
                        testDetails: null,
                        testId: null,
                        testName: null,
                      );
                      CartData.addItems(data);
                      Navigator.of(context).pop(true);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _getTabView(int index) {
    if (!widget.istest) {
      prescription.clear();
      if (profileDetail != null) {
        //var data = profileDetail;
        if (index == 0)
          profileDetail?.tests?.forEach((element) {
            prescription.add(element.testName);
          });

        if (index == 1) prescription.add(profileDetail?.preparation);
      }
      return ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: prescription
            .map((e) => Container(
                  padding: const EdgeInsets.all(10),
                  child: TextView(
                    text: e?.toString(),
                    style: AppTextTheme.textTheme12Light,
                  ),
                ))
            .toList(),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(10),
        child: TextView(
          text: _validateText(widget.labtest.preparation),
          style: AppTextTheme.textTheme12Light,
        ),
      );
    }
  }

  String _validateText(String text) {
    if (text != null && text.trim().isNotEmpty) return text.trim();
    return 'Not available';
  }

  void _getProfileData() async {
    //EasyLoading.show(status: '', indicator: CircularProgressIndicator());
    Loader.showProgress();
    final labtestrepo = LabTestRepo();
    final data = await labtestrepo
        .getLabProfileDetails(widget.labtest.profileId.toString());
    profileDetail = data.profileDetail[0];
    //EasyLoading.dismiss();
    Loader.hide();
    setState(() {});
  }
}
