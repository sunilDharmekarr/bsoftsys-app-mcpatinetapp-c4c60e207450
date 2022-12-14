import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/family_member_model.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/model/selected_user_model.dart';
import 'package:mumbaiclinic/screen/register/user_form_screen.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/utils/utils.dart';

enum SelectionType { chooseMember, bookAppointment, pickMember }

class SelectMemberDialog extends StatefulWidget {
  final Function(String userId) onSelected;
  final SelectionType selectionType;
  SelectMemberDialog({this.onSelected, @required this.selectionType});

  @override
  _SelectMemberDialogState createState() => _SelectMemberDialogState();
}

class _SelectMemberDialogState extends State<SelectMemberDialog> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                alignment: Alignment.centerLeft,
                child: TextView(
                  text: 'Family Members',
                  style: AppTextTheme.textTheme12Bold,
                ),
              ),
              Flexible(
                child: ListView.builder(
                  itemBuilder: (_, index) {
                    return Container(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          if (widget.selectionType ==
                              SelectionType.bookAppointment) {
                            PreferenceManager.setActiveUserID(
                                _list[index].patid.toString());

                            _selectedUser = SelectedUser(
                              id: _list[index].patid.toString(),
                              fname: _list[index].fullName,
                              mname: _list[index].middleName,
                              sname: _list[index].lastName,
                              sex: _list[index].gender,
                              email: _list[index].email,
                              mobile: _list[index].mobile,
                              dob: _list[index].dob.toString(),
                            );
                            PreferenceManager.setSelectedUser = _selectedUser;
                          } else if (widget.selectionType ==
                              SelectionType.chooseMember) {
                            PreferenceManager.setUserId(
                                _list[index].patid.toString());
                          }
                          widget.onSelected(_list[index].patid.toString());
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: _list[index].profile_pic.isNotEmpty
                                    ? Image.network(
                                        _list[index].profile_pic,
                                        fit: BoxFit.fill,
                                        headers: Utils.getHeaders(),
                                      )
                                    : Container(),
                              ),
                            ),
                            Expanded(
                              child: TextView(
                                text: '${_list[index].fullName}',
                                style: AppTextTheme.textTheme12Light,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  itemCount: _list.length,
                  shrinkWrap: true,
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorTheme.buttonColor,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (_) => UserFormScreen(false)));
                  },
                  child: Center(
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Datum _user;
  SelectedUser _selectedUser;
  String fullName = '';
  String relation = '';
  String dob = '1997-03-08T00:00:00';
  String patientId = '';
  List<FamilyMember> _list = [];

  loadData() async {
    final data = PreferenceManager.getUserFamily();
    final pid = PreferenceManager.getUserId();

    _user = await AppDatabase.db.getUser(pid) as Datum;

    if (_user != null) {
      _selectedUser = SelectedUser(
        id: _user.patid.toString(),
        fname: _user.firstName,
        mname: _user.middleName,
        sname: _user.lastName,
        dob: _user.dob,
        mobile: _user.mobile,
        sex: _user.sex,
        email: _user.email,
      );

      fullName = _user.firstName + ' ' + _user.lastName;
      relation = 'Self';
      dob = _user.dob;
      patientId = _user.patid.toString();
    }

    if (data != 'null' && data != null) {
      final family = familyMemberModelFromJson(data);
      _list.clear();
      _list.addAll(family.familyMember);
      setState(() {});
    }
  }
}
