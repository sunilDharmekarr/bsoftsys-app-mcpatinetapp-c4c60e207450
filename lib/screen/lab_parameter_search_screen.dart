import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/model/CommonLabTest.dart';
import 'package:mumbaiclinic/repository/lab_test_repo.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/search_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class LabParameterSearchScreen extends StatefulWidget {
  static int group=1;
  static int parameter=2;

  final String title;
  final int mode;
  final dynamic id;
  final Function(dynamic data,dynamic id) onSelected;

  LabParameterSearchScreen({this.title, this.onSelected,this.mode,this.id});

  @override
  _LabParameterSearchScreenState createState() => _LabParameterSearchScreenState();
}

class _LabParameterSearchScreenState extends State<LabParameterSearchScreen> {
  final labTestRepo = LabTestRepo();
  final _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _loadData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.getAppBar(widget.title),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            SearchView(
              controller: _controller,
              hint: 'Search',
              onSubmit: (searchKey) {
                FocusScope.of(context).unfocus();
                //_onSearch(searchKey);
              },
              onChange: (key) {
                _search(key);
              },
            ),
            const SizedBox(height: 10 ,),
            Expanded(child: ListView.builder(itemBuilder: (_,index){
              return GestureDetector(
                onTap: (){
                  widget.onSelected?.call(_test[index].test,_test[index].id);
                Navigator.of(context).pop();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ColorTheme.lightGreenOpacity,
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: AppText.getRegularText(_test[index].test , 14  , ColorTheme.darkGreen,),
                ),
              );
            },itemCount: _test.length,))
          ],
        ),
      ),
    );
  }

  List<GroupTest> _test =[];
  List<GroupTest> _Alltest =[];

  _search(String key){
    _test.clear();
    _Alltest.forEach((element) {
      if(element.test.toString().toLowerCase().contains(key.toLowerCase())){
        _test.add(element);
      }
    });

    if(key.length==0){
      _test.addAll(_Alltest);

    }

    setState(() {

    });
  }

  _loadData()async{
    _test.clear();
    Loader.showProgress();

    if(widget.mode==LabParameterSearchScreen.group)
      {
        final data = await labTestRepo.getTestGroup();
        if(data!=null){
          _test = data.groupTest;
        }
      }else{
      final data = await labTestRepo.getTestName(widget.id.toString());
      if(data!=null){
        _test = data.groupTest;
      }
    }
    _Alltest = List.from(_test);
    Loader.hide();
    setState(() {

    });
  }
}
