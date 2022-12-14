import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/model/ReportTypeModel.dart';
import 'package:mumbaiclinic/model/response_model.dart';
import 'package:mumbaiclinic/repository/emr_repository.dart';
import 'package:mumbaiclinic/screen/emr/capture_report_screen.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/app_text_field.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class UploadEmrReportScreen extends StatefulWidget {
  final List<ReportType> reportList;

  UploadEmrReportScreen(this.reportList);

  @override
  _UploadEmrReportScreenState createState() => _UploadEmrReportScreenState();
}

class _UploadEmrReportScreenState extends State<UploadEmrReportScreen> {
  final _controller = TextEditingController();
  final emrRepo = EMRRepository();
  File _image;
  File _file;
  final picker = ImagePicker();

  List<ReportType> _reportList = [];
  int reportType = 0;
  String date = '';
  String fileName = '';
  String reportName = '';

  @override
  void initState() {
    super.initState();
    _reportList.clear();
    List<ReportType> temp = List.from(widget.reportList);
    _reportList.addAll(temp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar('Upload Reports'),
      body: Container(
        padding: const EdgeInsets.all(10),
        color: Colors.white,
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  getLabel('Report Type'),
                  Container(
                    height: 50,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ColorTheme.lightGreenOpacity,
                    ),
                    child: DropdownButton(
                      //key: UniqueKey(),
                      onTap: () {
                        FocusScope.of(context).unfocus();
                      },
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down),
                      underline: Container(),
                      value: reportType,
                      onChanged: (value) {
                        setState(() {
                          reportName = _reportList
                              .firstWhere((element) => element.id == value)
                              .name;
                          reportType = value;
                        });
                      },
                      items: _reportList
                          .map<DropdownMenuItem>(
                            (e) => DropdownMenuItem(
                              child: AppText.getLightText(
                                  e.name, 14, ColorTheme.darkGreen,
                                  textAlign: TextAlign.left),
                              value: e.id,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  getLabel('Report Date'),
                  Container(
                    height: 50,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ColorTheme.lightGreenOpacity,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: AppText.getLightText(
                                date, 14, ColorTheme.darkGreen,
                                textAlign: TextAlign.left)),
                        IconButton(
                            icon: Image.asset(
                              AppAssets.calander,
                              color: ColorTheme.iconColor,
                            ),
                            onPressed: () {
                              _showDatePicker();
                            })
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  getLabel('Report Details'),
                  Container(
                    height: 150,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ColorTheme.lightGreenOpacity,
                    ),
                    child: AppTextField(
                      controller: _controller,
                      textHint: '',
                      textInputType: TextInputType.multiline,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {},
                      onSubmit: (value) {
                        FocusScope.of(context).unfocus();
                      },
                      shadow: false,
                      maxLength: 150,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  getLabel('Report'),
                  Container(
                    height: 50,
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ColorTheme.lightGreenOpacity,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppText.getLightText(
                            fileName,
                            14,
                            ColorTheme.darkGreen,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                              color: ColorTheme.buttonColor,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10))),
                          child: IconButton(
                              icon: Image.asset(
                                AppAssets.take_pic,
                                color: ColorTheme.white,
                                width: 24,
                                height: 24,
                              ),
                              onPressed: () {
                                _showImagePicker();
                              }),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    height: 50,
                    color: ColorTheme.white,
                    margin: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        if (validate()) {
                          _upload();
                        }
                      },
                      child: AppText.getBoldText(
                        'Upload',
                        14,
                        ColorTheme.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: ColorTheme.buttonColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  bool validate() {
    if (reportType == 0) {
      Utils.showToast(message: 'Select report type.');
      return false;
    } else if (date.isEmpty) {
      Utils.showToast(message: 'Select report date.');
      return false;
    } else if (_controller.text.toString().trim().isEmpty) {
      Utils.showToast(message: 'Enter comment.');
      return false;
    } else if (_file == null) {
      Utils.showToast(message: 'Attach the report.');
      return false;
    } else
      return true;
  }

  Widget getLabel(text) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: AppText.getBoldText(text, 14, ColorTheme.darkGreen));
  }

  /// using this method for getting date
  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      helpText: "",
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        date = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  _showImagePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: 180,
        decoration: BoxDecoration(
          color: ColorTheme.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          children: [
            Expanded(
                child: Center(
              child:
                  AppText.getButtonText('Camera', 16, Colors.black, () async {
                Navigator.of(context).pop();
                //getImage(1);
                String path = await Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (_) => CaptureReportScreen(),
                  ),
                );
                if (path != null && path.length > 0) {
                  setState(() {
                    fileName = path.split('/').last;
                    _file = File(path);
                  });
                }
              }),
            )),
            Divider(
              color: Colors.grey,
            ),
            Expanded(
                child: Center(
              child: AppText.getButtonText('File', 16, Colors.black, () {
                Navigator.of(context).pop();
                getFile();
              }),
            )),
            Divider(
              color: Colors.grey,
            ),
            Expanded(
                child: Center(
              child: AppText.getButtonText('Cancel', 16, Colors.black, () {
                Navigator.of(context).pop();
              }),
            )),
          ],
        ),
      ),
    );
  }

  /* Future getImage(int type) async {
    final pickedFile = await picker.pickImage(
        source: type == 1 ? ImageSource.camera : ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        fileName = pickedFile.path.split('/').last;
        _file = File(pickedFile.path);
      }
    });
  } */

  Future getFile() async {
    final pickedFile = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: [
      'jpeg',
      'jpg',
      'png',
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
    ]);

    if (pickedFile != null) {
      setState(() {
        PlatformFile file = pickedFile.files.first;
        fileName = file.name;
        _file = File(file.path);
      });
    }
  }

  _upload() async {
    Loader.showProgress();
    final response = await emrRepo.uploadEMRReport(_file.path,
        reportType.toString(), reportName, _controller.text.toString(), date);
    Loader.hide();

    if (response != null) {
      final data = responseModelFromJson(response);
      if (data.success == 'true') {
        Utils.showSingleButtonAlertDialog(
            context: context,
            message: 'Report uploaded successfully',
            onClick: () {
              MyApplication.navigateAndClear('/home');
            });
      } else {
        Utils.showSingleButtonAlertDialog(
          context: context,
          message: 'Failed to upload report: ${data.error}',
        );
      }
    } else {
      Utils.showSingleButtonAlertDialog(
        context: context,
        message: 'Failed to upload report',
      );
    }
  }
}
