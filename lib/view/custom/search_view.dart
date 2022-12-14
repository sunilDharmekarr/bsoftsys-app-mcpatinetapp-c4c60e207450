import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';

class SearchView extends StatefulWidget {
  final Key key;
  final String hint;
  final TextEditingController controller;
  final Function(String key) onChange;
  final Function onSubmit;

  SearchView({this.key, this.hint, @required this.controller,this.onSubmit,this.onChange})
      : super(key: key);

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ColorTheme.lightGreen.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10)
      ),
      child: TextField(
        maxLines: 1,
        maxLength: 30,
        autofocus: false,
        textInputAction: TextInputAction.search,
        controller: widget.controller,
        onSubmitted: (val)=>widget.onSubmit(val),
        onChanged: (val)=>widget.onChange(val),
        decoration: InputDecoration(
            counter: null,
            counterText: '',
            contentPadding: const EdgeInsets.all(8),
            prefixIcon: Icon(
              Icons.search,
              color: ColorTheme.darkGreen,
            ),
          enabledBorder: OutlineInputBorder(
            gapPadding: 0.0,
            borderSide: BorderSide(
              color: ColorTheme.darkGreen,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            gapPadding: 0.0,
            borderSide: BorderSide(
              color: ColorTheme.darkGreen,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
            hintText: widget.hint ?? 'Search here',),
      ),
    );
  }
}
