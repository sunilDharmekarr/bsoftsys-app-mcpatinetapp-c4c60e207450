import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/model/LabTestModel.dart';
import 'package:mumbaiclinic/model/address_model.dart';
import 'package:mumbaiclinic/model/lab_model.dart';
import 'package:mumbaiclinic/model/lab_slot_model.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/repository/lab_selection_repo.dart';
import 'package:mumbaiclinic/repository/lab_test_repo.dart';
import 'package:mumbaiclinic/repository/patient_repo.dart';
import 'package:mumbaiclinic/screen/ordertest/order_summary.dart';
import 'package:mumbaiclinic/screen/register/user_form_screen.dart';
import 'package:mumbaiclinic/screen/testdetals/test_detail_screen.dart';
import 'package:mumbaiclinic/services/address_service.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/dialog/edit_address_dialog.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

class OrderTestScreen extends StatefulWidget {
  @override
  _OrderTestScreenState createState() => _OrderTestScreenState();
}

class _OrderTestScreenState extends State<OrderTestScreen>
    with TickerProviderStateMixin {
  var _selectedTest = Set<int>();
  var _selectedProfile = Set<int>();
  var _selectedPatient = -1;
  var _addressType = 0;
  AddressDatum _selectedAddress;
  var _selectedLab = -1;
  var _selectedTestType = typeAll;
  var _lastPatientAddress = 0;
  DateTime _selectedDate;
  Slot _selectedSlot;

  List<Labtest> _tests = [];
  List<Labtest> _filteredTests = [];
  List<Labtest> _frequentTests = [];
  //List<FamilyMember> _patients = [];
  List<Datum> _users = [];
  List<AddressDatum> _addresses = [];
  List<Lab> _labs = [];
  List<Slot> _slots = [];
  List<DateTime> time = [];
  Map<int, double> _labDistances = {};
  LoadingState _dataState = LoadingState.Loading;
  LoadingState _addressState = LoadingState.Loading;

  static const pageTest = 0;
  static const pagePatient = 1;
  static const pageLocation = 2;
  static const pageTime = 3;
  static const typeAll = 0;
  static const typeIndividual = 1;
  static const typeProfile = 2;
  final stepTitles = ['Tests', 'Patient', 'Place', 'Time'];
  final testTypeOptions = ['All test types', 'Specific tests', 'Profile tests'];

  var _tabIndex = pageTest;
  var _monthValue = 0;
  var _isSearchOpen = false;

  var _currentDate = DateTime.now();
  final _controller = ScrollController();
  final _testSearchController = TextEditingController();
  TabController _tabController;
  final AddressService _addressService = AddressService.instance;
  Position _currentLocation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: stepTitles.length, vsync: this, initialIndex: pageTest);
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });
    _dataState = LoadingState.Loading;
    _loadData();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: ColorTheme.white,
        title: Text(
          'Order tests',
          style: Theme.of(MyApplication.navigatorKey.currentContext)
              .appBarTheme
              .textTheme
              .headline1,
          //.headline1,
        ),
        leading: IconButton(
          onPressed: () {
            MyApplication.pop();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(MyApplication.navigatorKey.currentContext)
                .primaryColor,
          ),
        ),
        actions: [
          if (_tabIndex == pageLocation && _currentLocation == null)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextView(
                  text: 'Location',
                  style: TextStyle(
                      fontSize: AppTextTheme.textSize14,
                      color: ColorTheme.darkGreen,
                      fontFamily: TextFont.poppinsLight),
                ),
                SizedBox(
                  width: 6,
                ),
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: ColorTheme.darkGreen),
                ),
                SizedBox(
                  width: 8,
                ),
              ],
            ),
        ],
        bottom: _dataState == LoadingState.Success
            ? PreferredSize(
                preferredSize: const Size.fromHeight(36),
                child: IgnorePointer(
                  child: Container(
                    height: 36,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: TabBar(
                      tabs: List.generate(
                          stepTitles.length,
                          (index) => Tab(
                                child: TextView(
                                    text: stepTitles[index],
                                    maxLine: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextTheme.textTheme14Bold,
                                    color: _tabIndex == index
                                        ? Colors.black
                                        : ColorTheme.darkGreen),
                              )),
                      controller: _tabController,
                      indicator: RectangularIndicator(
                        color: ColorTheme.buttonColor,
                        paintingStyle: PaintingStyle.fill,
                        topLeftRadius: 18,
                        bottomLeftRadius: 18,
                        topRightRadius: 18,
                        bottomRightRadius: 18,
                      ),
                    ),
                  ),
                ),
              )
            : PreferredSize(
                preferredSize: const Size.fromHeight(36),
                child: SizedBox.shrink()),
      ),
      body: _dataState == LoadingState.Success
          ? TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                _buildTests(),
                _buildPatients(),
                _buildLocation(),
                _buildDateTime(),
              ],
            )
          : _dataState == LoadingState.Loading
              ? SizedBox.expand()
              : Center(
                  child: TextView(
                    text: 'Failed to load data!\nPlease try later.',
                    style: AppTextTheme.textTheme16Regular,
                    color: ColorTheme.darkRed,
                    textAlign: TextAlign.center,
                  ),
                ),
      bottomNavigationBar: _dataState == LoadingState.Success
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _tabIndex > 0 ? _previousPage : null,
                  child: Container(
                    height: 36,
                    constraints: BoxConstraints(minWidth: 80),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(4),
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                        color: ColorTheme.buttonColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: Utils.getShadow()),
                    child: TextView(
                      text: "BACK",
                      color: _tabIndex > 0 ? Colors.white : Color(0x60FFFFFF),
                      style: AppTextTheme.textTheme14Light,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.bounceIn,
                  child: _buildBottomOptions(),
                ),
                GestureDetector(
                  onTap: _nextPage,
                  child: Container(
                    height: 36,
                    constraints: BoxConstraints(minWidth: 80),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(4),
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                        color: ColorTheme.buttonColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: Utils.getShadow()),
                    child: TextView(
                      text: _tabIndex == pageTime ? 'FINISH' : 'NEXT',
                      color: Colors.white,
                      style: AppTextTheme.textTheme14Light,
                    ),
                  ),
                ),
              ],
            )
          : SizedBox.shrink(),
    );
  }

  _previousPage() {
    FocusScope.of(context).unfocus();
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
    }
  }

  _nextPage() {
    FocusScope.of(context).unfocus();
    if (_tabIndex == pageTest &&
        (_selectedTest.isEmpty && _selectedProfile.isEmpty)) {
      Utils.showToast(message: "Please select test(s)");
    } else if (_tabIndex == pagePatient && _selectedPatient <= 0) {
      Utils.showToast(message: "Please select patient");
    } else if (_tabIndex == pageLocation &&
        _addressType == 0 &&
        _selectedAddress == null) {
      Utils.showToast(message: "Please select address");
    } else if (_tabIndex == pageLocation &&
        _addressType == 1 &&
        _selectedLab <= 0) {
      Utils.showToast(message: "Please select lab");
    } else if (_tabIndex == pageTime &&
        (_selectedDate == null || _selectedSlot == null)) {
      Utils.showToast(message: "Please select date/time");
    } else if (_tabController.index == pageTime) {
      if (_validate()) {
        Navigator.of(context).push<bool>(CupertinoPageRoute(
            builder: (_) => OrderSummaryScreen(
                _tests
                    .where((test) =>
                        (test.testId != null &&
                            _selectedTest.contains(test.testId)) ||
                        (test.profileId != null &&
                            _selectedProfile.contains(test.profileId)))
                    .toList(),
                _users
                    .firstWhere((patient) => patient.patid == _selectedPatient),
                _addressType == 0
                    ? _addresses.firstWhere(
                        (address) => address.id == _selectedAddress.id)
                    : null,
                _addressType == 1
                    ? _labs.firstWhere((lab) => lab.labId == _selectedLab)
                    : null,
                DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                ),
                _selectedSlot.collectionSlot)));
      }
    } else {
      final nextPage = _tabController.index + 1;
      if (nextPage == pageLocation && _lastPatientAddress != _selectedPatient) {
        _loadAddress(_selectedPatient);
      }
      _tabController.animateTo(nextPage);
    }
  }

  Widget _buildTests() {
    return Column(
      children: [
        if (!_isSearchOpen)
          SizedBox(
            height: 96,
            child: Card(
              child: Row(
                children: [
                  RotatedBox(
                    quarterTurns: -1,
                    child: TextView(
                      text: 'Frequently\nOrdered',
                      style: AppTextTheme.textTheme12Light,
                      color: Colors.black45,
                      maxLine: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemBuilder: (context, index) => InkWell(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _toggleTestSelection(_frequentTests[index]);
                                });
                              },
                              child: Container(
                                //constraints: BoxConstraints(maxWidth: 300),
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                child: Row(
                                  children: [
                                    _isTestSelected(_frequentTests[index])
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              color: ColorTheme.buttonColor,
                                              child: Icon(
                                                Icons.check,
                                                size: 32,
                                                color: ColorTheme.white,
                                              ),
                                            ),
                                          )
                                        : Image.asset(
                                            AppAssets.tests,
                                            height: 40,
                                            width: 40,
                                            //color: ColorTheme.darkGreen,
                                          ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(top: 8),
                                          child: TextView(
                                            text: _frequentTests[index]
                                                        .testId !=
                                                    null
                                                ? '${_frequentTests[index].testName}'
                                                : '${_frequentTests[index].profileName}',
                                            style:
                                                AppTextTheme.textTheme16Regular,
                                            color: _isTestSelected(
                                                    _frequentTests[index])
                                                ? ColorTheme.buttonColor
                                                : ColorTheme.darkGreen,
                                            maxLine: 1,
                                            overflow: TextOverflow.fade,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextView(
                                              text:
                                                  'Rs ${Utils.formatAmount(_frequentTests[index].discountedPrice)}',
                                              style:
                                                  AppTextTheme.textTheme14Light,
                                              color: _isTestSelected(
                                                      _frequentTests[index])
                                                  ? ColorTheme.buttonColor
                                                  : ColorTheme.darkGreen,
                                              maxLine: 1,
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                bool result = await showDialog(
                                                    context: context,
                                                    builder:
                                                        (_) => TestDetailScreen(
                                                              istest: _frequentTests[
                                                                          index]
                                                                      .testId !=
                                                                  null,
                                                              labtest:
                                                                  _frequentTests[
                                                                      index],
                                                              lab: null,
                                                            ));

                                                if (result != null && result) {
                                                  setState(() {
                                                    _frequentTests[index]
                                                                .testId !=
                                                            null
                                                        ? _selectedTest.add(
                                                            _frequentTests[
                                                                    index]
                                                                .testId)
                                                        : _selectedProfile.add(
                                                            _frequentTests[
                                                                    index]
                                                                .profileId);
                                                  });
                                                }
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    12, 8, 16, 8),
                                                child: TextView(
                                                  text: 'DETAILS',
                                                  style: AppTextTheme
                                                      .textTheme12Bold,
                                                  //fontStyle: FontStyle.italic,
                                                  color: _isTestSelected(
                                                          _frequentTests[index])
                                                      ? ColorTheme.buttonColor
                                                      : Colors.black38,
                                                  maxLine: 1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                        itemCount: _frequentTests.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal),
                  ),
                ],
              ),
            ),
          ),
        Card(
            child: _isSearchOpen
                ? Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: SizedBox(
                            height: 36,
                            child: Stack(
                              children: [
                                TextField(
                                  controller: _testSearchController,
                                  enableInteractiveSelection: true,
                                  inputFormatters: [
                                    FilteringTextInputFormatter(
                                        RegExp('[a-zA-Z0-9 ]'),
                                        replacementString: '',
                                        allow: true),
                                  ],
                                  autofocus: false,
                                  maxLines: 1,
                                  keyboardType: TextInputType.name,
                                  textInputAction: TextInputAction.none,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .apply(
                                          fontFamily: TextFont.poppinsRegular),
                                  onChanged: (val) => _filterTests(),
                                  decoration: InputDecoration(
                                    /* icon: SizedBox.square(
                                      dimension: 18,
                                      child: Icon(Icons.search),
                                    ), */
                                    hintText: 'Search test name',
                                    hintStyle:
                                        Theme.of(context).textTheme.caption,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.fromLTRB(44, 4, 12, 4),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isSearchOpen = false;
                                      _testSearchController.text = '';
                                    });
                                    FocusScope.of(context).unfocus();
                                    _filterTests();
                                  },
                                  child: SizedBox(
                                    height: 36,
                                    width: 44,
                                    child: Icon(
                                      Icons.arrow_back,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        child: LimitedBox(
                          maxHeight: 36,
                          maxWidth: 120,
                          child: DropdownButton(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                            },
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: ColorTheme.darkGreen,
                              size: 24,
                            ),
                            underline: Container(),
                            value: _selectedTestType,
                            items: List.generate(
                              testTypeOptions.length,
                              (index) => DropdownMenuItem(
                                child: Text(
                                  testTypeOptions[index],
                                  textAlign: TextAlign.right,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      .apply(
                                        fontFamily: TextFont.poppinsRegular,
                                        color: ColorTheme.darkGreen,
                                      ),
                                ),
                                value: index,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _selectedTestType = value;
                              });
                              FocusScope.of(context).unfocus();
                              _filterTests();
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      RotatedBox(
                        quarterTurns: -1,
                        child: TextView(
                          text: 'Tests',
                          style: AppTextTheme.textTheme12Light,
                          color: Colors.black45,
                          maxLine: 2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Radio<int>(
                        value: typeAll,
                        groupValue: _selectedTestType,
                        onChanged: (value) => setState(() {
                          _selectedTestType = typeAll;
                          _filterTests();
                        }),
                      ),
                      TextView(
                          text: "All", style: AppTextTheme.textTheme12Light),
                      SizedBox.square(dimension: 12),
                      Radio<int>(
                        value: typeIndividual,
                        groupValue: _selectedTestType,
                        onChanged: (value) => setState(() {
                          _selectedTestType = typeIndividual;
                          _filterTests();
                        }),
                      ),
                      TextView(
                          text: "Individual",
                          style: AppTextTheme.textTheme12Light),
                      SizedBox.square(dimension: 12),
                      Radio<int>(
                        value: typeProfile,
                        groupValue: _selectedTestType,
                        onChanged: (value) => setState(() {
                          _selectedTestType = typeProfile;
                          _filterTests();
                        }),
                      ),
                      TextView(
                          text: "Profile",
                          style: AppTextTheme.textTheme12Light),
                      Expanded(child: Container()),
                      IconButton(
                          onPressed: () {
                            setState(() {
                              _isSearchOpen = true;
                              _testSearchController.text = '';
                            });
                            _filterTests();
                          },
                          icon: Icon(Icons.search)),
                    ],
                  )),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
            itemBuilder: (context, index) {
              //print("ANAMOY: $index");
              return CheckboxListTile(
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: ColorTheme.buttonColor,
                title: TextView(
                  text: _filteredTests[index].testId != null
                      ? '${_filteredTests[index].testName}'
                      : '${_filteredTests[index].profileName}',
                  style: AppTextTheme.textTheme16Regular,
                  color: _isTestSelected(_filteredTests[index])
                      ? ColorTheme.buttonColor
                      : ColorTheme.darkGreen,
                ),
                subtitle: Row(
                  children: [
                    _filteredTests[index].discountedPrice <
                            _filteredTests[index].price
                        ? Text.rich(TextSpan(
                            text: 'Rs ',
                            style: AppTextTheme.textTheme14Light.apply(
                              color: _isTestSelected(_filteredTests[index])
                                  ? ColorTheme.buttonColor
                                  : ColorTheme.darkGreen,
                            ),
                            children: [
                              TextSpan(
                                  text:
                                      '${Utils.formatAmount(_filteredTests[index].price)}',
                                  style: AppTextTheme.textTheme14Light.apply(
                                    color:
                                        _isTestSelected(_filteredTests[index])
                                            ? ColorTheme.buttonColor
                                            : Colors.black38,
                                    decoration: TextDecoration.lineThrough,
                                  )),
                              TextSpan(
                                text:
                                    ' ${Utils.formatAmount(_filteredTests[index].discountedPrice)}',
                                style: AppTextTheme.textTheme14Light.apply(
                                  color: _isTestSelected(_filteredTests[index])
                                      ? ColorTheme.buttonColor
                                      : ColorTheme.darkGreen,
                                ),
                              ),
                            ],
                          ))
                        : TextView(
                            text:
                                'Rs ${Utils.formatAmount(_filteredTests[index].price)}',
                            style: AppTextTheme.textTheme14Light,
                            color: _isTestSelected(_filteredTests[index])
                                ? ColorTheme.buttonColor
                                : ColorTheme.darkGreen,
                            maxLine: 1,
                          ),
                    InkWell(
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        bool result = await showDialog(
                            context: context,
                            builder: (_) => TestDetailScreen(
                                  istest: _filteredTests[index].testId !=
                                      null, //TODO
                                  labtest: _filteredTests[index],
                                  lab: null,
                                ));

                        if (result != null && result) {
                          setState(() {
                            _filteredTests[index].testId != null
                                ? _selectedTest
                                    .add(_filteredTests[index].testId)
                                : _selectedProfile
                                    .add(_filteredTests[index].profileId);
                          });
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12, 8, 16, 8),
                        child: TextView(
                          text: 'DETAILS',
                          style: AppTextTheme.textTheme12Bold,
                          //fontStyle: FontStyle.italic,
                          color: _isTestSelected(_filteredTests[index])
                              ? ColorTheme.buttonColor
                              : Colors.black38,
                          maxLine: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                value: _isTestSelected(_filteredTests[index]),
                onChanged: (bool isSelected) => setState(() {
                  FocusScope.of(context).unfocus();
                  _toggleTestSelection(_filteredTests[index]);
                }),
                secondary: _isTestSelected(_filteredTests[index])
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          color: ColorTheme.buttonColor,
                          child: Icon(
                            Icons.check,
                            size: 32,
                            color: ColorTheme.white,
                          ),
                        ),
                      )
                    : Image.asset(
                        AppAssets.tests,
                        height: 40,
                        width: 40,
                        //color: ColorTheme.darkGreen,
                      ),
              );
            },
            itemCount: _filteredTests.length,
          ),
        ),
      ],
    );
  }

  Widget _buildPatients() {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
      itemBuilder: (context, index) {
        if (index < _users.length) {
          var user = _users[index];
          return ListTile(
            title: TextView(
              text: '${user.fullName}',
              style: AppTextTheme.textTheme16Regular,
              color: _selectedPatient == user.patid
                  ? ColorTheme.buttonColor
                  : ColorTheme.darkGreen,
            ),
            subtitle: TextView(
              text: '(${user.sex} / ${Utils.getYears(date: user.dob)} years)',
              style: AppTextTheme.textTheme14Light,
              color: _selectedPatient == user.patid
                  ? ColorTheme.buttonColor
                  : ColorTheme.darkGreen,
            ),
            trailing: Radio(
              value: user.patid,
              groupValue: _selectedPatient,
              activeColor: ColorTheme.buttonColor,
              onChanged: (value) {
                setState(() {
                  _selectedPatient = value;
                });
              },
            ),
            leading: Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.only(right: 12),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _selectedPatient == user.patid
                      ? Container(
                          width: 40,
                          height: 40,
                          color: ColorTheme.buttonColor,
                          child: Icon(
                            Icons.check,
                            size: 30,
                            color: ColorTheme.white,
                          ),
                        )
                      : user.profile_pic.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: user.profile_pic,
                              fit: BoxFit.fill,
                              httpHeaders: Utils.getHeaders(),
                            )
                          : Container(
                              width: 40,
                              height: 40,
                              color: Colors.black12,
                              child: Icon(
                                Icons.person_outlined,
                                size: 30,
                                color: ColorTheme.darkGreen,
                              ),
                            )),
            ),
          );
        } else {
          return InkWell(
            onTap: () async {
              bool isUpdated =
                  await Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) => UserFormScreen(
                            false,
                            quickAdd: true,
                          )));
              if (isUpdated != null && isUpdated) {
                List<Datum> dbData = await AppDatabase.db.getUsers();
                if (dbData != null && dbData.length > 0) {
                  print("ADDED: ${dbData.length}");
                  setState(() {
                    _users.clear();
                    _users.addAll(dbData);
                  });
                }
              }
            },
            child: ListTile(
              title: TextView(
                text: '   Add new patient',
                style: AppTextTheme.textTheme16Regular,
                color: ColorTheme.darkGreen,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  color: Colors.black12,
                  child: Icon(
                    Icons.add,
                    size: 32,
                    color: ColorTheme.buttonColor,
                  ),
                ),
              ),
            ),
          );
        }
      },
      itemCount: _users.length + 1,
    );
  }

  Widget _buildLocation() {
    return Column(
      children: [
        Card(
            child: Row(
          children: [
            Radio<int>(
              value: 0,
              groupValue: _addressType,
              onChanged: (value) => setState(() => _addressType = value),
            ),
            TextView(text: "Home", style: AppTextTheme.textTheme14Regular),
            SizedBox.square(dimension: 12),
            Radio<int>(
              value: 1,
              groupValue: _addressType,
              onChanged: (value) => setState(() => _addressType = value),
            ),
            TextView(text: "Lab", style: AppTextTheme.textTheme14Regular),
          ],
        )),
        if (_addressType == 0)
          _addressState == LoadingState.Success
              ? Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
                    itemBuilder: (context, index) {
                      //print("ANAMOY: $index");
                      if (index < _addresses.length) {
                        var address = _addresses[index];
                        return ListTile(
                          title: TextView(
                            text: '${_mapAddress(address)}',
                            style: AppTextTheme.textTheme16Regular,
                            color: _selectedAddress != null &&
                                    _selectedAddress.id == address.id
                                ? ColorTheme.buttonColor
                                : ColorTheme.darkGreen,
                          ),
                          subtitle: TextView(
                            text: '[${address.type}]',
                            style: AppTextTheme.textTheme14Light,
                            color: _selectedAddress != null &&
                                    _selectedAddress.id == address.id
                                ? ColorTheme.buttonColor
                                : ColorTheme.darkGreen,
                          ),
                          trailing: Radio(
                            value: address,
                            groupValue: _selectedAddress,
                            activeColor: ColorTheme.buttonColor,
                            onChanged: (value) {
                              setState(() {
                                _selectedAddress = value;
                              });
                            },
                          ),
                          leading: Container(
                            width: 40,
                            height: 40,
                            margin: EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 40,
                                height: 40,
                                color: _selectedAddress != null &&
                                        _selectedAddress.id == address.id
                                    ? ColorTheme.buttonColor
                                    : Colors.black12,
                                child: Icon(
                                  _selectedAddress != null &&
                                          _selectedAddress.id == address.id
                                      ? Icons.check
                                      : Icons.home_outlined,
                                  size: 30,
                                  color: _selectedAddress != null &&
                                          _selectedAddress.id == address.id
                                      ? ColorTheme.white
                                      : ColorTheme.darkGreen,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return InkWell(
                          onTap: () async {
                            if (_selectedPatient > 0) {
                              bool isUpdated = await showDialog(
                                  context: context,
                                  builder: (_) => EditAddressDialog(
                                      patient: _selectedPatient));
                              if (isUpdated != null && isUpdated) {
                                _loadAddress(_selectedPatient);
                              }
                            }
                          },
                          child: ListTile(
                            title: TextView(
                              text: '   Add new address ',
                              style: AppTextTheme.textTheme16Regular,
                              color: ColorTheme.darkGreen,
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 40,
                                height: 40,
                                color: Colors.black12,
                                child: Icon(
                                  Icons.add,
                                  size: 32,
                                  color: ColorTheme.buttonColor,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    itemCount: _addresses.length + 1,
                  ),
                )
              : _addressState == LoadingState.Failure
                  ? Expanded(
                      child: Center(
                        child: TextView(
                          text: 'Failed to load addresses.\nPlease try later.',
                          style: AppTextTheme.textTheme16Regular,
                          color: ColorTheme.darkRed,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : Expanded(
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextView(
                              text: 'Loading addresses',
                              style: AppTextTheme.textTheme16Regular,
                              color: ColorTheme.darkGreen,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: ColorTheme.darkGreen),
                            ),
                          ],
                        ),
                      ),
                    )
        else
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(0, 8, 0, 8),
              itemBuilder: (context, index) {
                //print("ANAMOY: $index");
                var lab = _labs[index];
                return ListTile(
                  title: TextView(
                    text: '${lab.labName}',
                    style: AppTextTheme.textTheme16Regular,
                    color: _selectedLab == lab.labId
                        ? ColorTheme.buttonColor
                        : ColorTheme.darkGreen,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextView(
                        text: _formatLabAddress(lab),
                        style: AppTextTheme.textTheme14Light,
                        color: _selectedLab == lab.labId
                            ? ColorTheme.buttonColor
                            : ColorTheme.darkGreen,
                      ),
                      InkWell(
                        onTap: () => MyApplication.navigateToWebPage(
                            'Map', lab.googleLocation),
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(4, 8, 16, 16),
                            child: TextView(
                              text: "DIRECTIONS",
                              style: AppTextTheme.textTheme12Regular,
                              //fontStyle: FontStyle.italic,
                              color: Colors.black38,
                            )),
                      ),
                    ],
                  ),
                  trailing: Radio(
                    value: lab.labId,
                    groupValue: _selectedLab,
                    activeColor: ColorTheme.buttonColor,
                    onChanged: (labId) {
                      setState(() {
                        _selectedLab = labId;
                      });
                    },
                  ),
                  leading: Container(
                    width: 40,
                    height: 40,
                    margin: EdgeInsets.only(right: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 40,
                        height: 40,
                        color: _selectedLab == lab.labId
                            ? ColorTheme.buttonColor
                            : Colors.black12,
                        child: Icon(
                          _selectedLab == lab.labId
                              ? Icons.check
                              : Icons.science_outlined,
                          size: 30,
                          color: _selectedLab == lab.labId
                              ? ColorTheme.white
                              : ColorTheme.darkGreen,
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: _labs.length,
            ),
          ),
      ],
    );
  }

  Widget _buildDateTime() {
    return ListView(
      controller: _controller,
      children: [
        Card(
          child: Row(
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(
                    Icons.calendar_month,
                    size: 18,
                  )),
              _getMonths(),
            ],
          ),
        ),
        SizedBox(
          height: 16,
        ),
        ConstrainedBox(
          child: _getCalendarView(),
          constraints: BoxConstraints(maxHeight: 350, minHeight: 330),
        ),
        SizedBox(
          height: 24,
        ),
        for (int i = 0; i < _slots.length; i++)
          InkWell(
            onTap: () {
              setState(() {
                _selectedSlot = _slots[i];
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              padding: EdgeInsets.all(12),
              decoration: new BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    width: _selectedSlot != null &&
                            _selectedSlot.id == _slots[i].id
                        ? 2
                        : 1,
                    color: _selectedSlot != null &&
                            _selectedSlot.id == _slots[i].id
                        ? ColorTheme.buttonColor
                        : Colors.black26),
              ),
              child: _selectedSlot != null && _selectedSlot.id == _slots[i].id
                  ? AppText.getLightText(
                      "${_slots[i].collectionSlot}", 14, ColorTheme.buttonColor)
                  : AppText.getLightText(
                      "${_slots[i].collectionSlot}", 14, Colors.black87),
            ),
          ),
      ],
    );
  }

  Widget _getMonths() {
    return DropdownButton(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      icon: Icon(
        Icons.keyboard_arrow_down,
        size: 24,
      ),
      underline: Container(),
      value: _monthValue,
      items: time.map((e) {
        return DropdownMenuItem(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text(
              DateFormat.yMMM().format(e),
              style: AppTextTheme.textTheme14Bold,
            ),
          ),
          value: time.indexOf(e),
        );
      }).toList(),
      onChanged: (value) {
        _monthValue = value;
        var date = time[value];
        if (value == 0) {
          _currentDate = DateTime.now();
          _selectedDate = DateTime.now();
        } else {
          _currentDate = DateTime(date.year, date.month, 1);
          _selectedDate = _currentDate;

          ///_selectedDate was getting null.
          ///issue date
        }
        setState(() {});
      },
    );
  }

  String _formatLabAddress(Lab lab) {
    var distance = -1.0;
    if (_labDistances.containsKey(lab.labId)) {
      distance = _labDistances[lab.labId];
    }
    return (distance > 0.0)
        ? '${lab.labAddress}\n(${Utils.formatAmount(distance / 1000)} km away)'
        : '${lab.labAddress}';
  }

  void _toggleTestSelection(Labtest test) {
    if (test.testId != null) {
      if (_selectedTest.contains(test.testId))
        _selectedTest.remove(test.testId);
      else
        _selectedTest.add(test.testId);
    } else {
      if (_selectedProfile.contains(test.profileId))
        _selectedProfile.remove(test.profileId);
      else
        _selectedProfile.add(test.profileId);
    }
  }

  bool _isTestSelected(Labtest test) {
    return (test.testId != null && _selectedTest.contains(test.testId)) ||
        (test.profileId != null && _selectedProfile.contains(test.profileId));
  }

  Widget _getCalendarView() {
    return Container(
      key: UniqueKey(),
      child: CalendarCarousel<Event>(
        pageScrollPhysics: NeverScrollableScrollPhysics(),
        onDayPressed: (DateTime date, List<Event> events) {
          _selectedDate = date;

          for (int i = 0; i < time.length; i++) {
            var element = time[i];
            var month = DateFormat('yyyy-MM-dd').format(element).split('-')[1];
            var month1 =
                DateFormat('yyyy-MM-dd').format(_selectedDate).split('-')[1];
            if (month == month1) {
              _monthValue = time.indexOf(element);
              break;
            }
          }

          _controller.animateTo(100.0 * 9,
              duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);
          setState(() {});
        },
        selectedDateTime: _selectedDate,
        selectedDayTextStyle: TextStyle(color: Colors.white),
        selectedDayButtonColor: ColorTheme.buttonColor,
        weekdayTextStyle: TextStyle(
          fontSize: 14,
          color: ColorTheme.darkGreen.withOpacity(0.8),
          fontWeight: FontWeight.bold,
        ),
        weekendTextStyle: TextStyle(
          fontSize: 14,
          color: ColorTheme.darkGreen.withOpacity(0.8),
          fontWeight: FontWeight.bold,
        ),
        weekFormat: false,
        isScrollable: true,
        customGridViewPhysics: NeverScrollableScrollPhysics(),
        dayPadding: 4.0,
        showHeader: false,
        weekDayFormat: WeekdayFormat.standaloneShort,
        daysHaveCircularBorder: false,
        minSelectedDate:
            DateTime(_currentDate.year, _currentDate.month, _currentDate.day),
        todayButtonColor: Colors.transparent,
        todayBorderColor: Colors.transparent,
        todayTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        maxSelectedDate: DateTime(_currentDate.year, _currentDate.month + 1, 0),
        daysTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        dayButtonColor: Colors.transparent,
      ),
    );
  }

  void _loadData() async {
    Loader.showProgress();
    DateTime data = DateTime.now();
    for (int i = 0; i < 3; i++) {
      time.add(data.add(Duration(days: i * 30)));
    }

    final labSelectionRepo = LabSelectionRepo();
    final labsModel = await labSelectionRepo.getLabs();
    if (labsModel != null && labsModel.success == 'true') {
      _labs = labsModel.labs;
    }

    final labTestRepo = LabTestRepo();
    var labTestModel = await labTestRepo.getLabTset('0');
    _tests.clear();
    if (labTestModel != null && labTestModel.success == 'true') {
      _tests.addAll(labTestModel.labtest);
    }
    labTestModel = await labTestRepo.getProfileTest('0');
    if (labTestModel != null && labTestModel.success == 'true') {
      _tests.addAll(labTestModel.labtest);
    }
    _filteredTests = _tests;

    _frequentTests.clear();
    final freqTestsModel = await labTestRepo.getFrequentlyAskedTest('0');
    if (freqTestsModel != null && freqTestsModel.success == 'true') {
      _frequentTests.addAll(freqTestsModel.labtest);
    }

    final labSlotModel = await labTestRepo.getLabSlots();
    if (labSlotModel != null && labTestModel.success == 'true') {
      _slots = labSlotModel.slots;
    }

    List<Datum> dbData = await AppDatabase.db.getUsers();
    _users.clear();
    if (dbData != null && dbData.length > 0) {
      _users.addAll(dbData);
    }

    Loader.hide();
    setState(() {
      if (_labs.isNotEmpty &&
          _tests.isNotEmpty &&
          _frequentTests.isNotEmpty &&
          _slots.isNotEmpty &&
          _users.isNotEmpty)
        _dataState = LoadingState.Success;
      else
        _dataState = LoadingState.Failure;
    });
  }

  void _loadAddress(int patientId) async {
    setState(() {
      _addresses.clear();
      _selectedAddress = null;
      _lastPatientAddress = 0;
      _addressState = LoadingState.Loading;
    });
    var addresses = <AddressDatum>[];
    try {
      final tempData =
          await AppDatabase.db.getUser(patientId.toString()) as Datum;
      if (tempData != null) {
        addresses.add(AddressDatum(
          id: 0,
          patient: tempData.patid,
          typeId: 0,
          type: 'Primary',
          address1: tempData.address1,
          address2: tempData.address2,
          city: tempData.city,
          state: tempData.state,
          country: tempData.country,
          pinCode: tempData.pincode,
          landmark: '',
        ));
      }
      final patientRepo = PatientRepo();
      AddressModel addressModel =
          await patientRepo.getAddresses(patientId: patientId.toString());
      if (addressModel != null && addressModel.success == 'true') {
        addresses.addAll(addressModel.addresses);
      }
    } catch (_) {}
    await Future.delayed(Duration(seconds: 5));
    setState(() {
      if (addresses.isNotEmpty) {
        _addresses = addresses;
        _lastPatientAddress = patientId;
        _addressState = LoadingState.Success;
      } else {
        _addressState = LoadingState.Failure;
      }
    });
  }

  String _mapAddress(AddressDatum address) {
    StringBuffer buffer = StringBuffer();
    if (address.address1 != null && address.address1.isNotEmpty) {
      buffer.write(address.address1);
      buffer.write(', ');
    }
    if (address.address2 != null && address.address2.isNotEmpty) {
      buffer.write(address.address2);
      buffer.write(', ');
    }
    if (address.landmark != null && address.landmark.isNotEmpty) {
      buffer.write("Landmark: ${address.landmark}".trim());
      buffer.write(', ');
    }
    if (address.city != null && address.city.isNotEmpty) {
      buffer.write("${address.city}, ".trim());
      buffer.write(', ');
    }
    if (address.state != null && address.state.isNotEmpty) {
      buffer.write("${address.state}".trim());
      buffer.write(', ');
    }
    if (address.country != null && address.country.isNotEmpty) {
      buffer.write("${address.country}, ".trim());
      buffer.write(', ');
    }
    if (address.pinCode != null && address.pinCode.isNotEmpty) {
      buffer.writeln("PIN: ${address.pinCode}".trim());
    }

    if (buffer.isEmpty)
      return 'Invalid address data';
    else
      return buffer.toString().trim();
  }

  bool _validate() {
    if (_selectedTest.isEmpty && _selectedProfile.isEmpty) {
      Utils.showToast(message: "Please select test(s)");
      return false;
    } else if (_selectedPatient <= 0) {
      Utils.showToast(message: "Please select patient");
      return false;
    } else if (_addressType == 0 && _selectedAddress == null) {
      Utils.showToast(message: "Please select address");
      return false;
    } else if (_addressType == 1 && _selectedLab <= 0) {
      Utils.showToast(message: "Please select lab");
      return false;
    } else if (_selectedDate == null || _selectedSlot == null) {
      Utils.showToast(message: "Please select date/time");
      return false;
    }
    return true;
  }

  void _filterTests() {
    String val = _isSearchOpen ? _testSearchController.text : '';
    setState(() {
      if (val.isEmpty) {
        if (_selectedTestType == typeIndividual) {
          _filteredTests =
              _tests.where((test) => test.testName != null).toList();
        } else if (_selectedTestType == typeProfile) {
          _filteredTests =
              _tests.where((test) => test.profileName != null).toList();
        } else {
          _filteredTests = _tests;
        }
      } else {
        if (_selectedTestType == typeIndividual) {
          _filteredTests = _tests
              .where((test) =>
                  test.testName != null &&
                  test.testName.toLowerCase().contains(val.toLowerCase()))
              .toList();
        } else if (_selectedTestType == typeProfile) {
          _filteredTests = _tests
              .where((test) =>
                  test.profileName != null &&
                  test.profileName.toLowerCase().contains(val.toLowerCase()))
              .toList();
        } else {
          _filteredTests = _tests
              .where((test) =>
                  (test.testName != null &&
                      test.testName
                          .toLowerCase()
                          .contains(val.toLowerCase())) ||
                  (test.profileName != null &&
                      test.profileName
                          .toLowerCase()
                          .contains(val.toLowerCase())))
              .toList();
        }
      }
    });
  }

  Widget _buildBottomOptions() {
    return _tabIndex == pageTest &&
            (_selectedTest.isNotEmpty || _selectedProfile.isNotEmpty)
        ? Container(
            padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
            decoration: new BoxDecoration(
              color: ColorTheme.lightGreenOpacity,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ColorTheme.buttonColor),
            ),
            child: AppText.getLightText(
                "Selected: ${_selectedTest.length + _selectedProfile.length}",
                14,
                Colors.black87),
          )
        : (_tabIndex == pageTime &&
                _selectedDate != null &&
                _selectedSlot != null)
            ? Container(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                decoration: new BoxDecoration(
                  color: ColorTheme.lightGreenOpacity,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorTheme.buttonColor),
                ),
                child: AppText.getLightText(
                    "${DateFormat.MMMd().format(_selectedDate)}, ${_selectedSlot.collectionSlot}",
                    14,
                    Colors.black87),
              )
            : SizedBox.shrink();
  }

  _getCurrentLocation() async {
    try {
      final position = await _addressService.getCurrentLocation();
      if (position.latitude != 0.0 || position.longitude != 0.0) {
        setState(() {
          _currentLocation = position;
          _sortLabs();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _sortLabs() async {
    if (_labs != null && _currentLocation != null) {
      Geolocator geolocator = Geolocator();
      for (var lab in _labs) {
        _labDistances[lab.labId] = await geolocator.distanceBetween(
            _currentLocation.latitude,
            _currentLocation.longitude,
            double.parse(lab.latitude),
            double.parse(lab.longitude));
      }
      setState(() {
        _labs.sort(
          (first, second) =>
              _labDistances[first.labId].compareTo(_labDistances[second.labId]),
        );
      });
    }
  }
}
