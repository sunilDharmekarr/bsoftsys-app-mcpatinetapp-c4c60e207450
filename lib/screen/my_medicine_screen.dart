import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/model/CurrentMedicineModel.dart';
import 'package:mumbaiclinic/model/PreviousMedicineModel.dart';
import 'package:mumbaiclinic/repository/medicine_repo.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';
import 'package:share/share.dart';

class MyMedicineScreen extends StatefulWidget {
  @override
  _MyMedicineScreenState createState() => _MyMedicineScreenState();
}

class _MyMedicineScreenState extends State<MyMedicineScreen> {
  final medicineRepo = MedicineRepo();
  int currentIndex = 0;
  List<CurrentMedicine> _currentMedicine = [];
  List<PreviousMedicine> _listMedicines = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar('My Medicines'),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                      child: AppText.getBoldText(
                          'Current Medicine'.toUpperCase(),
                          16,
                          ColorTheme.darkGreen)),
                  IconButton(
                    onPressed: () {
                      if (_currentMedicine.length > 0) {
                        _shareCurrentMedicine();
                      }
                    },
                    iconSize: 24,
                    icon: Icon(
                      Icons.share,
                      color: ColorTheme.iconColor,
                    ),
                  )
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                _currentMedicine.length == 0
                    ? <Widget>[
                        Center(child: AppText.getErrorText('No Data.', 16))
                      ]
                    : _currentMedicine
                        .map<Widget>(
                          (e) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText.getTitleText(
                                    e.medicineName, 16, ColorTheme.darkGreen),
                                const SizedBox(
                                  height: 4,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    AppText.getRegularText(
                                      '${e.doseRegimen}',
                                      14,
                                      ColorTheme.darkGreen,
                                      maxline: 1,
                                    ),
                                    AppText.getRegularText(
                                      '${e.days}',
                                      14,
                                      ColorTheme.darkGreen,
                                      maxline: 1,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Divider(
                                  color: ColorTheme.darkGreen,
                                ),
                                //AppText.getLightText(e.days, 12, ColorTheme.darkGreen)
                              ],
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 20,
              ),
            ),
            SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                      child: AppText.getBoldText(
                          'Previous Medicine'.toUpperCase(),
                          16,
                          ColorTheme.darkGreen)),
                  IconButton(
                    onPressed: () {
                      if (_listMedicines.length > 0) {
                        _sharePreviousMedicine();
                      }
                    },
                    iconSize: 24,
                    icon: Icon(
                      Icons.share,
                      color: ColorTheme.iconColor,
                    ),
                  )
                ],
              ),
            ),
            if (_listMedicines.length == 0)
              SliverToBoxAdapter(
                child: Center(child: AppText.getErrorText('No Data.', 16)),
              ),
            if (_listMedicines.length > 0)
              SliverToBoxAdapter(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: ColorTheme.darkGreen,
                      ),
                      onPressed: () {
                        if (currentIndex != _listMedicines.length - 1) {
                          currentIndex += 1;
                          print("index: $currentIndex");

                          setState(() {});
                        }
                      },
                    ),
                    Container(
                        child: AppText.getBoldText(
                            Utils.getReadableDate(
                                _listMedicines[currentIndex].date),
                            14,
                            ColorTheme.darkGreen)),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: ColorTheme.darkGreen,
                      ),
                      onPressed: () {
                        if (currentIndex != 0) {
                          currentIndex -= 1;
                          print("index: $currentIndex");
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
            if (_listMedicines.length > 0)
              SliverList(
                delegate: SliverChildListDelegate(
                  _listMedicines[currentIndex]
                      .medicines
                      .map<Widget>(
                        (e) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.getTitleText(
                                  e.medicineName, 16, ColorTheme.darkGreen),
                              const SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  AppText.getRegularText(
                                    '${e.doseRegimen}',
                                    14,
                                    ColorTheme.darkGreen,
                                    maxline: 1,
                                  ),
                                  AppText.getRegularText(
                                    '${e.days}',
                                    14,
                                    ColorTheme.darkGreen,
                                    maxline: 1,
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Divider(
                                color: ColorTheme.darkGreen,
                              ),
                              //AppText.getLightText(e.days, 12, ColorTheme.darkGreen)
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _getData() async {
    Loader.showProgress();
    final current = await medicineRepo.getCurrentMedicines();
    final previous = await medicineRepo.getPreviousMedicines();
    Loader.hide();
    setState(() {
      if (current != null) {
        _currentMedicine = current.currentMedicine;
      }
      if (previous != null) {
        _listMedicines = previous.previousMedicine;
      }
    });
  }

  _shareCurrentMedicine() async {
    //Current Medicines
    // DOLO 650 ( 1-0-1 )  5Days
    // DOLO 650 ( 1-0-1 )  5Days
    // DOLO 650 ( 1-0-1 )  5Days
    // DOLO 650 ( 1-0-1 )  5Days
    String medicine = '';
    _currentMedicine.forEach((element) {
      medicine +=
          "\n${element.medicineName} (${element.doseRegimen}) ${element.days}";
    });
    String message = '''
        Current Medicines
        $medicine 
        ''';
    final RenderBox box = context.findRenderObject();
    await Share.share(message,
        subject: 'My Medicines',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  _sharePreviousMedicine() async {
    //Current Medicines
    String medicine = '';
    String date = Utils.getReadableDate(_listMedicines[currentIndex].date);
    _listMedicines[currentIndex].medicines.forEach((element) {
      medicine +=
          "\n${element.medicineName} (${element.doseRegimen}) ${element.days}";
    });
    String message = '''
        Past Medicines ($date)
        $medicine 
        ''';
    final RenderBox box = context.findRenderObject();
    await Share.share(message,
        subject: 'My Medicines',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}
