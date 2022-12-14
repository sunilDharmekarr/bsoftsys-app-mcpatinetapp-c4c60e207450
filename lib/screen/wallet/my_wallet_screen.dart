import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/model/transaction_model.dart';
import 'package:mumbaiclinic/model/wallet_model.dart';
import 'package:mumbaiclinic/repository/wallet_repo.dart';
import 'package:mumbaiclinic/screen/payment/payment_result_screen.dart';
import 'package:mumbaiclinic/utils/razorpay_util.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class MyWalletScreen extends StatefulWidget {
  final bool popOnAdd;

  MyWalletScreen({this.popOnAdd = false});

  @override
  _MyWalletScreenState createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  final _addMoneyController = TextEditingController();
  final WalletRepo _walletRepo = WalletRepo();

  String walletBalance = '0';
  bool loading = true;
  String token = '';
  String pid = '';
  String contact = '';
  String email = '';
  String paymentId = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
    _addMoneyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: ColorTheme.lightGreenOpacity,
          centerTitle: false,
          title: Text(
            'My Wallet',
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
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: <Widget>[
              Container(
                color: ColorTheme.lightGreenOpacity,
                padding:
                    const EdgeInsets.symmetric(vertical: 40, horizontal: 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Center(
                        child: FutureBuilder(
                          future: _walletRepo.getWalletBalance(),
                          builder: (_, AsyncSnapshot<Wallet> snapshot) {
                            if (snapshot.hasData && snapshot.data != null) {
                              return TextView(
                                text:
                                    'Rs.${snapshot.data.walletBalance[0].walletBalance}',
                                color: ColorTheme.darkGreen,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: AppTextTheme.textSize30,
                                    fontFamily: TextFont.poppinsBold),
                              );
                            } else if (snapshot.data == null) {
                              return AppText.getBoldText(
                                'Rs.0',
                                30,
                                ColorTheme.darkGreen,
                              );
                            } else if (snapshot.hasError) {
                              return AppText.getRegularText(
                                  snapshot.error.toString(), 12, Colors.red);
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        ),
                      ),
                    ),
                    TextView(
                      text: 'My Wallet Balance',
                      color: ColorTheme.darkGreen,
                      textAlign: TextAlign.center,
                      style: AppTextTheme.textTheme14Light,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: ColorTheme.white,
                                boxShadow:
                                    Utils.getShadow(color: Colors.black)),
                            child: TextField(
                              controller: _addMoneyController,
                              style: AppTextTheme.textTheme16Bold,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              onSubmitted: (val) {
                                FocusScope.of(context).unfocus();
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintText: 'Enter Amount',
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                hintStyle: AppTextTheme.textTheme14Bold
                                    .apply(color: ColorTheme.darkGreen),
                                hintMaxLines: 1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        GestureDetector(
                          onTap: () {
                            _createPayment();
                          },
                          child: Container(
                            height: 80,
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: ColorTheme.buttonColor,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Image.asset(
                                  AppAssets.add_money,
                                  width: 24,
                                  height: 24,
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                TextView(
                                  text: 'Add Money',
                                  color: ColorTheme.white,
                                  textAlign: TextAlign.center,
                                  style: AppTextTheme.textTheme14Light,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
              Container(
                color: ColorTheme.darkGreen.withOpacity(0.1),
                height: 4,
              ),
              Expanded(
                  child: FutureBuilder(
                future: _walletRepo.getTransactionsData(),
                builder: (_, AsyncSnapshot<TransactionModel> snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data.transaction.length > 0) {
                    List<Transaction> _transaction = snapshot.data.transaction;
                    return ListView.builder(
                      itemBuilder: (cntx, index) {
                        final data = _transaction[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: TextView(
                                      text:
                                          'Date:${Utils.getReadableDate(data.transactionDate)}',
                                      color: ColorTheme.darkGreen,
                                      textAlign: TextAlign.start,
                                      style: AppTextTheme.textTheme10Light,
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: TextView(
                                        text:
                                            '${Utils.getReadableTime(data.transactionDate)}',
                                        color: ColorTheme.darkGreen,
                                        textAlign: TextAlign.end,
                                        style: AppTextTheme.textTheme10Light,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: data.credit == 0
                                        ? ColorTheme.lightGreen.withOpacity(0.4)
                                        : ColorTheme.lightGreen),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: TextView(
                                          text: data.credit == 0
                                              ? 'Deducted From your Wallet'
                                              : 'Added to your Wallet',
                                          color: data.credit == 0
                                              ? ColorTheme.darkGreen
                                              : ColorTheme.white,
                                          style: AppTextTheme.textTheme12Light,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: TextView(
                                          text: data.debit == 0
                                              ? '+Rs.${data.credit}'
                                              : '-Rs.${data.debit}',
                                          color: data.credit == 0
                                              ? ColorTheme.darkGreen
                                              : ColorTheme.white,
                                          style: AppTextTheme.textTheme16Bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
              ))
            ],
          ),
        ),
      ),
    );
  }

  _createPayment() async {
    double pay = double.parse(_addMoneyController.text.toString());

    RazorPayUtil.get().open(
      pay,
      "Mumbai-Clinic",
      "Add to wallet",
      (value) async {
        paymentId = value;

        final result =
            await Navigator.of(context).push<bool>(CupertinoPageRoute(
                builder: (_) => PaymentResultScreen(
                      success: true,
                      needToPop: true,
                    )));
        if (result) _addMoneyToWallet();
      },
      (value) {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (_) => PaymentResultScreen(
              success: false,
            ),
          ),
        );
      },
    );
  }

  void loadData() async {
    pid = PreferenceManager.getUserId();
    final Datum usermodel = await AppDatabase.db.getUser(pid);
    email = usermodel.email;
    contact = usermodel.mobile;
    _addMoneyController.text = '';
  }

  _addMoneyToWallet() async {
    final data = await _walletRepo.addMoneyToWallet(
        _addMoneyController.text.trim(), pid, paymentId);
    if (data != null) {
      if (data.success == 'true') {
        _addMoneyController.text = '';
        setState(() {});
        if (widget.popOnAdd) {
          Navigator.pop(context, true);
        }
      } else {
        Utils.showToast(
            message: 'Failed to process payment: ${data.error}', isError: true);
      }
    } else {
      Utils.showToast(message: 'Failed to process payment', isError: true);
    }
  }
}
