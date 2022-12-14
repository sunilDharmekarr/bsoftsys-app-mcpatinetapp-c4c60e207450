import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/global/CartData.dart';
import 'package:mumbaiclinic/model/LabTestModel.dart';
import 'package:mumbaiclinic/model/lab_model.dart';
import 'package:mumbaiclinic/repository/lab_test_repo.dart';
import 'package:mumbaiclinic/repository/order_test_repo.dart';
import 'package:mumbaiclinic/screen/ordermedicaltest/cart_screen.dart';
import 'package:mumbaiclinic/screen/ordermedicaltest/search_screen.dart';
import 'package:mumbaiclinic/screen/testdetals/test_detail_screen.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/cell/cell_order_test.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class OrderMedicalTestScreen extends StatefulWidget {
  final Lab lab;

  OrderMedicalTestScreen(this.lab);

  @override
  _OrderMedicalTestScreenState createState() => _OrderMedicalTestScreenState();
}

class _OrderMedicalTestScreenState extends State<OrderMedicalTestScreen> {
  final frequentlyKey = UniqueKey();
  final orderKey = UniqueKey();
  OrderTestRepo repo;
  bool test = true;
  bool profileTest = false;
  int count = 0;

  List<Labtest> frequentlyList = [];
  List<Labtest> labtest = [];
  final labtestrepo = LabTestRepo();

  @override
  void initState() {
    super.initState();
    repo = OrderTestRepo();
    _getFrequentlyTest();
    loaData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Order Tests',
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
              final result = await Navigator.of(context).push(
                  CupertinoPageRoute(builder: (_) => CartScreen(widget.lab)));
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
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            key: UniqueKey(),
            child: Container(
              alignment: Alignment.centerLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 60,
                        width: 60,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CachedNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: "${widget.lab.logoPath}",
                          httpHeaders: Utils.getHeaders(),
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                                value: downloadProgress.progress),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            AppAssets.tests,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              TextView(
                                text: '${widget.lab.labName}',
                                style: AppTextTheme.textTheme14Bold,
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    AppAssets.location,
                                    width: 18,
                                    height: 18,
                                    color: ColorTheme.lightGreen,
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Expanded(
                                    child: TextView(
                                      text: '${widget.lab.labAddress}',
                                      maxLine: 2,
                                      style: AppTextTheme.textTheme10Light,
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
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                if (frequentlyList.length > 0)
                  Container(
                    padding: const EdgeInsets.all(14),
                    child: TextView(
                      text: 'Frequently ordered tests',
                      style: AppTextTheme.textTheme14Bold,
                      color: ColorTheme.darkGreen,
                    ),
                  ),
                if (frequentlyList.length > 0)
                  Container(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (_, index) => CellOrderTest(
                        index: index,
                        divider: true,
                        test: true,
                        labtest: frequentlyList[index],
                        onClick: () {
                          _Navidate(
                            frequentlyList[index],
                          );
                        },
                        onCartClick: (data) {
                          CartData.addItems(data);
                          count = CartData.getItems.length;
                          setState(() {});
                        },
                      ),
                      itemCount: frequentlyList.length,
                    ),
                  ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            key: UniqueKey(),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(
                    width: 8,
                  ),
                  TextView(
                    text: 'Individual Tests',
                    style: AppTextTheme.textTheme10Light,
                  ),
                  Container(
                    child: Switch.adaptive(
                      value: test,
                      activeColor: ColorTheme.buttonColor,
                      onChanged: (value) {
                        test = value;

                        profileTest = !test;
                        loaData();

                        setState(() {});
                      },
                    ),
                  ),
                  TextView(
                    text: 'Profile Tests',
                    style: AppTextTheme.textTheme10Light,
                  ),
                  Container(
                    child: Switch.adaptive(
                      value: profileTest,
                      activeColor: ColorTheme.buttonColor,
                      onChanged: (value) {
                        profileTest = value;
                        test = !profileTest;
                        loaData();
                        setState(() {});
                      },
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.grey,
                  ),
                  IconButton(
                    icon: Image.asset(
                      AppAssets.search,
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () async {
                      final result = await Navigator.push<bool>(
                          context,
                          CupertinoPageRoute(
                              builder: (_) => SearchScreen(labtest, test)));

                      if (result) {
                        count = CartData.getItems.length;
                        setState(() {});
                      }
                    },
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 1.2,
                  crossAxisCount: 2,
                ),
                itemCount: labtest.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (_, index) => CellOrderTest(
                  index: index,
                  test: test,
                  labtest: labtest[index],
                  divider: false,
                  onCartClick: (Labtest data) {
                    CartData.addItems(data);
                    count = CartData.getItems.length;
                    setState(() {});
                  },
                  onClick: () {
                    _Navidate(labtest[index]);
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  _Navidate(data) async {
    /* final result = await Navigator.of(context).push<bool>(CupertinoPageRoute(
        builder: (_) => TestDetailScreen(
              istest: test,
              labtest: data,
              lab: widget.lab,
            )));

    if (result != null && result) {
      count = CartData.getItems.length;
      setState(() {});
    } */
  }

  loaData() async {
    labtest.clear();
    setState(() {});
    test ? _getLabTest() : _getLabProfile();
  }

  _getFrequentlyTest() async {
    frequentlyList.clear();
    final recentData =
        await labtestrepo.getFrequentlyAskedTest(widget.lab.labId.toString());
    if (recentData != null) {
      frequentlyList.clear();
      frequentlyList.addAll(recentData.labtest);
    } else {
      frequentlyList.clear();
    }
    setState(() {});
  }

  _getLabTest() async {
    // EasyLoading.show(status: '', indicator: CircularProgressIndicator());
    Loader.showProgress();
    final data = await labtestrepo.getLabTset(widget.lab.labId.toString());
    // EasyLoading.dismiss();
    Loader.hide();
    if (data != null) {
      labtest.clear();
      labtest.addAll(data.labtest);
    } else {
      labtest.clear();
    }
    setState(() {});
  }

  _getLabProfile() async {
    // EasyLoading.show(status: '', indicator: CircularProgressIndicator());
    Loader.showProgress();
    final data = await labtestrepo.getProfileTest(widget.lab.labId.toString());
    //EasyLoading.dismiss();
    Loader.hide();
    if (data != null) {
      labtest.clear();
      labtest.addAll(data.labtest);
    } else {
      labtest.clear();
    }
    setState(() {});
  }
}
