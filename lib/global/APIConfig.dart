class APIConfig {
  //This is devlopment URL;
  //static const String BASE_URL = 'http://mumbaiclinic.co.in:5004/api/';

  //This is production URL;
  static const String BASE_URL = 'https://mumbaiclinic.net:9000/api/';

  static const ValidateOTP = BASE_URL + 'Authentication/ValidateOTP';
  static const MobileAuthentication =
      BASE_URL + 'Authentication/MobileAuthentication';
  static const RegisterPatient = BASE_URL + 'Authentication/RegisterPatient';
  static const getSpecialization = BASE_URL + 'Resource/getSpecialization';
  static const getDoctorBySpecialization =
      BASE_URL + 'Resource/getDoctorBySpecialization';
  static const getPatientDetails = BASE_URL + 'Resource/getPatientID?mobile=';
  static const GetFrequentlyConsultedDoctor =
      BASE_URL + 'Patient/GetFrequentlyConsultedDoctor';
  static const ValidateCouponCode = BASE_URL + 'Resource/ValidateCouponCode';
  static const getDoctorSchedule = BASE_URL + 'Doctor/getDoctorSchedule';
  static const checkWalletBalance = BASE_URL + 'Wallet/checkWalletBalance';
  static const CreateAppointment = BASE_URL + 'Appointment/CreateAppointment';
  static const UpdateAppointmentPendingPayment =
      BASE_URL + 'Appointment/updateAppointmentPendingPayment';
  static const GetSymptomsBySpecialisation =
      BASE_URL + 'Appointment/GetSymptomsBySpecialisation';
  static const getWalletDetails = BASE_URL + 'Wallet/getWalletDetails';
  static const getTransactionDetails =
      BASE_URL + '/Patient/getTransactionDetails';
  static const addMoneyToWallet = BASE_URL + 'Wallet/addMoneyToWallet';
  static const getFamily = BASE_URL + 'Patient/getFamily?patid=';
  static const deleteFamilyMember = BASE_URL + 'Patient/deleteFamilyMember';
  static const getAppointmentQuestionsWithAnswers =
      BASE_URL + 'Appointment/getAppointmentQuestionsWithAnswers';
  static const getAppointment = BASE_URL + 'Appointment/getAppointment?patid=';
  static const addAppointmentQuestionAnswer = BASE_URL +
      'Appointment/addAppointmentQuestionAnswer'; //Appointment/addAppointmentQuestionAnswer
  static const getPathLabs = BASE_URL + 'Resource/getPathLabs';
  static const getLabTest = BASE_URL + 'LabTest/getLabTest?lab_id=';
  static const getLabProfile = BASE_URL + 'LabTest/getLabProfile?lab_id=';
  static const AddTestOrder = BASE_URL + 'LabTest/AddTestOrder';
  static const getFrequentlyAskedTest =
      BASE_URL + 'LabTest/getFrequentlyAskedTest?lab_id=';
  static const getLabProfileDetails =
      BASE_URL + 'LabTest/getLabProfileDetails?profile_id=';
  static const getLabServiceFee = BASE_URL + 'LabTest/getLabServiceFee';
  static const getPatientAlerts = BASE_URL + 'Patient/getPatientAlerts?patid=';
  static const readPatientAlert = BASE_URL + 'Patient/readPatientAlert';
  static const readAllPatientAlerts = BASE_URL + 'Patient/readAllPatientAlert';
  static const setPatProfileimageByMobile =
      BASE_URL + 'Patient/setPatProfileimageByMobile';
  static const editPatientDetails = BASE_URL + 'Patient/editPatientDetails';
  static const getAddressTypes = BASE_URL + 'Resource/getAddressType';
  static const getAddresses = BASE_URL + 'Patient/getPatientAddress?patid=';
  static const addEditAddress = BASE_URL + 'Patient/AddEditPatientAddress';
  static const deleteAddress = BASE_URL + 'Patient/DeletePatientAddress';

  static const addAppointmentQuestAnswerAttachment =
      BASE_URL + 'Appointment/addAppointmentQuestAnswerAttachment';
  static const getPatientWeightHistory =
      BASE_URL + 'Patient/getPatientWeightHistory?patientid=';
  static const getPatientHeightHistory =
      BASE_URL + 'Patient/getPatientHeightHistory?patientid=';

  static const getPatientBMIHistory =
      BASE_URL + 'Patient/getPatientBMIHistory?patientid=';

  static const getPatientTempHistory =
      BASE_URL + 'Patient/getPatientTempHistory?patientid=';
  static const getPatientPulseHistory =
      BASE_URL + 'Patient/getPatientPulseHistory?patientid=';
  static const getPatientBPHistory =
      BASE_URL + 'Patient/getPatientBPHistory?patientid=';
  static const getPatientSpo2History =
      BASE_URL + 'Patient/getPatientSpo2History?patientid=';
  static const getPatientSugarHistory =
      BASE_URL + 'Patient/getPatientSugarHistory?patientid=';
  static const getPatientLastVitals =
      BASE_URL + 'Patient/getPatientLastVitals?patientid=';
  static const editPatientVital = BASE_URL + 'Patient/EditVital';
  static const deletePatientVital = BASE_URL + 'Patient/DeleteVital';
  static const getVitalComments =
      BASE_URL + 'Resource/getVitalComments?vital_id=';
  static const getCallBackType = BASE_URL + 'Resource/getCallBackType';
  static const logCallBack = BASE_URL + 'Resource/logCallBack';
  static const getPackages = BASE_URL + 'Package/getPackages';
  static const getPackageDetails =
      BASE_URL + 'Package/getPackageDetails?package_id=';
  static const getHealthManagerDetails =
      BASE_URL + 'Resource/getHealthManagerDetails?patid=';
  static const manageSettings = BASE_URL + 'Resource/manageSettings';
  static const getChatURL = BASE_URL + 'Appointment/getChatURL';
  static const contactUs = BASE_URL + 'Resource/contact_us';
  static const checkAppUpgrade = BASE_URL + 'Resource/checkAPPupgrade';

  static getVideoCallToken(String appointment_id) {
    return BASE_URL +
        'Resource/getVideoCallToken?appointment_id=$appointment_id';
  }

  static getSettings(String patId) {
    return BASE_URL + 'Resource/getSettings?patid=$patId';
  }
}
