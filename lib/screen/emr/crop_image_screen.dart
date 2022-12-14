import 'dart:io';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';
import 'package:path_provider/path_provider.dart';

class CropImageScreen extends StatefulWidget {
  final String source;

  CropImageScreen(this.source);

  @override
  _CropImageScreenState createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  final CropController _cropController = CropController(
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );

  @override
  void dispose() {
    _cropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar('Crop image',
          action: IconButton(
            icon: Icon(
              Icons.check_circle,
              color: ColorTheme.buttonColor,
              size: 36,
            ),
            onPressed: () async {
              Loader.showProgress();
              final outPath = await _crop();
              Loader.hide();
              Navigator.of(context).pop(outPath);
            },
          )),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: CropImage(
            controller: _cropController,
            image: Image.file(File(widget.source)),
          ),
        ),
      ),
    );
  }

  Future<String> _crop() async {
    Directory tempFolder = await getTemporaryDirectory();
    if (!await tempFolder.exists()) {
      tempFolder.create(recursive: true);
    }
    final fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
    final outputFile = File('${tempFolder.path}/$fileName');
    ui.Image image = await _cropController.croppedBitmap();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    await outputFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    return outputFile.path;
  }
}
