import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/family_member_model.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/app_text.dart';

class FamilyHorizontalView extends StatefulWidget {
  final Function(String id) onUserClick;

  FamilyHorizontalView(this.onUserClick);

  @override
  _FamilyHorizontalViewState createState() => _FamilyHorizontalViewState();
}

class _FamilyHorizontalViewState extends State<FamilyHorizontalView> {
  List<FamilyMember> _list = [];
  String id = '';
  @override
  void initState() {
    super.initState();
    id = PreferenceManager.getUserId();
    loadata();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      width: MediaQuery.of(context).size.height,
      color: ColorTheme.lightGreenOpacity,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: _list
            .map<Widget>(
              (e) => GestureDetector(
                onTap: () {
                  id = e.patid.toString();
                  widget.onUserClick?.call(e.patid.toString());
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: ColorTheme.lightGreenOpacity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 70,
                        width: 70,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: id == e.patid.toString()
                              ? ColorTheme.buttonColor
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            httpHeaders: Utils.getHeaders(),
                            imageUrl: "${e.profile_pic}",
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) => Center(
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress),
                            ),
                            errorWidget: (context, url, error) => Opacity(
                              opacity: 0.5,
                              child: Image.asset(
                                AppAssets.about_Mumbai_clinic,
                                color: Colors.grey[200],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      AppText.getLightText(
                          e.firstName.isEmpty
                              ? e.fullName.substring(0, 8)
                              : e.firstName,
                          12,
                          ColorTheme.darkGreen),
                      const SizedBox(
                        height: 6,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  loadata() async {
    final data = PreferenceManager.getUserFamily();
    if (data != 'null' && data != null) {
      final family = familyMemberModelFromJson(data);
      _list.clear();
      _list.addAll(family.familyMember);
      setState(() {});
    }
  }
}
