import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/model/LabTestModel.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';

class CellOrderTest extends StatelessWidget {
  final int index;
  final bool divider;
  final Function onClick;
  final Function(Labtest data) onCartClick;
  final Labtest labtest;
  final bool test;
  CellOrderTest(
      {@required this.index,
      this.divider = false,
      this.onClick,
      this.onCartClick,
      this.labtest,
      this.test});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onClick(),
      child: Container(
        width: 180,
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: ColorTheme.lightGreenOpacity,
                      borderRadius: BorderRadius.circular(4),
                    ),

                    child: Row(
                      children: [
                        Image.asset(
                          AppAssets.tests,
                          width: 40,
                          height: 40,
                        ),
                        Flexible(
                          child: Center(
                            child: TextView(
                              text:
                                  test ? labtest.testName : labtest.profileName,
                              maxLine: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextTheme.textTheme14Bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                   (labtest?.price > labtest?.discountedPrice)?
                                    TextSpan(
                                        text: '₹${labtest.price}\n',
                                        style: TextStyle(
                                          color: ColorTheme.buttonColor,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        )):
                                    TextSpan(
                                        text: '\n',
                                        style: TextStyle(
                                          color: ColorTheme.buttonColor,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        )),
                                  if (labtest.discountedPrice != null &&
                                      labtest.discountedPrice != 0)
                                    TextSpan(
                                        text: '₹${labtest.discountedPrice}',
                                        style: TextStyle(
                                          color: ColorTheme.darkGreen,
                                        ))
                                ],
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (onCartClick != null) {
                              onCartClick(labtest);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: ColorTheme.buttonColor,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  AppAssets.add,
                                  width: 14,
                                  height: 14,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                TextView(
                                  text: 'Cart',
                                  color: ColorTheme.white,
                                  style: AppTextTheme.textTheme10Light,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!divider && index != -1)
                    Container(
                      height: 0.7,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
            if (divider && index != -1)
              Container(
                height: 80,
                width: 0.7,
                color: Colors.grey,
              ),
            if (!divider && index % 2 == 0)
              Container(
                height: 80,
                width: 0.7,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}
