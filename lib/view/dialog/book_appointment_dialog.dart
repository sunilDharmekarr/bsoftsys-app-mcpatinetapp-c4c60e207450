import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/model/ConsultFees.dart' as fees;
import 'package:mumbaiclinic/model/doc_by_specialization.dart';
import 'package:mumbaiclinic/repository/lab_test_repo.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
// import 'package:webview_flutter/webview_flutter.dart';

class BookAppointmentDialog extends StatefulWidget {
  final Doctor doctor;
  final Function onTypeClick;
  final ConsulationType type;
  final bool follow;
  final bool isFast;
  BookAppointmentDialog(
      {this.doctor,
      this.onTypeClick,
      this.type,
      this.follow = false,
      this.isFast = false});

  @override
  _BookAppointmentDialogState createState() => _BookAppointmentDialogState();
}

class _BookAppointmentDialogState extends State<BookAppointmentDialog> {
  final labTestRepo = LabTestRepo();
  int count = 0;
  int index = 0;
  ConsulationType _type;
  String amount = '0';
  var video = '0';
  var home = '0';
  var visit = '0';
  bool loader = true;
  // final Completer<WebViewController> _controller =
  //     Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    _type = widget.type;
    _getFees();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      key: UniqueKey(),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 6.0,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    height: 80,
                    width: 80,
                    margin: const EdgeInsets.fromLTRB(0, 14, 14, 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: NetworkImage(
                          '${widget.doctor.photopath}',
                          headers: Utils.getHeaders(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 12, bottom: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextView(
                            text: widget.doctor.name,
                            style: AppTextTheme.textTheme14Bold,
                          ),
                          TextView(
                            text: widget.doctor.specializationName +
                                '/' +
                                widget.doctor.qualification,
                            style: AppTextTheme.textTheme10Light,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GestureDetector(
                onTap: () {
                  MyApplication.navigateToWebPage(
                      'Map', widget.doctor.googleLocation);
                },
                child: Row(
                  children: [
                    Image.asset(
                      AppAssets.location,
                      width: 18,
                      height: 18,
                      color: ColorTheme.lightGreen,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    TextView(
                      text: widget.doctor.clinicAddress,
                      maxLine: 2,
                      style: AppTextTheme.textTheme10Light,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
              child: TextView(
                text: widget.doctor.languageKnown,
                style: AppTextTheme.textTheme14Bold,
              ),
            ),
            widget.doctor.doctorDetails.isEmpty
                ? Container()
                : Container(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 40),
                    height: 130,
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        child: TextView(
                          text: widget.doctor.doctorDetails,
                          textAlign: TextAlign.justify,
                          style: AppTextTheme.textTheme12Light,
                        ),
                      ),
                    ),
                  ),
            loader
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Row(
                    children: (visit == '0' && video == '0' && home == '0')
                        ? <Widget>[]
                        : <Widget>[
                            if (widget.doctor.videoConsult == 'true')
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _type = ConsulationType.Online;
                                    amount = video;
                                    setState(() {});
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: (_type == ConsulationType.Online)
                                            ? ColorTheme.buttonColor
                                            : Colors.grey[200],
                                        border: Border(
                                            right: BorderSide(
                                                color: ColorTheme.darkGreen))),
                                    padding: const EdgeInsets.all(4),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        TextView(
                                          text: 'Online\nConsult',
                                          color:
                                              (_type == ConsulationType.Online)
                                                  ? ColorTheme.white
                                                  : ColorTheme.darkGreen,
                                          textAlign: TextAlign.center,
                                          style: AppTextTheme.textTheme12Light,
                                        ),
                                        TextView(
                                          text: 'Rs.$video',
                                          color:
                                              (_type == ConsulationType.Online)
                                                  ? ColorTheme.white
                                                  : ColorTheme.darkGreen,
                                          style: AppTextTheme.textTheme14Bold,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (widget.doctor.clinicConsult == 'true')
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _type = ConsulationType.Clinic;
                                    amount = visit;
                                    setState(() {});
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: (_type == ConsulationType.Clinic)
                                            ? ColorTheme.buttonColor
                                            : Colors.grey[200],
                                        border: Border(
                                            right: BorderSide(
                                                color: ColorTheme.darkGreen))),
                                    padding: const EdgeInsets.all(4),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        TextView(
                                          text: 'Clinic\nVisit',
                                          color:
                                              (_type == ConsulationType.Clinic)
                                                  ? ColorTheme.white
                                                  : ColorTheme.darkGreen,
                                          textAlign: TextAlign.center,
                                          style: AppTextTheme.textTheme12Light,
                                        ),
                                        TextView(
                                          text: 'Rs.$visit',
                                          color:
                                              (_type == ConsulationType.Clinic)
                                                  ? ColorTheme.white
                                                  : ColorTheme.darkGreen,
                                          style: AppTextTheme.textTheme14Bold,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            if (widget.doctor.homeVisit == 'true')
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    _type = ConsulationType.Home;
                                    amount = home;
                                    setState(() {});
                                  },
                                  child: Container(
                                    color: (_type == ConsulationType.Home)
                                        ? ColorTheme.buttonColor
                                        : Colors.grey[200],
                                    padding: const EdgeInsets.all(4),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        TextView(
                                          text: 'Home\nVisit',
                                          color: (_type == ConsulationType.Home)
                                              ? ColorTheme.white
                                              : ColorTheme.darkGreen,
                                          textAlign: TextAlign.center,
                                          style: AppTextTheme.textTheme12Light,
                                        ),
                                        TextView(
                                          text: 'Rs.$home',
                                          color: (_type == ConsulationType.Home)
                                              ? ColorTheme.white
                                              : ColorTheme.darkGreen,
                                          style: AppTextTheme.textTheme14Bold,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                  ),
            if (!loader)
              GestureDetector(
                onTap: () =>
                    widget.onTypeClick(_type, amount, widget.doctor.doctorId),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(14, 20, 14, 20),
                  decoration: BoxDecoration(
                    color: ColorTheme.buttonColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: Utils.getShadow(shadow: 0.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: TextView(
                        text: (visit == '0' && video == '0' && home == '0')
                            ? 'Request Appointment'
                            : 'Book Appointment',
                        color: Colors.white,
                        style: AppTextTheme.textTheme14Bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _updateAmount() {
    if (_type == ConsulationType.Online) amount = '$video';
    if (_type == ConsulationType.Clinic) amount = '$visit';
    if (_type == ConsulationType.Home) amount = '$home';
  }

  _getFees() async {
    if (widget.follow) {
      widget.doctor.consultFees.forEach((element) {
        if (element.consult_type == 'Video Consult')
          video = double.parse(element.followup_consultation_fee.toString())
              .toStringAsFixed(0);
        if (element.consult_type == 'Clinic Consult')
          visit = double.parse(element.followup_consultation_fee.toString())
              .toStringAsFixed(0);
        if (element.consult_type == 'Home Visit')
          home = double.parse(element.followup_consultation_fee.toString())
              .toStringAsFixed(0);
      });
      _updateAmount();
    } else {
      fees.ConsultFees data;
      if (widget.isFast)
        data = await labTestRepo
            .getFastAppointmentDoctorFee(widget.doctor.doctorId.toString());
      else
        data =
            await labTestRepo.getDoctorFees(widget.doctor.doctorId.toString());

      var error = 'Failed to load consultation fees';
      if (data != null) {
        if (data.success == 'true') {
          error = null;
          if (data.fee.length > 0) {
            data.fee.forEach((element) {
              if (element.consultType == 'Video Consult')
                video = element.firstConsultationFee.toString();
              if (element.consultType == 'Clinic Consult')
                visit = element.firstConsultationFee.toString();
              if (element.consultType == 'Home Visit')
                home = element.firstConsultationFee.toString();
            });
          } else {
            video = visit = home = '0';
          }
          _updateAmount();
        } else {
          error = 'Failed to load consultation fees: ${data.error}';
        }
      }
      if (error != null) {
        Utils.showToast(message: error, isError: true);
      }
    }
    loader = false;

    setState(() {});
  }
}
