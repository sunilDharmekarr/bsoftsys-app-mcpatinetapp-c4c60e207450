import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/transaction_model.dart';
import 'package:mumbaiclinic/repository/lab_selection_repo.dart';
import 'package:mumbaiclinic/repository/wallet_repo.dart';
import 'package:mumbaiclinic/screen/myappointment/my_appointment_screen.dart';
import 'package:mumbaiclinic/screen/testdetals/my_test_order.dart';
import 'package:mumbaiclinic/screen/testdetals/my_test_orders.dart';
import 'package:mumbaiclinic/screen/view_invoice_screen.dart';
import 'package:mumbaiclinic/utils/PermissionUtils.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';
import 'package:permission_handler/permission_handler.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<Transaction> _transaction = [];
  final WalletRepo _walletRepo = WalletRepo();
  final repository = LabSelectionRepo();

  @override
  void initState() {
    super.initState();
    // loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Transactions and orders',
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
        child: Column(
          children: <Widget>[
            getView(AppAssets.my_appointments, 'Appointment', onclick: () {
              MyApplication.navigateToScreen(MyAppointmentScreen());
            }),
            getView(AppAssets.order_tests, 'Orders', onclick: () {
              MyApplication.navigateToScreen(MyTestOrderScreen());
            }),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                      child: AppText.getRegularText(
                          'Recent', 16, ColorTheme.darkGreen)),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (_) =>
                              MyTestOrderSearchScreen(_transaction)));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      height: 40,
                      width: 40,
                      child: Image.asset(AppAssets.search),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _walletRepo.getTransactionsData(),
                builder: (_, AsyncSnapshot<TransactionModel> snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data.transaction.length > 0) {
                    _transaction = snapshot.data.transaction;
                    return ListView.builder(
                      itemBuilder: (cntx, index) {
                        final data = _transaction[index];
                        return Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          color: ColorTheme.lightGreenOpacity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                              text: "${data.invoiceNo}\n",
                                              style: TextStyle(
                                                  color: ColorTheme.darkGreen,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text:
                                                  "${data.credit == 0 ? '-' : ''}Rs.${data.credit == 0 ? data.debit : data.credit}\n",
                                              style: TextStyle(
                                                  color: data.credit == 0
                                                      ? ColorTheme.darkRed
                                                      : ColorTheme.buttonColor,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: TextFont
                                                      .poppinsExtraBold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    color: Colors.grey,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    height: 50,
                                    width: 1.0,
                                  ),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                              text: "${data.remarks}\n",
                                              style: TextStyle(
                                                  color: ColorTheme.darkGreen,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold)),

                                          //TextSpan(text:"${ data.remarks}\n",style: TextStyle(color: ColorTheme.darkGreen,fontSize: 14,fontWeight: FontWeight.w300)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (data.invoiceNo
                                            .toString()
                                            .isNotEmpty)
                                          _requestPermission(
                                              data.invoiceNo.toString());
                                        else
                                          Utils.showToast(
                                              message:
                                                  'Invoice number is missing');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        primary: ColorTheme.buttonColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: AppText.getRegularText(
                                          'Download Invoice', 14, Colors.white),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 14,
                                  ),
                                  Container(
                                    child: Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                              text:
                                                  "Date:${Utils.getReadableDate(data.transactionDate)}\n",
                                              style: TextStyle(
                                                  color: ColorTheme.darkGreen,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w300)),
                                          TextSpan(
                                              text:
                                                  "Time:${Utils.getReadableTime(data.transactionDate)}",
                                              style: TextStyle(
                                                  color: ColorTheme.darkGreen,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w300)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                      itemCount: _transaction.length,
                    );
                  } else if (snapshot.hasError) {
                    return AppText.getRegularText(
                        snapshot.error.toString(), 12, Colors.red);
                  } else {
                    return AppText.getRegularText(
                        'Fetching transactions..', 12, ColorTheme.darkGreen);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getView(String assets, String title, {Function onclick}) {
    return GestureDetector(
      onTap: () => onclick?.call(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: ColorTheme.white,
        ),
        child: Row(
          children: <Widget>[
            SizedBox(
              height: 28,
              width: 28,
              child: Image.asset(
                assets,
                width: 30,
                height: 30,
                color: ColorTheme.iconColor,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: TextView(
                text: title,
                style: AppTextTheme.textTheme13Bold,
              ),
            ),
            SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child: Image.asset(
                  AppAssets.arrow_right,
                  width: 18,
                  height: 18,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _requestPermission(String invoice) async {
    final permissionUtils = PermissionUtils.instance;

    final result = await permissionUtils.requestPermission(Permission.storage);

    if (result) {
      Loader.showProgress();
      final data = await repository.getInvoice(invoice);
      Loader.hide();
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (_) => ViewInvoiceScreen(data, title: 'Invoice')));
    }
  }
}
