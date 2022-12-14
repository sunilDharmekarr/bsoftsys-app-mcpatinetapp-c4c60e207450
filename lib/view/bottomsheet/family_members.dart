import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/APIConfig.dart';
import 'package:mumbaiclinic/global/mumbai_clinic_network_call.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/family_member_model.dart';
import 'package:mumbaiclinic/screen/register/user_form_screen.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

enum MenuOptions { edit, delete }

class FamilyMembers extends StatefulWidget {
  final Function() onSelected;

  FamilyMembers(this.onSelected);

  @override
  _FamilyMembersState createState() => _FamilyMembersState();
}

class _FamilyMembersState extends State<FamilyMembers> {
  List<FamilyMember> _list = [];
  List<FamilyMember> _familyHeadList = [];
  List<FamilyMember> _familyMemberList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Family members',
          style: Theme.of(context).appBarTheme.textTheme.headline1,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(10),
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: CustomScrollView(
          slivers: [
            if (_familyHeadList.length > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextView(
                    text: 'Family Head',
                    style: AppTextTheme.textTheme12Bold,
                  ),
                ),
              ),
            SliverList(
              delegate: SliverChildListDelegate(
                _familyHeadList
                    .map((e) => GestureDetector(
                          onTap: () {
                            widget.onSelected?.call();
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.lightBlueAccent.withOpacity(0.1),
                                  boxShadow: Utils.getShadow(),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 70,
                                      margin: const EdgeInsets.all(10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          httpHeaders: Utils.getHeaders(),
                                          imageUrl: "${e.profile_pic}",
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              Center(
                                            child: CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Opacity(
                                            opacity: 0.5,
                                            child: Image.asset(
                                              AppAssets.about_Mumbai_clinic,
                                              color: Colors.grey[200],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        FittedBox(
                                          child: TextView(
                                            text: e.fullName,
                                            style: AppTextTheme.textTheme13Bold,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        TextView(
                                          text:
                                              '${e.gender ?? ''} |${Utils.getYears(date: e.dob.toString())} Yrs',
                                          style: AppTextTheme.textTheme12Light,
                                        ),
                                        TextView(
                                          text: 'PID: ${e.patid}',
                                          style: AppTextTheme.textTheme12Light,
                                        ),
                                        TextView(
                                          text:
                                              'DOB: ${Utils.getReadableDate(e.dob)}',
                                          style: AppTextTheme.textTheme12Light,
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              _createOptionsButton(e.patid.toString(),
                                  isFamilyHead: true),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                if (_familyMemberList.length > 0)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextView(
                      text: 'Family Members',
                      style: AppTextTheme.textTheme12Bold,
                    ),
                  )
              ]),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                _familyMemberList
                    .map((e) => GestureDetector(
                          onTap: () {
                            widget.onSelected?.call();
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                constraints: BoxConstraints(
                                    maxHeight: 150, minHeight: 80),
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: ColorTheme.lightGreenOpacity,
                                  boxShadow: Utils.getShadow(),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 70,
                                      width: 70,
                                      margin: const EdgeInsets.all(10),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          httpHeaders: Utils.getHeaders(),
                                          imageUrl: "${e.profile_pic}",
                                          progressIndicatorBuilder: (context,
                                                  url, downloadProgress) =>
                                              Center(
                                            child: CircularProgressIndicator(
                                                value:
                                                    downloadProgress.progress),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Opacity(
                                            opacity: 0.5,
                                            child: Image.asset(
                                              AppAssets.about_Mumbai_clinic,
                                              color: Colors.grey[200],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          FittedBox(
                                            child: TextView(
                                              text: e.fullName,
                                              style:
                                                  AppTextTheme.textTheme13Bold,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 6,
                                          ),
                                          Row(
                                            children: [
                                              AppText.getLightText(
                                                  '${e.gender ?? ''} | ${Utils.getYears(date: e.dob.toString())} Yrs',
                                                  12,
                                                  ColorTheme.darkGreen),
                                              Expanded(
                                                child: AppText.getLightText(
                                                    'Relation: ${e.relationName}',
                                                    12,
                                                    ColorTheme.darkGreen,
                                                    textAlign: TextAlign.end),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              AppText.getLightText(
                                                  'PID: ${e.patid}',
                                                  12,
                                                  ColorTheme.darkGreen),
                                              Expanded(
                                                child: AppText.getLightText(
                                                    'DOB: ${Utils.getReadableDate(e.dob)}',
                                                    12,
                                                    ColorTheme.darkGreen,
                                                    textAlign: TextAlign.end),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              _createOptionsButton(e.patid.toString()),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                height: 40,
                margin:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: AppButton(
                  text: 'Add Family',
                  style: AppTextTheme.textTheme14Bold,
                  onClick: () {
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (_) => UserFormScreen(false)));
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _loadData() async {
    final data = PreferenceManager.getUserFamily();
    if (data != 'null' && data != null) {
      final family = familyMemberModelFromJson(data);
      _list.clear();
      _familyHeadList.clear();
      _familyMemberList.clear();
      _list.addAll(family.familyMember);

      _list.forEach((element) {
        if (element.fhead) {
          _familyHeadList.add(element);
        } else {
          _familyMemberList.add(element);
        }
      });
      setState(() {});
    }
  }

  Widget _createOptionsButton(String patId, {bool isFamilyHead = false}) {
    return Positioned(
      child: PopupMenuButton<MenuOptions>(
        icon: Icon(
          Icons.more_vert,
        ),
        iconSize: 16,
        padding: EdgeInsets.fromLTRB(16, 6, 6, 16),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<MenuOptions>>[
          const PopupMenuItem<MenuOptions>(
            child: Text('Edit'),
            value: MenuOptions.edit,
          ),
          PopupMenuItem<MenuOptions>(
            child: Text('Delete'),
            value: MenuOptions.delete,
            enabled: !isFamilyHead,
          ),
        ],
        onSelected: (MenuOptions option) {
          if (option == MenuOptions.edit) {
            Navigator.of(context).push(CupertinoPageRoute(
                builder: (_) => UserFormScreen(
                      true,
                      pId: patId,
                    )));
          } else if (option == MenuOptions.delete) {
            _deleteFamilyMember(patId);
          }
        },
      ),
      top: 0,
      right: 0,
    );
  }

  _deleteFamilyMember(String patId) async {
    final body = {
      "patid": PreferenceManager.getUserId(),
      "remove_patid": patId,
    };
    Loader.showProgress();
    await MumbaiClinicNetworkCall.postRequest(
      endPoint: APIConfig.deleteFamilyMember,
      header: Utils.getHeaders(),
      body: body,
      onSuccess: (response) {
        if (response != null) {
          final model = familyMemberModelFromJson(response);
          if (model.success == 'true') {
            AppDatabase.db.addBatchUsers(model.familyMember);
            PreferenceManager.setUserFamily(response);
            _loadData();
          } else {
            Utils.showToast(
                message: 'Delete failed: ${model.error}', isError: true);
          }
        } else {
          Utils.showToast(message: 'Failed to delete', isError: true);
        }
      },
      onError: (error) {
        Utils.showToast(message: 'Delete failed: $error', isError: true);
      },
    );
    Loader.hide();
  }
}
