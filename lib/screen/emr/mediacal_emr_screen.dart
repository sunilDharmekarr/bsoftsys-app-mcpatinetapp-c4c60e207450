import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/LatestReportModel.dart';
import 'package:mumbaiclinic/model/ReportTypeModel.dart';
import 'package:mumbaiclinic/repository/download_repo.dart';
import 'package:mumbaiclinic/repository/emr_repository.dart';
import 'package:mumbaiclinic/screen/emr/upload_emr_report_screen.dart';
import 'package:mumbaiclinic/screen/view_prescription_screen.dart';
import 'package:mumbaiclinic/utils/PermissionUtils.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/family_vertical_view.dart';
import 'package:permission_handler/permission_handler.dart';

class MedicalEMRScreen extends StatefulWidget {
  @override
  _MedicalEMRScreenState createState() => _MedicalEMRScreenState();
}

class _MedicalEMRScreenState extends State<MedicalEMRScreen>
    with TickerProviderStateMixin {
  final emrRepository = EMRRepository();
  final downloadRepository = DownloadRepo();

  final permission = PermissionUtils.instance;

  List<ReportType> _reportList = [];
  TabController _tabController;
  int currentIndex = 0;
  int reportType = 0;
  String pid = '';
  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    pid = PreferenceManager.getUserId();
    _getReportType();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: ColorTheme.lightGreenOpacity,
        title: Text(
          'Medical Records(EMR)',
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
        color: ColorTheme.lightGreenOpacity,
        child: Column(
          children: [
            FamilyHorizontalView((String ids) {
              setState(() {
                pid = ids;
              });
            }),
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
                  currentIndex = index;
                  setState(() {});
                },
                tabs: ['Latest Report', 'Previous Report']
                    .map(
                      (e) => Tab(
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
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(
              child: _getView(),
            ),
            Container(
                width: double.infinity,
                height: 70,
                color: ColorTheme.white,
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (_) => UploadEmrReportScreen(_reportList)));
                  },
                  child: AppText.getBoldText(
                    'Upload Report',
                    14,
                    ColorTheme.white,
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: ColorTheme.buttonColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _getView() {
    if (currentIndex == 0)
      return Container(
        color: ColorTheme.white,
        child: FutureBuilder(
          future: emrRepository.getLatestEMRReport(pid),
          builder: (_, AsyncSnapshot<LatestReportModel> snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data.latestReport.length == 0)
                return Center(
                  child: AppText.getErrorText('No Data.', 16),
                );
              else
                return ListView.builder(
                  itemBuilder: (_, index) {
                    LatestReport report = snapshot.data.latestReport[index];
                    return CellEmrReport(
                      report: report,
                      onDownload: () {
                        _permission(report.reportPath);
                      },
                    );
                  },
                  itemCount: snapshot.data.latestReport.length,
                );
            } else if (snapshot.hasError) {
              return Center(
                child: AppText.getErrorText('${snapshot.error.toString()}', 16),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      );

    if (currentIndex == 1) {
      return Container(
        color: ColorTheme.white,
        child: Column(
          children: [
            Container(
              height: 50,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ColorTheme.lightGreenOpacity,
              ),
              child: DropdownButton(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down),
                underline: Container(),
                value: reportType,
                onChanged: (value) {
                  setState(() {
                    reportType = value;
                  });
                },
                items: _reportList
                    .map(
                      (e) => DropdownMenuItem(
                        child: Text(
                          '${e.name}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .apply(fontFamily: TextFont.poppinsBold),
                        ),
                        value: e.id,
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: emrRepository.getPreviousEMRReport(pid, '$reportType'),
                builder: (_, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.latestReport.length == 0)
                      return Center(
                        child: AppText.getErrorText('No Data.', 16),
                      );
                    else
                      return ListView.builder(
                        itemBuilder: (_, index) {
                          LatestReport report =
                              snapshot.data.latestReport[index];
                          return CellEmrReport(
                            report: report,
                            onDownload: () {
                              _permission(report.reportPath);
                            },
                          );
                        },
                        itemCount: snapshot.data.latestReport.length,
                      );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: AppText.getErrorText(
                          '${snapshot.error.toString()}', 16),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            )
          ],
        ),
      );
    }
  }

  _permission(String data) async {
    final permissionUtils = PermissionUtils.instance;
    final result = await permissionUtils.requestPermission(Permission.storage);
    if (result != null && result) {
      //  Loader.showProgress();
      // final result =  await downloadRepository.downloadReport(data);
      //  Loader.hide();

      // if(result){
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (_) => ViewPrescriptionScreen(
                data,
                title: 'Medical Records(EMR)',
              )));
      // }
    }
  }

  _getReportType() async {
    //Loader.showProgress();
    final response = await emrRepository.getEMRReportType();
    //Loader.hide();
    _reportList.clear();
    _reportList.add(ReportType(id: 0, name: 'Report Type'));
    if (response != null) {
      if (response.reportType.length > 0) {
        reportType = response.reportType[0].id;
      }
      _reportList.addAll(response.reportType);
    }

    setState(() {});
  }
}

class CellEmrReport extends StatelessWidget {
  final Function onDownload;
  const CellEmrReport({
    Key key,
    @required this.report,
    this.onDownload,
  }) : super(key: key);

  final LatestReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: ColorTheme.lightGreenOpacity,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                  child: AppText.getBoldText(
                      report.reportType, 14, ColorTheme.darkGreen)),
              AppText.getLightText(Utils.getReadableDate(report.reportDate), 12,
                  ColorTheme.darkGreen)
            ],
          ),
          AppText.getLightText(
              '${report.reportDescription}', 14, ColorTheme.darkGreen,
              maxLine: 3, textAlign: TextAlign.start),
          Row(
            children: [
              Expanded(
                  child: AppText.getBoldText('', 14, ColorTheme.darkGreen)),
              ElevatedButton(
                onPressed: () {
                  onDownload?.call();
                },
                style: ElevatedButton.styleFrom(
                  primary: ColorTheme.buttonColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                child: AppText.getLightText('Download', 12, ColorTheme.white),
              )
            ],
          ),
        ],
      ),
    );
  }
}
