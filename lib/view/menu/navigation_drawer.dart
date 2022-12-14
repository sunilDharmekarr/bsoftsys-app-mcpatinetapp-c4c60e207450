import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/menu_items.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/menu_model.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/screen/my_health_manager.dart';
import 'package:mumbaiclinic/screen/register/user_form_screen.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';

class NavigationDrawer extends StatefulWidget {
  final Function onMenuClick;

  NavigationDrawer({@required this.onMenuClick});

  @override
  _NavigationDrawerState createState() => _NavigationDrawerState();
}

class _NavigationDrawerState extends State<NavigationDrawer> {
  List<MenuModel> navMenus = menus;

  String username = '';
  String age = '';
  String sex = '';
  String profile = '';
  String versionTxt = '';

  @override
  void initState() {
    super.initState();
    versionTxt =
        Constant.appVersionName != null && Constant.appVersionName.isNotEmpty
            ? "Version: ${Constant.appVersionName}"
            : "";
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        height: MediaQuery.of(context).size.height,
        color: ColorTheme.buttonColor,
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.fromLTRB(30, 40, 0, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      MyApplication.pop();
                      Navigator.of(context).push(CupertinoPageRoute(
                          builder: (_) => UserFormScreen(
                                true,
                                pId: PreferenceManager.getUserId(),
                                profile: false,
                              )));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 44,
                          height: 44,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: profile.isNotEmpty
                                ? Image.network(
                                    profile,
                                    fit: BoxFit.fill,
                                    headers: Utils.getHeaders(),
                                  )
                                : Container(),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextView(
                            text:
                                '${username}\nPatient ID: ${PreferenceManager.getUserId()}',
                            color: ColorTheme.white,
                            maxLine: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextTheme.textTheme14Regular,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: ColorTheme.white,
              height: 1,
              thickness: 1.0,
            ),
            Expanded(
              child: ListView.separated(
                itemCount: navMenus.length,
                itemBuilder: (cntx, index) {
                  return InkWell(
                    onTap: () => widget.onMenuClick(navMenus[index]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            navMenus[index].icons,
                            width: 24,
                            height: 24,
                            color: ColorTheme.white,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                            child: TextView(
                              text: navMenus[index].title,
                              color: ColorTheme.white,
                              style: AppTextTheme.textTheme14Light,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (cntx, index) {
                  return Divider(
                    color: Colors.grey[300],
                    thickness: 0.5,
                    height: 0.5,
                  );
                },
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: AppText.getLightText(versionTxt, 11, ColorTheme.white),
            ),
            Divider(
              color: ColorTheme.white,
              height: 1,
              thickness: 1.0,
            ),
            Container(
              height: 60,
              alignment: Alignment.center,
              child: AppText.getButtonText(
                  'My Health Manager', 16, ColorTheme.white, () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) => MyHealthManagerScreen()));
              }),
            ),
          ],
        ),
      ),
    );
  }

  void loadData() async {
    final userId = PreferenceManager.getUserId();
    final userData = await AppDatabase.db.getUser(userId) as Datum;
    username = userData.fullName;
    sex = userData.sex;
    age = Utils.getYears(date: userData.dob);
    profile = userData.profile_pic;
    setState(() {});
  }
}
