import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/platform_interface.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MumbaiWebView extends StatefulWidget {
  final String title;
  final String url;
  final bool actionBar;
  MumbaiWebView({this.title, this.url, this.actionBar = true});

  @override
  _MumbaiWebViewState createState() => _MumbaiWebViewState();
}

class _MumbaiWebViewState extends State<MumbaiWebView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print('_MumbaiWebViewState');
    print('URL -- ${widget.url}');
    _controller.future.then(
        (value) => value.loadUrl(widget.url, headers: Utils.getHeaders1()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.actionBar
          ? AppBar(
              title: Text(
                widget.title,
                style: TextStyle(color: CupertinoColors.black),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            )
          : null,
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            WebView(
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },
              onPageStarted: (String url) {
                print('Web View onPageStarted -->$url');
                isLoading = true;
                setState(() {});
              },
              onPageFinished: (String url) {
                print('Web View onPageFinished -->$url');
                isLoading = false;
                setState(() {});
              },
              onWebResourceError: (WebResourceError error) {
                isLoading = false;
                print('Web View Loading -->${error.description}');
                setState(() {});
              },
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith('mailto:') ||
                    request.url.startsWith('tel:')) {
                  launch(request.url);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
            Align(
              alignment: Alignment.center,
              child: isLoading ? CircularProgressIndicator() : Container(),
            )
          ],
        ),
      ),
    );
  }
}


///----------------------old code---------------------------------------//

/*
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
// import 'package:webview_flutter/platform_interface.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MumbaiWebView extends StatefulWidget {
  final String title;
  final String url;
  final bool actionBar;
  MumbaiWebView({this.title, this.url, this.actionBar = true});

  @override
  _MumbaiWebViewState createState() => _MumbaiWebViewState();
}

class _MumbaiWebViewState extends State<MumbaiWebView> {
  bool isLoading = true;
  InAppWebViewController webView;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    FlutterWebviewPlugin().close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.actionBar
          ? AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: CupertinoColors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      )
          : null,
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            // WebviewScaffold(
            //   url: widget.url,
            //   withLocalStorage: true,
            //   scrollBar: true,
            //   withJavascript: true,
            //   allowFileURLs: true,
            //   javascriptChannels: jsChannels,
            // ),
            _mainView2(),
            Align(
              alignment: Alignment.center,
              child: isLoading ? CircularProgressIndicator() : Container(),
            )
          ],
        ),
      ),
    );
  }

  _mainView2() {
    return InAppWebView(
      initialUrl: widget.url,
      initialHeaders: {},
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(
            debuggingEnabled: true,
            useOnDownloadStart: true

        ),
      ),

      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
      },
      onLoadStart: (InAppWebViewController controller, String url) {

      },
      onLoadStop: (InAppWebViewController controller, String url) {
        setState(() {
          isLoading = false;
        });
      },
      onDownloadStart: (controller, url) async {
        print("onDownloadStart $url");
        _open(url);
      },
    );
  }


  Future<void> _open(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
*/
