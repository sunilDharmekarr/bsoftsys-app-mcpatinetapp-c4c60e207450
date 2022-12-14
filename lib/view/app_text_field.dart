import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String textHint;
  final String suffixText;
  final bool enable;
  final List<TextInputFormatter> formatter;
  final Function(String value) onSubmit;
  final Function(String value) onChanged;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final bool shadow;
  final int maxLength;
  final bool isSelectable;
  final EdgeInsetsGeometry margin;
  AppTextField({
    @required this.controller,
    @required this.textHint,
    this.suffixText = '',
    this.formatter,
    this.onSubmit,
    this.onChanged,
    this.enable = true,
    this.textInputType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.shadow = true,
    this.maxLength = 40,
    this.isSelectable = true,
    this.margin = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: maxLength + 10.0,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: ColorTheme.lightGreenOpacity,
        boxShadow: shadow ? Utils.getShadow() : [],
      ),
      child: TextField(
        enabled: enable,
        controller: controller,
        enableInteractiveSelection: isSelectable,
        inputFormatters: formatter,
        textCapitalization: TextCapitalization.words,
        autofocus: false,
        onSubmitted: (val) => onSubmit?.call(val),
        minLines: 1,
        maxLines: maxLength > 40 ? 5 : 1,
        maxLength: maxLength,
        keyboardType: textInputType,
        textInputAction: textInputAction,
        style: Theme.of(context)
            .textTheme
            .bodyText1
            .apply(fontFamily: TextFont.poppinsBold),
        onChanged: (val) => onChanged?.call(val),
        decoration: InputDecoration(
          hintText: '$textHint',
          hintStyle: Theme.of(context).textTheme.bodyText1,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
          counterText: '',
          counter: null,
          suffix: AppText.getLightText(suffixText, 12, ColorTheme.darkGreen),
        ),
      ),
    );
  }
}
