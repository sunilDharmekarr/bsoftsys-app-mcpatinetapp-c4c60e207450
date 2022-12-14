import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/global/CartData.dart';
import 'package:mumbaiclinic/model/LabTestModel.dart';
import 'package:mumbaiclinic/utils/validation_utils.dart';
import 'package:mumbaiclinic/view/cell/cell_order_test.dart';
import 'package:mumbaiclinic/view/custom/search_view.dart';

class SearchScreen extends StatefulWidget {
  final List<Labtest> labtest;
  final bool istest;

  SearchScreen(this.labtest, this.istest);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  List<Labtest> _list = [];
  List<Labtest> _filter = [];

  bool isChange=false;

  @override
  void initState() {
    super.initState();
    _list = List.from(widget.labtest);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        Navigator.of(context).pop(isChange);
        return;
      },
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
             widget.istest? 'Search Tests':'Search Profile Tests',
              style: Theme.of(context).appBarTheme.textTheme.headline1,
            ),
            actions: [
              IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: ColorTheme.darkGreen,
                  ),
                  onPressed: () => Navigator.of(context).pop(isChange)),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(6),
                  child: SearchView(
                    controller: _controller,
                    hint:  widget.istest? 'Search Test':'Search Profile Test',
                    onSubmit: (searchKey) {
                      FocusScope.of(context).unfocus();
                      //_onSearch(searchKey);
                    },
                    onChange: (key) {
                      _onSearch(key);
                    
                      // _onSearch(key);
                    },
                  ),
                ),
              ),
              SliverFillRemaining(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 1.2,
                      crossAxisCount: 2,
                    ),
                    itemCount: _filter.length,
                    itemBuilder: (_, index) => CellOrderTest(
                      index: index,
                      test: widget.istest,
                      labtest: _filter[index],
                      divider: false,
                      onCartClick: (Labtest data) {
                        CartData.addItems(data);
                        isChange=true;
                        setState(() {});
                      },
                      onClick: () {
                        /* Navigator.of(context).push(
                          CupertinoPageRoute(builder: (_) => TestDetailScreen()));*/
                      },
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  _onSearch(String key) {
    _filter.clear();
    _list.forEach((element) {
      if (element.testName != null &&
          element.testName.toLowerCase().contains(key.toLowerCase()))
        _filter.add(element);
      else if (element.profileName != null &&
          element.profileName.toLowerCase().contains(key.toLowerCase()))
        _filter.add(element);
    });

    if (key.length == 0) _filter.clear();

    setState(() {});
  }
}
