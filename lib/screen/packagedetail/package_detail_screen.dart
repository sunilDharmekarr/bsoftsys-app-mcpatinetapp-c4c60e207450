import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/global/CartData.dart';
import 'package:mumbaiclinic/model/LabTestModel.dart';
import 'package:mumbaiclinic/repository/call_back_repo.dart';
import 'package:mumbaiclinic/screen/ordermedicaltest/cart_screen.dart';
import 'package:mumbaiclinic/screen/termscondition/mumbai_web_view.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';
import 'package:mumbaiclinic/model/PackageDetail.dart';
import 'package:mumbaiclinic/repository/package_repository.dart';

class PakageDetailScreen extends StatefulWidget {
  final int _packageData;
  final String url;
  PakageDetailScreen(this._packageData, this.url);

  @override
  _PakageDetailScreenState createState() => _PakageDetailScreenState();
}

class _PakageDetailScreenState extends State<PakageDetailScreen>
    with TickerProviderStateMixin {
  final packageRepo = PackageRepository();
  TabController _tabController;

  int currentIndex = 0;

  int count = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
  }

  @override
  void dispose() {
    super.dispose();
    CartData.clearData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Package Details',
          style: Theme.of(context).appBarTheme.textTheme.headline1,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              final result =
                  await Navigator.of(context).push(CupertinoPageRoute(
                      builder: (_) => CartScreen(
                            null,
                            packege: true,
                          )));
              if (result) {
                count = CartData.getItems.length;
                setState(() {});
              }
            },
            child: Stack(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: Image.asset(
                      AppAssets.my_cart,
                      width: 34,
                      height: 34,
                    ),
                  ),
                ),
                if (count != 0)
                  Positioned(
                    top: 4,
                    child: Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red[800],
                      ),
                      child: TextView(
                        text: '$count',
                        style: AppTextTheme.textTheme10Light,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          )
        ],
      ),
      body: Container(
        child: FutureBuilder(
          future: packageRepo.getPackaeDetail(widget._packageData.toString()),
          builder: (_, AsyncSnapshot<PackageData> snapshot) {
            if (snapshot.hasData) {
              return Container(
                height: MediaQuery.of(context).size.height,
                child: CustomScrollView(
                  shrinkWrap: true,
                  primary: true,
                  anchor: 0.5,
                  slivers: [
                    SliverToBoxAdapter(
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          httpHeaders: Utils.getHeaders(),
                          imageUrl: "${widget.url}",
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Center(
                            child: CircularProgressIndicator(
                                value: downloadProgress.progress),
                          ),
                          errorWidget: (context, url, error) => Opacity(
                            opacity: 0.5,
                            child: Image.asset(
                              AppAssets.about_Mumbai_clinic,
                              color: Colors.grey[200],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: AppText.getBoldText(
                                snapshot.data.packageName,
                                14,
                                ColorTheme.darkGreen),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: AppText.getLightText(
                                snapshot.data.packageDetails,
                                14,
                                ColorTheme.darkGreen,
                                maxLine: 15,
                                textAlign: TextAlign.justify),
                          ),
                          Container(
                            color: ColorTheme.darkGreen.withOpacity(0.1),
                            margin: const EdgeInsets.all(10),
                            height: 4,
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: AppText.getLightText(
                                      'Age Details:', 14, ColorTheme.darkGreen,
                                      textAlign: TextAlign.start),
                                ),
                                Expanded(
                                    child: AppText.getBoldText(
                                  snapshot.data.ageDetails,
                                  14,
                                  ColorTheme.darkGreen,
                                )),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: AppText.getLightText(
                                      'Gender:', 14, ColorTheme.darkGreen,
                                      textAlign: TextAlign.start),
                                ),
                                Expanded(
                                    child: AppText.getBoldText(
                                  snapshot.data.gender,
                                  14,
                                  ColorTheme.darkGreen,
                                )),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: ColorTheme.lightGreenOpacity,
                              boxShadow: Utils.getShadow(),
                            ),
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
                                      labelPadding: const EdgeInsets.symmetric(
                                          horizontal: 0),
                                      isScrollable: false,
                                      unselectedLabelColor:
                                          ColorTheme.darkGreen,
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      labelColor: ColorTheme.darkGreen,
                                      indicator: BoxDecoration(
                                        color: ColorTheme.darkGreen
                                            .withOpacity(0.4),
                                      ),
                                      onTap: (index) {
                                        setState(() {
                                          currentIndex = index;
                                          print(currentIndex);
                                        });
                                      },
                                      tabs: ['Tests Included', 'Preparation']
                                          .map<Widget>(
                                            (e) => Tab(
                                              child: Container(
                                                height: 44,
                                                margin: const EdgeInsets.only(
                                                    bottom: 1.5),
                                                decoration: BoxDecoration(
                                                  color: ColorTheme
                                                      .lightGreenOpacity,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    e,
                                                    maxLines: 1,
                                                    textScaleFactor: 1.0,
                                                    style: TextStyle(
                                                      fontSize: AppTextTheme
                                                          .textSize12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: _getTabView(
                                      currentIndex,
                                      currentIndex == 0
                                          ? snapshot.data.packageTestFile
                                          : snapshot.data.preparation),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(10),
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(
                                text: 'Amount: Rs ',
                                style: TextStyle(
                                  color: ColorTheme.darkGreen,
                                  fontSize: 16,
                                  fontFamily: TextFont.poppinsRegular,
                                )),
                            TextSpan(
                                text: '${snapshot.data.discountedAmount}',
                                style: TextStyle(
                                  color: ColorTheme.darkGreen,
                                  fontSize: 16,
                                  fontFamily: TextFont.poppinsRegular,
                                )),
                            if (snapshot.data.amount >
                                snapshot.data.discountedAmount)
                              TextSpan(
                                  text: ' ',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                    fontFamily: TextFont.poppinsLight,
                                  )),
                            if (snapshot.data.amount >
                                snapshot.data.discountedAmount)
                              TextSpan(
                                  text: '${snapshot.data.amount}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 16,
                                    fontFamily: TextFont.poppinsLight,
                                  )),
                          ]),
                          textScaleFactor: 1.0,
                          maxLines: 1,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                        child: Container(
                      width: double.infinity,
                      height: 40,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: AppButton(
                        text: 'Add to cart',
                        style: AppTextTheme.textTheme12Light,
                        onClick: () {
                          final labtest = Labtest();
                          labtest.packageId = snapshot.data.packageId;
                          labtest.packageName = snapshot.data.packageName;
                          labtest.price = snapshot.data.amount;
                          labtest.discountedPrice =
                              snapshot.data.discountedAmount;
                          CartData.addItems(labtest);
                          setState(() {
                            count = CartData.getItems.length;
                          });
                          // Navigator.of(context).pop(true);
                        },
                      ),
                    )),
                    SliverToBoxAdapter(
                        child: Container(
                      width: double.infinity,
                      height: 40,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: AppButton(
                        text: 'Request callback for package enrolment',
                        style: AppTextTheme.textTheme12Light,
                        onClick: () {
                          _call(snapshot.data.packageId.toString());
                          //Navigator.of(context).pop(true);
                        },
                      ),
                    ))
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: AppText.getRegularText(
                    '${snapshot.error.toString()}', 16, Colors.grey),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }

  final callBackRepo = CallBackRepo();

  _getTabView(index, String data) {
    if (index == 0) {
      return Container(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (_) => MumbaiWebView(
                        title: 'Tests Included',
                        url: data,
                        actionBar: true,
                      )));
            },
            child: Text(
              'Click here to know tests included',
              style: TextStyle(
                fontSize: 12,
                color: ColorTheme.darkGreen,
                decoration: TextDecoration.underline,
              ),
            ),
          ));
    }
    if (index == 1) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: AppText.getLightText('$data', 14, ColorTheme.darkGreen,
            maxLine: 12, textAlign: TextAlign.justify),
      );
    }
  }

  _call(id) async {
    Loader.showProgress();
    final response = await callBackRepo.logCallbackForPackage(id);
    Loader.hide();
    if (response != null) {
      Utils.showSingleButtonAlertDialog(
          context: context,
          message: Utils.fixNewLines(response),
          onClick: () => Navigator.of(context).pop());
    }
  }
}
