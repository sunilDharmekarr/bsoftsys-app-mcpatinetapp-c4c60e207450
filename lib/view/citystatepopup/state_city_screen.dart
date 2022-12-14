import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/view/custom/search_view.dart';

class StateCityScreen extends StatefulWidget {
  final String token;
  final String endpoint;
  final String searchKey;
  final Function onSelected;

  StateCityScreen(
      {this.token, this.endpoint, this.searchKey = 'state', this.onSelected});

  @override
  _StateCityScreenState createState() => _StateCityScreenState();
}

class _StateCityScreenState extends State<StateCityScreen> {
  static final TextEditingController _controller = TextEditingController();
  List<String> allList = [];
  List<String> filterList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller.text = '';
    _getData();
  }

  _getData() async {
    isLoading = true;
    Map<String, String> header = {
      "Authorization": "Bearer ${widget.token}",
      "Accept": "application/json"
    };
    await MumbaiClinicNetworkCall.getCountryRequest(
      endPoint: widget.endpoint,
      context: context,
      header: header,
      onSuccess: (response) {
        isLoading = false;
        var data = jsonDecode(response);
        for (Map map in data) {
          if (widget.searchKey == 'state')
            allList.add(map['state_name']);
          else
            allList.add(map['city_name']);
        }
      },
      onError: (error) {
        isLoading = false;
      },
    );

    filterList.addAll(allList);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () => Navigator.pop(context),
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (ctnx) {
        return Container(
          padding: const EdgeInsets.all(8),
          height: MediaQuery.of(context).size.height * 0.60,
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Column(
            children: <Widget>[
              SearchView(
                controller: _controller,
                hint: 'Search',
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
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemBuilder: (ctx, index) {
                          return InkWell(
                            onTap: (){
                              Navigator.pop(context);
                              widget.onSelected(filterList[index]);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                filterList[index],
                                maxLines: 1,
                                textScaleFactor: 1.0,
                                overflow: TextOverflow.fade,
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                            ),
                          );
                        },
                        itemCount: filterList.length,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void onSearch(String val) {
    filterList.clear();
    allList.forEach((element) {
      if(element.toLowerCase().contains(val.toLowerCase())){
        filterList.add(element);
      }
    });

    if(val.length==0){
      filterList.addAll(allList);
    }

    setState(() {

    });
  }
}
