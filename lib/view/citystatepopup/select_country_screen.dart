import 'package:flutter/material.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/view/custom/search_view.dart';

import '../../global/country.dart';
import '../../model/country_model.dart';

class SelectCountryScreen extends StatefulWidget {
  final Function onSelectCountry;
  final bool isCodeVisible;

  SelectCountryScreen({this.onSelectCountry,this.isCodeVisible});

  @override
  _SelectCountryScreenState createState() => _SelectCountryScreenState();
}

class _SelectCountryScreenState extends State<SelectCountryScreen> {

  static final TextEditingController _controller = TextEditingController();
  static final List<Country> allList = countryList;
  static final List<Country> filterlist = [];

  @override
  void initState() {
    super.initState();
    filterlist.addAll(allList);
    _controller.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: (){
        Navigator.pop(context);
      },
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (ctx){
        return Container(
          padding: const EdgeInsets.all(8),
          height: MediaQuery.of(context).size.height * 0.60,
          decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Column(
            children: <Widget>[
              SearchView(
                controller: _controller,
                hint: 'Search country',
                onSubmit: (searchKey) {
                  FocusScope.of(context).unfocus();
                  //_onSearch(searchKey);
                },
                onChange: (key) {
                  // _onSearch(key);
                  onSearch(key);
                },
              ),
              /*SizedBox(
                height: 40,
                width: double.infinity,
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black12,
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLines: 1,
                    maxLength: 40,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    style: TextStyle(color: Colors.black),
                    onChanged: (val) {
                      onSearch(val);
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                      counterText: '',
                      counter: null,
                    ),
                  ),
                ),
              ),*/
              Expanded(
                child: ListView.builder(
                  itemBuilder: (cnx, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        if(widget.isCodeVisible){
                          PreferenceManager.isdCode = filterlist[index].phoneCode;
                        }
                        widget.onSelectCountry(widget.isCodeVisible?filterlist[index].phoneCode:filterlist[index].name);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: <Widget>[

                            widget.isCodeVisible?   Text(
                              filterlist[index].phoneCode,
                              style: Theme.of(context).textTheme.headline3,
                            ):Container(),
                            const SizedBox(
                              width: 6,
                            ),
                            Expanded(
                              child: Text(
                                filterlist[index].name,
                                textScaleFactor: 1.0,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: filterlist.length,
                ),
              ),
            ],
          ),
        );;
      },
    );
  }

   onSearch(String val) {
    filterlist.clear();
    allList.forEach((element) {
      if (element.name.toLowerCase().contains(val.toLowerCase())) {
        filterlist.add(element);
      }
    });

    if (val.length == 0) {
      filterlist.addAll(allList);
    }
    setState(() {

    });
  }
}
