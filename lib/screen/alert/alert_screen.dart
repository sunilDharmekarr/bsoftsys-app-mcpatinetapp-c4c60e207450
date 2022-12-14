import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/model/alert_model.dart';
import 'package:mumbaiclinic/repository/alert_repo.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class MyAlertScreen extends StatefulWidget {
  @override
  _MyAlertScreenState createState() => _MyAlertScreenState();
}

class _MyAlertScreenState extends State<MyAlertScreen> {
  List<Alert> alert = [];
  final AlertRepo _alertRepo = AlertRepo();
  int count = 0;

  @override
  void initState() {
    super.initState();
    _getAlert();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        count = alert.where((element) => !element.isRead).toList().length;
        Navigator.of(context).pop(count);
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Text(
            'My Alerts',
            style: Theme.of(context).appBarTheme.textTheme.headline1,
          ),
          leading: IconButton(
            onPressed: () {
              count = alert.where((element) => !element.isRead).toList().length;
              Navigator.of(context).pop(count);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).primaryColor,
            ),
          ),
          actions: <Widget>[
            alert.any((element) => !element.isRead)
                ? IconButton(
                    icon: const Icon(Icons.done_all),
                    tooltip: 'Clear unread status',
                    onPressed: () {
                      _readAll();
                    },
                  )
                : SizedBox.shrink(),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            alert.length == 0
                ? SliverFillRemaining(
                    child: Center(
                      child: AppText.getBoldText('No Data.', 14, Colors.grey),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildListDelegate(
                      alert
                          .map<Widget>(
                            (e) => Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 0),
                              child: GestureDetector(
                                onTap: () {
                                  _read(e.alertId);
                                  setState(() {
                                    e.read = true;
                                  });
                                  Utils.showSingleButtonAlertDialog(
                                      context: context,
                                      message: e.alertDetails,
                                      onClick: () {});
                                },
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: Utils.getShadow(),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 30,
                                        child: Center(
                                          child: Image.asset(
                                            e.isRead
                                                ? AppAssets.alert_green
                                                : AppAssets.alert_red,
                                            width: 24,
                                            height: 24,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 14, horizontal: 4),
                                            child: RichText(
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              textScaleFactor: 1.0,
                                              text: TextSpan(children: [
                                                TextSpan(
                                                  text:
                                                      '${Utils.getReadableDateTime(e.alertDate)}\n',
                                                  style: TextStyle(
                                                      color:
                                                          ColorTheme.darkGreen,
                                                      fontSize: AppTextTheme
                                                          .textSize15,
                                                      fontFamily:
                                                          TextFont.poppinsBold),
                                                ),
                                                TextSpan(
                                                  text: e.alertDetails,
                                                  style: TextStyle(
                                                    color: e.isRead
                                                        ? ColorTheme.darkGreen
                                                            .withOpacity(0.8)
                                                        : ColorTheme.darkRed,
                                                    fontSize:
                                                        AppTextTheme.textSize13,
                                                    fontFamily:
                                                        TextFont.poppinsLight,
                                                  ),
                                                )
                                              ]),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  _getAlert() async {
    Loader.showProgress();
    alert.clear();
    final model = await _alertRepo.getAlertData();
    Loader.hide();
    if (model != null) {
      alert.addAll(model.alert);
      setState(() {});
    }
  }

  _read(id) async {
    await _alertRepo.readAlert(id);
  }

  _readAll() async {
    Loader.showProgress();
    var error = await _alertRepo.readAllAlerts();
    if (error == null) {
      setState(() {
        for (int i = 0; i < alert.length; i++) {
          alert[i].isRead = true;
        }
      });
    } else {
      Utils.showAlertDialog(context: context, message: error);
    }
    Loader.hide();
  }
}
