import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/url_to_share_model.dart';
import 'package:mumbaiclinic/repository/emr_repository.dart';
import 'package:mumbaiclinic/utils/PermissionUtils.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewPrescriptionScreen extends StatefulWidget {
  final String path;
  final String title;
  ViewPrescriptionScreen(this.path, {this.title = 'Prescription'});

  @override
  _ViewPrescriptionScreenState createState() => _ViewPrescriptionScreenState();
}

class _ViewPrescriptionScreenState extends State<ViewPrescriptionScreen> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  String filePath = '';
  bool pdf = true;
  int pages = 0;
  int currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  Uint8List data;
  final emrRepository = EMRRepository();
  String url_to_share = '';

  @override
  void initState() {
    super.initState();
    print("file sharable url called");
    toGetURL();
    pdf = widget.path.toLowerCase().contains('pdf');
    if (pdf) Future.delayed(Duration(milliseconds: 300), _requestPermission);
  }

  toGetURL() async {
    ///Get sharable url
    ///
    UrlToShare urlToShare =
        await emrRepository.getFileURLToShare('${widget.path}');
    if (urlToShare.payload != null) {
      url_to_share = urlToShare.payload;
      print("----FILE_FOUND---- $url_to_share");
    } else {
      print("----NO_FILE----");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar('${widget.title}'),
      body: Column(children: [
        Expanded(
            child: Container(
          padding: const EdgeInsets.all(10),
          child: pdf ? _getPdfView() : _getImageView(),
        )),
        ElevatedButton(
          onPressed: () {
            _launchURL();
          },
          style: ElevatedButton.styleFrom(
            primary: ColorTheme.buttonColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: AppText.getLightText('Share', 12, ColorTheme.white),
        )
      ]),
    );
  }

  Widget _getPdfView() {
    if (filePath.isEmpty)
      return Container();
    else
      return Stack(
        children: <Widget>[
          PDFView(
            filePath: filePath,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: currentPage,
            fitPolicy: FitPolicy.WIDTH,
            preventLinkNavigation:
                false, // if set to true the link is handled in flutter
            onRender: (_pages) {
              setState(() {
                pages = _pages;
                isReady = true;
              });
              _requestPermission();
            },
            onError: (error) {
              setState(() {
                errorMessage = error.toString();
              });
              print(error.toString());
            },
            onPageError: (page, error) {
              setState(() {
                errorMessage = '$page: ${error.toString()}';
              });
              print('$page: ${error.toString()}');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String uri) {},
            onPageChanged: (int page, int total) {
              setState(() {
                currentPage = page;
              });
            },
          ),
          errorMessage.isEmpty
              ? !isReady
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Text(errorMessage),
                )
        ],
      );
  }

  Widget _getImageView() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: CachedNetworkImage(
        fit: BoxFit.contain,
        httpHeaders: Utils.getHeaders(),
        imageUrl: "${widget.path}",
        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => Center(
          child: Image.asset(
            AppAssets.my_consult,
            fit: BoxFit.contain,
            color: Colors.grey,
            width: 100,
            height: 100,
          ),
        ),
      ),
    );
  }

  createFileOfPdfUrl() async {
    try {
      final url = "${widget.path}";
      final filename = '${url.split('/').last}'.replaceAll('\\', '_');
      // final localDirectory = await FileUtils.instance.getSavePath();
      // File savedPath = File('${localDirectory}/$filename');

      // if (await savedPath.exists()) {
      //   filePath = savedPath.path;
      // } else {
      var response =
          await get(Uri.parse(widget.path), headers: Utils.getHeaders());
      data = response.bodyBytes;
      var bytes = response.bodyBytes;
      var dir = await getApplicationSupportDirectory();
      PreferenceManager.setFilePath('${dir.path}');
      File file = File("${dir.path}/$filename");

      await file.writeAsBytes(bytes, flush: true);

      filePath = file.path;
      // _download();
      // }
    } catch (e) {
      print(e.toString());
      filePath = '';
    }
    setState(() {});
  }

  _requestPermission() async {
    final status = true;
    // await PermissionUtils.instance.requestPermission(Permission.storage);

    if (status) createFileOfPdfUrl();
  }

  // _download()async{
  //   final url = "${widget.path}";
  //   final filename = '${url.split('/').last}'.replaceAll('\\', '_');
  //   final saved = await FileUtils.instance.save(filename, data);
  //
  // }

  _launchURL() {
    if (canLaunch('url_to_share') != null) {
      launch(url_to_share);
    } else {
      Utils.showAlertDialog(
          context: context, message: 'Could not share at this moment');
      throw 'Could not launch $url_to_share';
    }
  }
}
