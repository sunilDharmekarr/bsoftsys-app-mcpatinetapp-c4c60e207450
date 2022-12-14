import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/model/transaction_model.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/search_view.dart';

class MyTestOrderSearchScreen extends StatefulWidget {
  final List<Transaction> _transaction;

  MyTestOrderSearchScreen(this._transaction);

  @override
  _MyTestOrderSearchScreenState createState() =>
      _MyTestOrderSearchScreenState();
}

class _MyTestOrderSearchScreenState extends State<MyTestOrderSearchScreen> {
  final _searchController = TextEditingController();

  List<Transaction> _transaction = [];
  List<Transaction> _transactionAll = [];

  @override
  void initState() {
    super.initState();

    _transactionAll = List.from(widget._transaction);
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        titleSpacing: 0.0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 24),
          padding: const EdgeInsets.only(left: 14),
          decoration: BoxDecoration(
            color: ColorTheme.lightGreenOpacity,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              _onsearch(value);
            },
            onSubmitted: (value) {},
            style: TextStyle(
              fontSize: 14,
              color: ColorTheme.darkGreen,
            ),
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search here..',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                suffixIcon: Icon(
                  Icons.search_outlined,
                  color: ColorTheme.darkGreen,
                )),
          ),
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
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
                                          fontFamily:
                                              TextFont.poppinsExtraBold)),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.grey,
                            margin: const EdgeInsets.symmetric(horizontal: 14),
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
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                primary: ColorTheme.buttonColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
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
            ),
          )
        ],
      ),
    );
  }

  _onsearch(String data) {
    _transaction.clear();

    _transactionAll.forEach((element) {
      if (element.remarks.toLowerCase().contains(data?.toLowerCase())) {
        _transaction.add(element);
      }
    });
    setState(() {});
  }
}
