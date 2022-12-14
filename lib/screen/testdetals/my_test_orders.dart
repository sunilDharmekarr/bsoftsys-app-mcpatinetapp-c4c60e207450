import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/model/MyTestModel.dart';
import 'package:mumbaiclinic/repository/lab_selection_repo.dart';
import 'package:mumbaiclinic/screen/testdetals/my_test_orders_details.dart';
import 'package:mumbaiclinic/utils/PermissionUtils.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';

import '../view_invoice_screen.dart';

class MyTestOrderScreen extends StatefulWidget {
  @override
  _MyTestOrderScreenState createState() => _MyTestOrderScreenState();
}

class _MyTestOrderScreenState extends State<MyTestOrderScreen> {
  final repository = LabSelectionRepo();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Test Orders',
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
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(8),
        child: FutureBuilder(
          future: repository.myTestOrders(),
          builder: (_, AsyncSnapshot<List<Payload>> snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child:
                      AppText.getErrorText('${snapshot.error.toString()}', 16));
            } else if (snapshot.hasData) {
              List<Payload> list = snapshot.data;
              if (list.length == 0)
                return Center(child: AppText.getErrorText('No Data.', 16));
              else
                return Container(
                  child: ListView.builder(
                    itemBuilder: (_, index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: ColorTheme.lightGreenOpacity,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: AppText.getLightText(
                                        list[index].tests[0].status,
                                        12,
                                        ColorTheme.darkGreen,
                                        textAlign: TextAlign.left)),
                                IconButton(
                                    icon: Icon(
                                      Icons.share,
                                      color: ColorTheme.iconColor,
                                    ),
                                    onPressed: () {
                                      _shareAppointment(list[index]);
                                    })
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                    child: AppText.getBoldText(
                                  list[index].invoiceNumber,
                                  14,
                                  ColorTheme.darkGreen,
                                )),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Image.asset(
                                        AppAssets.calander,
                                        width: 24,
                                        height: 24,
                                        color: ColorTheme.iconColor,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      AppText.getBoldText(
                                          Utils.getReadableDateTime(
                                              list[index].date),
                                          14,
                                          ColorTheme.darkGreen)
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                  height: 40,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: AppButton(
                                    text: 'Details',
                                    style: AppTextTheme.textTheme12Bold,
                                    onClick: () {
                                      Navigator.of(context).push(
                                          CupertinoPageRoute(
                                              builder: (_) =>
                                                  MyTestOrdersDetailScreen(
                                                      list[index])));
                                    },
                                  ),
                                ),
                                AbsorbPointer(
                                  absorbing:
                                      list[index].tests[0].status != 'Ready',
                                  child: Container(
                                    height: 40,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    child: AppButton(
                                      text: 'Download Report',
                                      style: AppTextTheme.textTheme12Bold,
                                      buttonTextColor:
                                          list[index].tests[0].status == 'Ready'
                                              ? ColorTheme.white
                                              : ColorTheme.darkGreen,
                                      color:
                                          list[index].tests[0].status == 'Ready'
                                              ? ColorTheme.buttonColor
                                              : Colors.grey[200],
                                      onClick: () async {
                                        _requestPermission(
                                            list[index].testOrderId.toString());
                                      },
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: list.length,
                  ),
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

  _requestPermission(String ids) async {
    final permissionUtils = PermissionUtils.instance;
    final result = await permissionUtils.requestPermission(Permission.storage);
    if (result) {
      Loader.showProgress();
      var path = await repository.getTestReport(ids);
      Loader.hide();
      if (path != null) {
        Navigator.of(context).push(CupertinoPageRoute(
            builder: (_) => ViewInvoiceScreen(path, title: 'Test Reports')));
      }
    }
  }

  _shareAppointment(Payload data) async {
    //test_order: 1234
    // 	invoice_no: AVN-123456
    // 	Date: 16 Sep 2020
    // 	Status: in-progress
    // 	Tests: (1) CBC, (2) TSH, (3)T3
    //
    var test = '';
    var index = 1;
    data.tests.forEach((element) {
      if (index > 1) test += ', ';
      test += '($index) ${element.testName}';
      index++;
    });
    String message = '''
        Test Order:${data.testOrderId} 
        Invoice No:${data.invoiceNumber ?? ''}
        Date: ${Utils.getReadableDate(data.date)}
        Status: ${data.tests[0].status}
        Tests:\n$test
        ''';
    final RenderBox box = context.findRenderObject();
    await Share.share(message,
        subject: 'My Test Orders',
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }
}
