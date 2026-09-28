// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'ஸ்மார்ட் கள கண்காணிப்பு';

  @override
  String get appTagline => 'கள செயல்பாட்டு கண்காணிப்பு';

  @override
  String get loginHeader => 'ஸ்மார்ட் வருகைப்பதிவு';

  @override
  String get loginHint =>
      'பஞ்சாயத்து அலுவலகம் வழங்கிய பணியாளர் அடையாள எண்ணைக் கொண்டு உள்நுழையவும்.';

  @override
  String get employeeIdLabel => 'பணியாளர் அடையாள எண்';

  @override
  String get passwordLabel => 'கடவுச்சொல் அல்லது OTP';

  @override
  String get signInAction => 'உள்நுழை';

  @override
  String get signingInAction => 'உள்நுழைகிறது...';

  @override
  String get loginFailed =>
      'உள்நுழைவு தோல்வியடைந்தது. பணியாளர் அடையாள எண் மற்றும் கடவுச்சொல்லை சரிபார்க்கவும்.';

  @override
  String get loginRequiresConnection =>
      'முதல் முறை உள்நுழைவுக்கு இணைய இணைப்பு தேவை.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTamil => 'தமிழ்';

  @override
  String get sessionExpired =>
      'உங்கள் அமர்வு காலாவதியானது. மீண்டும் உள்நுழையவும்.';

  @override
  String get mobileOtpTab => 'மொபைல் OTP';

  @override
  String get employeeLoginTab => 'பணியாளர் உள்நுழைவு';

  @override
  String get mobileOtpHint =>
      'ஒருமுறை கடவுச்சொல்லைப் பெற உங்கள் பதிவு செய்யப்பட்ட மொபைல் எண்ணை உள்ளிடவும்.';

  @override
  String get mobileNumberLabel => 'மொபைல் எண்';

  @override
  String get mobileNumberInvalid => 'சரியான 10 இலக்க மொபைல் எண்ணை உள்ளிடவும்.';

  @override
  String get sendOtpAction => 'OTP அனுப்பு';

  @override
  String get sendingOtp => 'OTP அனுப்பப்படுகிறது...';

  @override
  String get otpSent => 'உங்கள் மொபைல் எண்ணுக்கு OTP அனுப்பப்பட்டது.';

  @override
  String get otpLabel => 'ஒருமுறை கடவுச்சொல்';

  @override
  String get otpInvalid => 'உங்கள் தொலைபேசிக்கு அனுப்பிய OTP-யை உள்ளிடவும்.';

  @override
  String get verifyOtpAction => 'சரிபார்த்து உள்நுழையவும்';

  @override
  String get verifyingOtp => 'OTP சரிபார்க்கப்படுகிறது...';

  @override
  String get resendOtpAction => 'OTP மீண்டும் அனுப்பு';

  @override
  String get otpAutofillNote =>
      'SMS வந்தவுடன் உங்கள் தொலைபேசி OTP-யை தானாக பரிந்துரைக்கலாம்.';

  @override
  String get navToday => 'இன்று';

  @override
  String get navTasks => 'பணிகள்';

  @override
  String get navHistory => 'வரலாறு';

  @override
  String get navProfile => 'சுயவிவரம்';

  @override
  String greetingMorning(String name) {
    return 'காலை வணக்கம், $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'மதிய வணக்கம், $name';
  }

  @override
  String greetingEvening(String name) {
    return 'மாலை வணக்கம், $name';
  }

  @override
  String get attendancePending => 'இன்றைய வருகைப்பதிவு நிலுவையில் உள்ளது';

  @override
  String dutyStartsAt(String time) {
    return 'பணி $time மணிக்கு தொடங்கும்';
  }

  @override
  String checkedInAt(String time) {
    return '$time மணிக்கு உள்நுழைவு பதிவானது';
  }

  @override
  String checkedOutAt(String time) {
    return '$time மணிக்கு வெளியேறுதல் பதிவானது';
  }

  @override
  String get locationVerifiedForToday =>
      'இன்றைய இருப்பிடம் மற்றும் புகைப்படம் சரிபார்க்கப்பட்டது';

  @override
  String get markAttendanceAction => 'வருகைப்பதிவு செய்';

  @override
  String get markCheckOutAction => 'வெளியேறுதலைப் பதிவு செய்';

  @override
  String get attendanceCompleted => 'இன்றைய வருகைப்பதிவு முடிந்தது';

  @override
  String get todaysSchedule => 'இன்றைய அட்டவணை';

  @override
  String get reportFieldActivityAction => 'கள செயல்பாட்டைப் பதிவு செய்';

  @override
  String pendingSyncBanner(String count) {
    return '$count பதிவுகள் ஒத்திசைவுக்காகக் காத்திருக்கின்றன';
  }

  @override
  String get allRecordsSynced =>
      'அனைத்து பதிவுகளும் சேவையகத்துடன் ஒத்திசைக்கப்பட்டன';

  @override
  String get offlineBanner =>
      'இணையம் இல்லை - பதிவுகள் இந்தச் சாதனத்தில் சேமிக்கப்படுகின்றன';

  @override
  String get onlineBanner => 'இணையம் உள்ளது';

  @override
  String recordsPendingSync(String count) {
    return '$count நிலுவை';
  }

  @override
  String get markAttendanceTitle => 'வருகைப்பதிவு';

  @override
  String get attendanceTypeCheckIn => 'உள்நுழைவு';

  @override
  String get attendanceTypeCheckOut => 'வெளியேறுதல்';

  @override
  String get statusGettingGps => 'GPS இருப்பிடம் பெறப்படுகிறது';

  @override
  String get statusCapturingPhoto => 'வருகை புகைப்படம் எடுக்கப்படுகிறது';

  @override
  String get statusVerifying => 'இருப்பிடம் மற்றும் முகம் சரிபார்க்கப்படுகிறது';

  @override
  String get gpsCoordinates => 'GPS ஆயத்தொலைவுகள் மற்றும் துல்லியம்';

  @override
  String gpsReading(String latitude, String longitude, String accuracy) {
    return '$latitude, $longitude  •  துல்லியம் $accuracy மீ';
  }

  @override
  String get gpsUnavailable => 'GPS இருப்பிடம் இன்னும் கிடைக்கவில்லை';

  @override
  String insideGeofence(String site, String distance) {
    return 'ஒதுக்கப்பட்ட பகுதிக்குள் உள்ளது ($site, மையத்திலிருந்து $distance மீ)';
  }

  @override
  String outsideGeofence(String distance) {
    return 'ஒதுக்கப்பட்ட பகுதிக்கு வெளியே $distance மீ';
  }

  @override
  String get photoCaptured => 'வருகை புகைப்படம் எடுக்கப்பட்டது';

  @override
  String get photoNotCaptured => 'வருகை புகைப்படம் நிலுவையில்';

  @override
  String get photographAction => 'புகைப்படம் எடு';

  @override
  String get selfieQrVerification => 'செல்ஃபி / QR சரிபார்ப்பு';

  @override
  String get geofenceVerification => 'புவிவேலி மற்றும் முக சரிபார்ப்பு';

  @override
  String get submitAttendanceAction => 'வருகையைச் சமர்ப்பி';

  @override
  String get continueAction => 'தொடரவும்';

  @override
  String get attendanceMarkedTitle => 'வருகைப்பதிவு செய்யப்பட்டது';

  @override
  String get attendanceMarkedBody =>
      'GPS, நேரம் மற்றும் வருகை புகைப்படம் பதிவு செய்யப்பட்டது. நீங்கள் ஒதுக்கப்பட்ட புவிவேலிக்குள் உள்ளீர்கள்.';

  @override
  String get attendanceQueuedBody =>
      'GPS, நேரம் மற்றும் வருகை புகைப்படம் இந்தச் சாதனத்தில் சேமிக்கப்பட்டது; இணைய இணைப்பு கிடைத்ததும் ஒத்திசைக்கப்படும்.';

  @override
  String get photoOnlyModeNote =>
      'புகைப்பட ஆதாரம் சாதனத்தில் சேமிக்கப்படுகிறது. ஒத்திசைவுக்குப் பின் முக சரிபார்ப்பு சேவையகத்தில் நடைபெறும்.';

  @override
  String get doneAction => 'முடிந்தது';

  @override
  String get retryAction => 'மீண்டும் முயற்சி';

  @override
  String get closeAction => 'மூடு';

  @override
  String get loadingLabel => 'ஏற்றப்படுகிறது...';

  @override
  String get genericError => 'ஏதோ தவறு நடந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get locationPermissionDenied =>
      'இருப்பிட அனுமதி மறுக்கப்பட்டது. வருகைப்பதிவு செய்ய அமைப்புகளில் அனுமதிக்கவும்.';

  @override
  String get locationServiceDisabled =>
      'வருகைப்பதிவு செய்ய சாதனத்தின் இருப்பிடத்தை (GPS) இயக்கவும்.';

  @override
  String get cameraPermissionDenied =>
      'கேமரா அனுமதி மறுக்கப்பட்டது. ஆதாரப் புகைப்படம் எடுக்க அமைப்புகளில் அனுமதிக்கவும்.';

  @override
  String get assignedForToday => 'இன்றைக்கு ஒதுக்கப்பட்ட பணிகள்';

  @override
  String get taskStatusUpcoming => 'வரவிருக்கும்';

  @override
  String get taskStatusInProgress => 'நடைபெறுகிறது';

  @override
  String get taskStatusCompleted => 'முடிந்தது';

  @override
  String get noTasks => 'இன்று ஒதுக்கப்பட்ட பணிகள் இல்லை';

  @override
  String get reportActivityTitle => 'கள செயல்பாட்டு அறிக்கை';

  @override
  String get activityTypeLabel => 'செயல்பாட்டு வகை';

  @override
  String get activityTypeStreetSanitation => 'தெரு சுத்தம்';

  @override
  String get activityTypeToiletInspection => 'பொது கழிப்பறை ஆய்வு';

  @override
  String get activityTypeDrainageInspection => 'வடிகால் ஆய்வு';

  @override
  String get activityTypeOther => 'இதர களப் பணி';

  @override
  String get remarksLabel => 'குறிப்புகள்';

  @override
  String get remarksHint =>
      'முடிக்கப்பட்ட பணி அல்லது கண்டறியப்பட்ட பிரச்சினைகளை விவரிக்கவும்';

  @override
  String get evidencePhotoAction => 'ஆதாரப் புகைப்படம் எடு';

  @override
  String evidencePhotoCount(String count) {
    return '$count ஆதாரப் புகைப்படங்கள் இணைக்கப்பட்டுள்ளன';
  }

  @override
  String get saveActivityAction => 'செயல்பாட்டைச் சேமி';

  @override
  String get activitySavedLocally =>
      'செயல்பாடு இந்தச் சாதனத்தில் சேமிக்கப்பட்டு ஒத்திசைவு வரிசையில் சேர்க்கப்பட்டது.';

  @override
  String get activitySavedAndSynced =>
      'செயல்பாடு சேமிக்கப்பட்டு சேவையகத்துடன் ஒத்திசைக்கப்பட்டது.';

  @override
  String get activitySaveFailed =>
      'செயல்பாட்டைச் சேமிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get evidenceRequired =>
      'குறைந்தது ஒரு ஆதாரப் புகைப்படத்தை இணைக்கவும்.';

  @override
  String get attendanceHistory => 'வருகை வரலாறு';

  @override
  String get statusVerified => 'சரிபார்க்கப்பட்டது';

  @override
  String get statusLate => 'தாமதம்';

  @override
  String get statusSynced => 'ஒத்திசைக்கப்பட்டது';

  @override
  String get statusPending => 'ஒத்திசைவு நிலுவை';

  @override
  String get statusFailed => 'ஒத்திசைவு தோல்வி';

  @override
  String get statusOffline => 'இணையமின்றி சேமிக்கப்பட்டது';

  @override
  String get noHistory => 'வருகைப் பதிவுகள் இன்னும் இல்லை';

  @override
  String historyIn(String time) {
    return 'உள்நுழைவு $time';
  }

  @override
  String historyOut(String time) {
    return 'வெளியேறுதல் $time';
  }

  @override
  String get refreshAction => 'புதுப்பி';

  @override
  String get profileAssignedArea => 'ஒதுக்கப்பட்ட பகுதி';

  @override
  String get profileMobileNumber => 'கைபேசி எண்';

  @override
  String profileDesignation(String designation, String employeeId) {
    return '$designation • $employeeId';
  }

  @override
  String profileJoinedOn(String date) {
    return '$date அன்று பணியில் சேர்ந்தவர்';
  }

  @override
  String get profileLanguage => 'மொழி';

  @override
  String get profileSyncNow => 'இப்போது ஒத்திசை';

  @override
  String get profileSyncQueue => 'ஒத்திசைவு வரிசை';

  @override
  String get profileApiEndpoint => 'சேவையகம்';

  @override
  String get profileAppVersion => 'செயலி பதிப்பு';

  @override
  String get signOutAction => 'வெளியேறு';

  @override
  String get signOutConfirm => 'இந்தச் சாதனத்திலிருந்து வெளியேற வேண்டுமா?';

  @override
  String get cancelAction => 'ரத்து செய்';

  @override
  String get syncQueueTitle => 'ஒத்திசைவு வரிசை';

  @override
  String get syncQueueEmpty =>
      'ஒத்திசைக்க எதுவும் இல்லை. அனைத்து பதிவுகளும் சேவையகத்தில் உள்ளன.';

  @override
  String syncInProgress(String count) {
    return '$count பதிவுகள் ஒத்திசைக்கப்படுகின்றன...';
  }

  @override
  String syncCompleted(String count) {
    return '$count பதிவுகள் ஒத்திசைக்கப்பட்டன';
  }

  @override
  String syncPartial(String count) {
    return '$count பதிவுகளை ஒத்திசைக்க முடியவில்லை';
  }

  @override
  String get syncNotPossible =>
      'நிலுவைப் பதிவுகளை ஒத்திசைக்க இணையத்துடன் இணைக்கவும்.';

  @override
  String pendingRecordAttendance(String type) {
    return 'வருகைப்பதிவு $type';
  }

  @override
  String pendingRecordActivity(String type) {
    return 'கள செயல்பாடு $type';
  }
}
