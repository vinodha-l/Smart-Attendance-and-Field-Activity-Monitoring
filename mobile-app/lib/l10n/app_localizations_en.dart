// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Smart Field Monitoring';

  @override
  String get appTagline => 'Field Activity Monitoring';

  @override
  String get loginHeader => 'Smart Attendance';

  @override
  String get loginHint =>
      'Sign in with the employee ID issued by your panchayat office.';

  @override
  String get employeeIdLabel => 'Employee ID';

  @override
  String get passwordLabel => 'Password or OTP';

  @override
  String get signInAction => 'Sign in';

  @override
  String get signingInAction => 'Signing in...';

  @override
  String get loginFailed =>
      'Sign in failed. Check your Employee ID and password.';

  @override
  String get loginRequiresConnection =>
      'An internet connection is required for the first sign in.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTamil => 'தமிழ்';

  @override
  String get sessionExpired => 'Your session expired. Please sign in again.';

  @override
  String get mobileOtpTab => 'Mobile OTP';

  @override
  String get employeeLoginTab => 'Employee login';

  @override
  String get mobileOtpHint =>
      'Enter your registered mobile number to receive a one-time password.';

  @override
  String get mobileNumberLabel => 'Mobile number';

  @override
  String get mobileNumberInvalid => 'Enter a valid 10-digit mobile number.';

  @override
  String get sendOtpAction => 'Send OTP';

  @override
  String get sendingOtp => 'Sending OTP...';

  @override
  String get otpSent => 'OTP sent to your mobile number.';

  @override
  String get otpLabel => 'One-time password';

  @override
  String get otpInvalid => 'Enter the OTP sent to your phone.';

  @override
  String get verifyOtpAction => 'Verify and sign in';

  @override
  String get verifyingOtp => 'Verifying OTP...';

  @override
  String get resendOtpAction => 'Resend OTP';

  @override
  String get otpAutofillNote =>
      'Your phone can suggest the OTP automatically when the SMS arrives.';

  @override
  String get viewDemoAction => 'View demo without OTP';

  @override
  String get demoLoginNote =>
      'Demo mode uses local sample data. It does not send an OTP or save to the government server.';

  @override
  String get navToday => 'Today';

  @override
  String get navTasks => 'Tasks';

  @override
  String get navHistory => 'History';

  @override
  String get navProfile => 'Profile';

  @override
  String greetingMorning(String name) {
    return 'Good morning, $name';
  }

  @override
  String greetingAfternoon(String name) {
    return 'Good afternoon, $name';
  }

  @override
  String greetingEvening(String name) {
    return 'Good evening, $name';
  }

  @override
  String get attendancePending => 'Attendance pending for today';

  @override
  String dutyStartsAt(String time) {
    return 'Duty begins at $time';
  }

  @override
  String checkedInAt(String time) {
    return 'Checked in at $time';
  }

  @override
  String checkedOutAt(String time) {
    return 'Checked out at $time';
  }

  @override
  String get locationVerifiedForToday =>
      'Location and photo verified for today';

  @override
  String get markAttendanceAction => 'Mark attendance';

  @override
  String get markCheckOutAction => 'Mark check-out';

  @override
  String get attendanceCompleted => 'Attendance for today is complete';

  @override
  String get todaysSchedule => 'Today\'s schedule';

  @override
  String get reportFieldActivityAction => 'Report field activity';

  @override
  String pendingSyncBanner(String count) {
    return '$count record(s) waiting to sync';
  }

  @override
  String get allRecordsSynced => 'All records synced with the server';

  @override
  String get offlineBanner => 'Offline - records are saved on this device';

  @override
  String get onlineBanner => 'Online';

  @override
  String recordsPendingSync(String count) {
    return '$count pending';
  }

  @override
  String get markAttendanceTitle => 'Mark attendance';

  @override
  String get attendanceTypeCheckIn => 'Check-in';

  @override
  String get attendanceTypeCheckOut => 'Check-out';

  @override
  String get statusGettingGps => 'Getting GPS location';

  @override
  String get statusCapturingPhoto => 'Capturing attendance photo';

  @override
  String get statusVerifying => 'Verifying location and face';

  @override
  String get gpsCoordinates => 'GPS coordinates and accuracy';

  @override
  String gpsReading(String latitude, String longitude, String accuracy) {
    return '$latitude, $longitude  •  accuracy $accuracy m';
  }

  @override
  String get gpsUnavailable => 'GPS location is not available yet';

  @override
  String insideGeofence(String site, String distance) {
    return 'Inside assigned area ($site, $distance m from centre)';
  }

  @override
  String outsideGeofence(String distance) {
    return 'Outside assigned area by $distance m';
  }

  @override
  String get photoCaptured => 'Attendance photo captured';

  @override
  String get photoNotCaptured => 'Attendance photo pending';

  @override
  String get photographAction => 'Take photo';

  @override
  String get selfieQrVerification => 'Selfie / QR verification';

  @override
  String get geofenceVerification => 'Geofence and face verification';

  @override
  String get submitAttendanceAction => 'Submit attendance';

  @override
  String get continueAction => 'Continue';

  @override
  String get attendanceMarkedTitle => 'Attendance marked';

  @override
  String get attendanceMarkedBody =>
      'GPS, time and attendance photo were recorded. You are inside the assigned geofence.';

  @override
  String get attendanceQueuedBody =>
      'GPS, time and attendance photo were saved on this device and will sync when the network is available.';

  @override
  String get photoOnlyModeNote =>
      'Photo evidence is stored on the device. Face verification runs on the server after sync.';

  @override
  String get doneAction => 'Done';

  @override
  String get retryAction => 'Retry';

  @override
  String get closeAction => 'Close';

  @override
  String get loadingLabel => 'Loading...';

  @override
  String get genericError => 'Something went wrong. Please try again.';

  @override
  String get locationPermissionDenied =>
      'Location permission was denied. Enable it in settings to mark attendance.';

  @override
  String get locationServiceDisabled =>
      'Turn on device location (GPS) to mark attendance.';

  @override
  String get cameraPermissionDenied =>
      'Camera permission was denied. Enable it in settings to capture evidence.';

  @override
  String get assignedForToday => 'Assigned for today';

  @override
  String get taskStatusUpcoming => 'Upcoming';

  @override
  String get taskStatusInProgress => 'In progress';

  @override
  String get taskStatusCompleted => 'Completed';

  @override
  String get noTasks => 'No tasks assigned today';

  @override
  String get reportActivityTitle => 'Report field activity';

  @override
  String get activityTypeLabel => 'Activity type';

  @override
  String get activityTypeStreetSanitation => 'Street sanitation';

  @override
  String get activityTypeToiletInspection => 'Public toilet inspection';

  @override
  String get activityTypeDrainageInspection => 'Drainage inspection';

  @override
  String get activityTypeOther => 'Other field work';

  @override
  String get remarksLabel => 'Remarks';

  @override
  String get remarksHint => 'Describe work completed or issues found';

  @override
  String get evidencePhotoAction => 'Capture evidence photo';

  @override
  String evidencePhotoCount(String count) {
    return '$count evidence photo(s) attached';
  }

  @override
  String get saveActivityAction => 'Save activity';

  @override
  String get activitySavedLocally =>
      'Activity saved on this device and queued for sync.';

  @override
  String get activitySavedAndSynced =>
      'Activity saved and synced to the server.';

  @override
  String get activitySaveFailed => 'Could not save the activity. Try again.';

  @override
  String get evidenceRequired => 'Attach at least one evidence photo.';

  @override
  String get attendanceHistory => 'Attendance history';

  @override
  String get statusVerified => 'Verified';

  @override
  String get statusLate => 'Late';

  @override
  String get statusSynced => 'Synced';

  @override
  String get statusPending => 'Pending sync';

  @override
  String get statusFailed => 'Sync failed';

  @override
  String get statusOffline => 'Saved offline';

  @override
  String get noHistory => 'No attendance records yet';

  @override
  String historyIn(String time) {
    return 'In $time';
  }

  @override
  String historyOut(String time) {
    return 'Out $time';
  }

  @override
  String get refreshAction => 'Refresh';

  @override
  String get profileAssignedArea => 'Assigned area';

  @override
  String get profileMobileNumber => 'Mobile number';

  @override
  String profileDesignation(String designation, String employeeId) {
    return '$designation • $employeeId';
  }

  @override
  String profileJoinedOn(String date) {
    return 'Joined on $date';
  }

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileSyncNow => 'Sync now';

  @override
  String get profileSyncQueue => 'Sync queue';

  @override
  String get profileApiEndpoint => 'Server';

  @override
  String get profileAppVersion => 'App version';

  @override
  String get signOutAction => 'Sign out';

  @override
  String get signOutConfirm => 'Do you want to sign out of this device?';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get syncQueueTitle => 'Pending sync queue';

  @override
  String get syncQueueEmpty =>
      'Nothing to sync. All records are on the server.';

  @override
  String syncInProgress(String count) {
    return 'Syncing $count record(s)...';
  }

  @override
  String syncCompleted(String count) {
    return '$count record(s) synced';
  }

  @override
  String syncPartial(String count) {
    return '$count record(s) could not be synced';
  }

  @override
  String get syncNotPossible =>
      'Connect to the internet to sync pending records.';

  @override
  String pendingRecordAttendance(String type) {
    return 'Attendance $type';
  }

  @override
  String pendingRecordActivity(String type) {
    return 'Field activity $type';
  }
}
