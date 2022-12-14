import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/model/lab_model.dart';
import 'package:mumbaiclinic/repository/lab_selection_repo.dart';
import 'package:mumbaiclinic/screen/ordermedicaltest/order_medical_test.dart';
import 'package:mumbaiclinic/screen/testdetals/my_test_orders.dart';
import 'package:mumbaiclinic/services/address_service.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';

class SelectLabScreen extends StatefulWidget {
  @override
  _SelectLabScreenState createState() => _SelectLabScreenState();
}

class _SelectLabScreenState extends State<SelectLabScreen> {
  LabSelectionRepo labSelectionRepo;

  @override
  void initState() {
    super.initState();
    labSelectionRepo = LabSelectionRepo();
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
          title: Text(
            'Lab Selections',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text.rich(TextSpan(children: [
                  TextSpan(
                    text: 'Your Location\n',
                    style: TextStyle(
                        fontSize: AppTextTheme.textSize12,
                        color: ColorTheme.darkGreen,
                        fontFamily: TextFont.poppinsLight),
                  ),
                  TextSpan(
                    text: '${getAddress()}',
                    style: TextStyle(
                        fontSize: AppTextTheme.textSize12,
                        color: ColorTheme.darkGreen,
                        fontFamily: TextFont.poppinsBold),
                  )
                ])),
                Image.asset(
                  AppAssets.location,
                  width: 24,
                  height: 24,
                ),
                const SizedBox(
                  width: 10,
                )
              ],
            ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  GestureDetector(
                    onTap: () {
                      MyApplication.navigateToScreen(MyTestOrderScreen());
                    },
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 14),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      decoration: BoxDecoration(
                          color: ColorTheme.buttonColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: Utils.getShadow()),
                      child: TextView(
                        text: "View my test orders",
                        color: Colors.white,
                        style: AppTextTheme.textTheme14Light,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverFillRemaining(
                key: UniqueKey(),
                child: FutureBuilder(
                  future: labSelectionRepo.getLabs(),
                  builder:
                      (BuildContext cntx, AsyncSnapshot<LabsModel> snapShot) {
                    if (snapShot.hasError) {
                      return Center(
                        child: TextView(
                          textAlign: TextAlign.center,
                          text: snapShot.error.toString(),
                          color: Colors.red,
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    } else if (snapShot.hasData) {
                      return ListView.builder(
                        itemBuilder: (_, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_) => OrderMedicalTestScreen(
                                          snapShot.data.labs[index])));
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 8),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: ColorTheme.lightGreenOpacity,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: 60,
                                        width: 60,
                                        margin: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.fill,
                                          httpHeaders: Utils.getHeaders(),
                                          imageUrl:
                                              "${snapShot.data.labs[index].logoPath}",
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Image.asset(
                                            AppAssets.tests,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              top: 12, bottom: 12),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              TextView(
                                                text: snapShot.data.labs[index]
                                                        .labName ??
                                                    '',
                                                style: AppTextTheme
                                                    .textTheme14Regular,
                                              ),
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    AppAssets.location,
                                                    width: 18,
                                                    height: 18,
                                                    color:
                                                        ColorTheme.lightGreen,
                                                  ),
                                                  const SizedBox(
                                                    width: 6,
                                                  ),
                                                  Expanded(
                                                    child: TextView(
                                                      text:
                                                          '${snapShot.data.labs[index].labAddress ?? ''}',
                                                      maxLine: 4,
                                                      textAlign:
                                                          TextAlign.justify,
                                                      style: AppTextTheme
                                                          .textTheme10Light,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            MyApplication.navigateToWebPage(
                                                'Map',
                                                snapShot.data.labs[index]
                                                    .googleLocation);
                                          },
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 16,
                                              ),
                                              Image.asset(
                                                AppAssets.directions,
                                                width: 20,
                                                height: 20,
                                              ),
                                              const SizedBox(
                                                width: 6,
                                              ),
                                              TextView(
                                                text: 'Direction',
                                                style: AppTextTheme
                                                    .textTheme12Regular,
                                                color: ColorTheme.darkGreen,
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2, horizontal: 16),
                                          decoration: BoxDecoration(
                                              color: ColorTheme.buttonColor,
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: TextView(
                                            text: 'Select Lab',
                                            style:
                                                AppTextTheme.textTheme12Regular,
                                            color: ColorTheme.white,
                                          ),
                                        ),
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: snapShot.data.labs.length,
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ))
          ],
        ));
  }

  String getAddress() {
    final addressService = AddressService.instance;
    final data = addressService.place;
    if (data != null) {
      return data.locality;
    }
    return 'Loading..';
  }
}
