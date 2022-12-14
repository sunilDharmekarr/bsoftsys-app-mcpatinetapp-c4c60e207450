import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/database/app_database.dart';
import 'package:mumbaiclinic/global/constant.dart';
import 'package:mumbaiclinic/global/preference_manager.dart';
import 'package:mumbaiclinic/model/register_model.dart';
import 'package:mumbaiclinic/model/specialization_model.dart';
import 'package:mumbaiclinic/model/frequently_doctor.dart';
import 'package:mumbaiclinic/repository/appointment_repo.dart';
import 'package:mumbaiclinic/screen/consulttype/consult_type_screen.dart';
import 'package:mumbaiclinic/utils/utils.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';
import 'package:mumbaiclinic/view/loader/custome_loader.dart';

class BookAppointment extends StatefulWidget {
  final bool isFastAppointment;

  BookAppointment({this.isFastAppointment = false});

  @override
  _BookAppointmentState createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  List<Specialization> _specialization = [];
  List<Frequently> _frequetly = [];

  String token = '';
  String username = '';
  String gender = '';
  String age = '';
  String pid = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.isFastAppointment
              ? 'Book Fast Appointments'
              : Constant.BOOK_APPOINTMENT,
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
      body: Container(
        child: Column(
          children: <Widget>[
            /* Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi,',
                              style: AppTextTheme.textThemeNameLabel
                                  .apply(color: Colors.black87),
                            ),
                            FittedBox(
                              child: Text(
                                '$username($gender/$age)',
                                style: AppTextTheme.textThemeNameLabel
                                    .apply(color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ), */
            _frequetly.length == 0
                ? Container()
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    color: ColorTheme.darkGreen,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: TextView(
                            text: 'Frequent Consulted Doctor',
                            style: AppTextTheme.textTheme12Light,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          height: 70,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: _frequetly.map((e) {
                              return InkWell(
                                onTap: () {
                                  /* Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (_) =>
                                        ConsultTypeScreen('Dr.Anil Gupta')));*/
                                },
                                child: Container(
                                  width: 200,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: TextView(
                                            text: 'Dr.',
                                            color: ColorTheme.white,
                                            style: AppTextTheme.textTheme12Bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            FittedBox(
                                                child: TextView(
                                                    text: e.name,
                                                    style: AppTextTheme
                                                        .textTheme13Bold,
                                                    color: Colors.white)),
                                            /* TextView(
                                        text: 'Family Physician',
                                        style: AppTextTheme.textTheme12Light,
                                      ),*/
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                          width: 1,
                                          height: 50,
                                          color: ColorTheme.white)
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )
                      ],
                    ),
                  ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                  itemBuilder: (cntx, index) {
                    var data = _specialization[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      margin: const EdgeInsets.only(top: 20),
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          PreferenceManager.specializationId = data.id;
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (_) => ConsultTypeScreen(
                                        data.description,
                                        data.id,
                                        isFastAppointment:
                                            widget.isFastAppointment,
                                      )));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: ColorTheme.lightGreenOpacity,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: Utils.getShadow(),
                          ),
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                height: 28,
                                width: 28,
                                child: Image.network(
                                  data.iconPath,
                                  headers: Utils.getHeaders(token: token),
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    TextView(
                                      text: data.specializationName,
                                      style: AppTextTheme.textTheme13Bold,
                                    ),
                                    const SizedBox(height: 2),
                                    TextView(
                                      text: data.description,
                                      style: AppTextTheme.textTheme12Light,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: Center(
                                  child: Image.asset(
                                    AppAssets.arrow_right,
                                    width: 18,
                                    height: 18,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: _specialization.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  loadData() async {
    // SelectedUser user = PreferenceManager.selectedUser;
    pid = PreferenceManager.getUserId();
    Datum model = await AppDatabase.db.getUser(pid);
    if (model != null) {
      username = model.fullName;
      gender = model.sex.toUpperCase();
      var date = model.dob;
      age = Utils.getYears(date: date);
    }

    setState(() {});
    _getFrequentlyConsultedDoctor();
    if (widget.isFastAppointment) {
      _getFastAppointmentSpecialization();
    } else {
      _getSpecialization();
    }
  }

  final appointmentRepository = AppointmentRepository();

  _getSpecialization() async {
    Loader.showProgress();
    final model = await appointmentRepository.getSpecialization();
    Loader.hide();

    if (model != null) {
      _specialization.clear();
      _specialization.addAll(model.specialization);
      setState(() {});
    }
  }

  _getFrequentlyConsultedDoctor() async {
    final model = await appointmentRepository.getFrequentlyConsultedDoctor();
    if (model != null) {
      _frequetly.clear();
      _frequetly.addAll(model.frequently);
      setState(() {});
    }
  }

  _getFastAppointmentSpecialization() async {
    Loader.showProgress();
    final model =
        await appointmentRepository.getFastAppointmentSpecialization();
    Loader.hide();

    if (model != null) {
      _specialization.clear();
      _specialization.addAll(model.specialization);
      setState(() {});
    }
  }
}
