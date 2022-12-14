import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/screen/emr/crop_image_screen.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class CaptureReportScreen extends StatefulWidget {
  @override
  _CaptureReportScreenState createState() => _CaptureReportScreenState();
}

class _CaptureReportScreenState extends State<CaptureReportScreen> {
  var _images = <String>[];
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar('Capture report',
          action: IconButton(
            icon: Icon(
              Icons.check_circle,
              color: ColorTheme.buttonColor,
              size: 36,
            ),
            onPressed: () async {
              if (_images.isEmpty) {
                Utils.showToast(message: 'Please add images');
              } else {
                Loader.showProgress();
                final outPath = await _createPdf();
                Loader.hide();
                Navigator.of(context).pop(outPath);
              }
            },
          )),
      body: Column(children: [
        Expanded(
            child: Center(
          child: _generateBody(),
        )),
        Container(
          width: double.infinity,
          height: 50,
          color: ColorTheme.white,
          margin: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: _captureImage,
            child: AppText.getBoldText(
              'Add page',
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
      ]),
    );
  }

  Widget _generateBody() {
    if (_images.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
            ),
            AppText.getLightText(
                'Please capture images to be added to the report.',
                14,
                Colors.black87,
                textAlign: TextAlign.center),
          ],
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        width: 150,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _images.length,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.all(5),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    File(_images[index]),
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () => setState(() {
                      _images.removeAt(index);
                    }),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: ColorTheme.buttonColor,
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      child: Icon(
                        Icons.close,
                        color: ColorTheme.white,
                        size: 24,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }

  Future _captureImage() async {
    final pickedFile = await picker.pickImage(
        source: ImageSource.camera, maxWidth: 1200, maxHeight: 1200);

    if (pickedFile != null) {
      String croppedImage = await Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => CropImageScreen(pickedFile.path),
        ),
      );
      if (croppedImage != null && croppedImage.length > 0) {
        setState(() {
          _images.add(croppedImage);
        });
      }
    }
  }

  Future<String> _createPdf() async {
    var pdf = await compute(createPdfBg, _images);

    Directory tempFolder = await getTemporaryDirectory();
    if (!await tempFolder.exists()) {
      tempFolder.create(recursive: true);
    }
    final fileName = "${DateTime.now().millisecondsSinceEpoch}.pdf";
    final outputFile = File('${tempFolder.path}/$fileName');
    await outputFile.writeAsBytes(await pdf.save(), flush: true);
    final len = await outputFile.length();
    return outputFile.path;
  }

  static pw.Document createPdfBg(List<String> images) {
    final pdf = pw.Document();
    for (final image in images) {
      final bytes = File(image).readAsBytesSync();
      final pdfImage = pw.MemoryImage(bytes, dpi: 72);
      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(pdfImage),
        ); // Center
      }));
    }
    return pdf;
  }
}
