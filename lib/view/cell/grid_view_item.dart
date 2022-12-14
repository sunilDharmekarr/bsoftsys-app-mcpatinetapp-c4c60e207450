import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/model/available_time.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';

class GridViewItem extends StatelessWidget {
  final SlotTime time;
  final bool _isSelected;

  GridViewItem(this.time, this._isSelected);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: RawMaterialButton(
        child: TextView(
          text: Utils.getReadableTime(time.slotStart),
          color: _isSelected
              ? ColorTheme.white
              : (time.isAvailable == 'true'
                  ? ColorTheme.darkGreen
                  : Colors.grey[400]),
          textAlign: TextAlign.center,
          maxLine: 1,
          style: AppTextTheme.textTheme12Light,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        fillColor: _isSelected ? ColorTheme.darkGreen : Colors.transparent,
        onPressed: null,
      ),
    );
  }
}
