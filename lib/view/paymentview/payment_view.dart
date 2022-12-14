import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';

class PaymentView extends StatefulWidget {
  final String amount;
  final Function onPay;

  PaymentView({this.amount, this.onPay});

  @override
  _PaymentViewState createState() => _PaymentViewState();
}

class _PaymentViewState extends State<PaymentView> {

  final _applyController = TextEditingController();
  String finalAmount = '';

  @override
  void initState() {
    super.initState();
    finalAmount = widget.amount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            color: Colors.white,
            height: 40,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextView(
                    text: 'Total Amount',
                    style: AppTextTheme.textTheme14Bold,
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: TextView(
                    text: 'Rs.${widget.amount}',
                    style: AppTextTheme.textTheme14Bold,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            color: Colors.grey[100],
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _applyController,
                      autofocus: false,
                      onSubmitted: (val) {
                        FocusScope.of(context).unfocus();
                      },
                      maxLines: 1,
                      maxLength: 40,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      style: AppTextTheme.textTheme12Bold,
                      onChanged: (val) {},
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        hintStyle: Theme.of(context).textTheme.bodyText1,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                        counterText: '',
                        counter: null,
                      ),
                    ),
                  ),
                  Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: ColorTheme.lightGreen,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {},
                      child: Center(
                        child: TextView(
                          text: 'Apply',
                          color: ColorTheme.white,
                          style: AppTextTheme.textTheme12Bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            height: 40,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextView(
                    text: 'Payable Amount',
                    style: AppTextTheme.textTheme14Bold,
                    textAlign: TextAlign.left,
                  ),
                ),
                Expanded(
                  child: TextView(
                    text: 'Rs.$finalAmount',
                    style: AppTextTheme.textTheme14Bold,
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40,),
          GestureDetector(
            onTap: () {
              widget.onPay(finalAmount);
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(14, 20, 14, 20),
              decoration: BoxDecoration(
                color: ColorTheme.lightGreen,
                borderRadius: BorderRadius.circular(8),
                boxShadow: Utils.getShadow(shadow: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: TextView(
                    text: 'Pay $finalAmount',
                    color: Colors.white,
                    style: AppTextTheme.textTheme14Bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
