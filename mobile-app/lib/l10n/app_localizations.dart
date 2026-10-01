import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ta')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Field Monitoring'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Field Activity Monitoring'**
  String get appTagline;

  /// No description provided for @loginHeader.
  ///
  /// In en, this message translates to:
  /// **'Smart Attendance'**
  String get loginHeader;

  /// No description provided for @loginHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in with the employee ID issued by your panchayat office.'**
  String get loginHint;

  /// No description provided for @employeeIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Employee ID'**
  String get employeeIdLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password or OTP'**
  String get passwordLabel;

  /// No description provided for @signInAction.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signInAction;

  /// No description provided for @signingInAction.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingInAction;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Check your Employee ID and password.'**
  String get loginFailed;

  /// No description provided for @loginRequiresConnection.
  ///
  /// In en, this message translates to:
  /// **'An internet connection is required for the first sign in.'**
  String get loginRequiresConnection;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageTamil.
  ///
  /// In en, this message translates to:
  /// **'தமிழ்'**
  String get languageTamil;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Please sign in again.'**
  String get sessionExpired;

  /// No description provided for @mobileOtpTab.
  ///
  /// In en, this message translates to:
  /// **'Mobile OTP'**
  String get mobileOtpTab;

  /// No description provided for @employeeLoginTab.
  ///
  /// In en, this message translates to:
  /// **'Employee login'**
  String get employeeLoginTab;

  /// No description provided for @mobileOtpHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered mobile number to receive a one-time password.'**
  String get mobileOtpHint;

  /// No description provided for @mobileNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get mobileNumberLabel;

  /// No description provided for @mobileNumberInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number.'**
  String get mobileNumberInvalid;

  /// No description provided for @sendOtpAction.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtpAction;

  /// No description provided for @sendingOtp.
  ///
  /// In en, this message translates to:
  /// **'Sending OTP...'**
  String get sendingOtp;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP sent to your mobile number.'**
  String get otpSent;

  /// No description provided for @otpLabel.
  ///
  /// In en, this message translates to:
  /// **'One-time password'**
  String get otpLabel;

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to your phone.'**
  String get otpInvalid;

  /// No description provided for @verifyOtpAction.
  ///
  /// In en, this message translates to:
  /// **'Verify and sign in'**
  String get verifyOtpAction;

  /// No description provided for @verifyingOtp.
  ///
  /// In en, this message translates to:
  /// **'Verifying OTP...'**
  String get verifyingOtp;

  /// No description provided for @resendOtpAction.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get resendOtpAction;

  /// No description provided for @otpAutofillNote.
  ///
  /// In en, this message translates to:
  /// **'Your phone can suggest the OTP automatically when the SMS arrives.'**
  String get otpAutofillNote;

  /// No description provided for @viewDemoAction.
  ///
  /// In en, this message translates to:
  /// **'View demo without OTP'**
  String get viewDemoAction;

  /// No description provided for @demoLoginNote.
  ///
  /// In en, this message translates to:
  /// **'Demo mode uses local sample data. It does not send an OTP or save to the government server.'**
  String get demoLoginNote;

  /// No description provided for @navToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get navToday;

  /// No description provided for @navTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get navTasks;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning, {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon, {name}'**
  String greetingAfternoon(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening, {name}'**
  String greetingEvening(String name);

  /// No description provided for @attendancePending.
  ///
  /// In en, this message translates to:
  /// **'Attendance pending for today'**
  String get attendancePending;

  /// No description provided for @dutyStartsAt.
  ///
  /// In en, this message translates to:
  /// **'Duty begins at {time}'**
  String dutyStartsAt(String time);

  /// No description provided for @checkedInAt.
  ///
  /// In en, this message translates to:
  /// **'Checked in at {time}'**
  String checkedInAt(String time);

  /// No description provided for @checkedOutAt.
  ///
  /// In en, this message translates to:
  /// **'Checked out at {time}'**
  String checkedOutAt(String time);

  /// No description provided for @locationVerifiedForToday.
  ///
  /// In en, this message translates to:
  /// **'Location and photo verified for today'**
  String get locationVerifiedForToday;

  /// No description provided for @markAttendanceAction.
  ///
  /// In en, this message translates to:
  /// **'Mark attendance'**
  String get markAttendanceAction;

  /// No description provided for @markCheckOutAction.
  ///
  /// In en, this message translates to:
  /// **'Mark check-out'**
  String get markCheckOutAction;

  /// No description provided for @attendanceCompleted.
  ///
  /// In en, this message translates to:
  /// **'Attendance for today is complete'**
  String get attendanceCompleted;

  /// No description provided for @todaysSchedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s schedule'**
  String get todaysSchedule;

  /// No description provided for @reportFieldActivityAction.
  ///
  /// In en, this message translates to:
  /// **'Report field activity'**
  String get reportFieldActivityAction;

  /// No description provided for @pendingSyncBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} record(s) waiting to sync'**
  String pendingSyncBanner(String count);

  /// No description provided for @allRecordsSynced.
  ///
  /// In en, this message translates to:
  /// **'All records synced with the server'**
  String get allRecordsSynced;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline - records are saved on this device'**
  String get offlineBanner;

  /// No description provided for @onlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineBanner;

  /// No description provided for @recordsPendingSync.
  ///
  /// In en, this message translates to:
  /// **'{count} pending'**
  String recordsPendingSync(String count);

  /// No description provided for @markAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark attendance'**
  String get markAttendanceTitle;

  /// No description provided for @attendanceTypeCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get attendanceTypeCheckIn;

  /// No description provided for @attendanceTypeCheckOut.
  ///
  /// In en, this message translates to:
  /// **'Check-out'**
  String get attendanceTypeCheckOut;

  /// No description provided for @statusGettingGps.
  ///
  /// In en, this message translates to:
  /// **'Getting GPS location'**
  String get statusGettingGps;

  /// No description provided for @statusCapturingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Capturing attendance photo'**
  String get statusCapturingPhoto;

  /// No description provided for @statusVerifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying location and face'**
  String get statusVerifying;

  /// No description provided for @gpsCoordinates.
  ///
  /// In en, this message translates to:
  /// **'GPS coordinates and accuracy'**
  String get gpsCoordinates;

  /// No description provided for @gpsReading.
  ///
  /// In en, this message translates to:
  /// **'{latitude}, {longitude}  •  accuracy {accuracy} m'**
  String gpsReading(String latitude, String longitude, String accuracy);

  /// No description provided for @gpsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'GPS location is not available yet'**
  String get gpsUnavailable;

  /// No description provided for @insideGeofence.
  ///
  /// In en, this message translates to:
  /// **'Inside assigned area ({site}, {distance} m from centre)'**
  String insideGeofence(String site, String distance);

  /// No description provided for @outsideGeofence.
  ///
  /// In en, this message translates to:
  /// **'Outside assigned area by {distance} m'**
  String outsideGeofence(String distance);

  /// No description provided for @photoCaptured.
  ///
  /// In en, this message translates to:
  /// **'Attendance photo captured'**
  String get photoCaptured;

  /// No description provided for @photoNotCaptured.
  ///
  /// In en, this message translates to:
  /// **'Attendance photo pending'**
  String get photoNotCaptured;

  /// No description provided for @photographAction.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get photographAction;

  /// No description provided for @selfieQrVerification.
  ///
  /// In en, this message translates to:
  /// **'Selfie / QR verification'**
  String get selfieQrVerification;

  /// No description provided for @geofenceVerification.
  ///
  /// In en, this message translates to:
  /// **'Geofence and face verification'**
  String get geofenceVerification;

  /// No description provided for @submitAttendanceAction.
  ///
  /// In en, this message translates to:
  /// **'Submit attendance'**
  String get submitAttendanceAction;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @attendanceMarkedTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance marked'**
  String get attendanceMarkedTitle;

  /// No description provided for @attendanceMarkedBody.
  ///
  /// In en, this message translates to:
  /// **'GPS, time and attendance photo were recorded. You are inside the assigned geofence.'**
  String get attendanceMarkedBody;

  /// No description provided for @attendanceQueuedBody.
  ///
  /// In en, this message translates to:
  /// **'GPS, time and attendance photo were saved on this device and will sync when the network is available.'**
  String get attendanceQueuedBody;

  /// No description provided for @photoOnlyModeNote.
  ///
  /// In en, this message translates to:
  /// **'Photo evidence is stored on the device. Face verification runs on the server after sync.'**
  String get photoOnlyModeNote;

  /// No description provided for @faceVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Face verification'**
  String get faceVerificationTitle;

  /// No description provided for @faceVerificationReady.
  ///
  /// In en, this message translates to:
  /// **'Take a selfie, then verify your face.'**
  String get faceVerificationReady;

  /// No description provided for @faceVerificationCaptureFirst.
  ///
  /// In en, this message translates to:
  /// **'Capture a selfie before face verification.'**
  String get faceVerificationCaptureFirst;

  /// No description provided for @verifyFaceAction.
  ///
  /// In en, this message translates to:
  /// **'Verify face'**
  String get verifyFaceAction;

  /// No description provided for @faceVerificationLoading.
  ///
  /// In en, this message translates to:
  /// **'Verifying your selfie...'**
  String get faceVerificationLoading;

  /// No description provided for @faceVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Face verified successfully.'**
  String get faceVerifiedSuccess;

  /// No description provided for @faceRejected.
  ///
  /// In en, this message translates to:
  /// **'Face does not match the registered worker. Please try again.'**
  String get faceRejected;

  /// No description provided for @faceNoFace.
  ///
  /// In en, this message translates to:
  /// **'No face was found. Capture the selfie again.'**
  String get faceNoFace;

  /// No description provided for @faceMultipleFaces.
  ///
  /// In en, this message translates to:
  /// **'Only one person should be visible. Capture the selfie again.'**
  String get faceMultipleFaces;

  /// No description provided for @faceWorkerNotRegistered.
  ///
  /// In en, this message translates to:
  /// **'This worker is not registered for face verification.'**
  String get faceWorkerNotRegistered;

  /// No description provided for @faceInvalidImage.
  ///
  /// In en, this message translates to:
  /// **'Capture a valid selfie and try again.'**
  String get faceInvalidImage;

  /// No description provided for @faceProcessingError.
  ///
  /// In en, this message translates to:
  /// **'Face verification is temporarily unavailable. Please retry.'**
  String get faceProcessingError;

  /// No description provided for @faceNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Could not reach face verification. Check your connection and retry.'**
  String get faceNetworkError;

  /// No description provided for @faceApiError.
  ///
  /// In en, this message translates to:
  /// **'Face verification could not be completed. Please retry.'**
  String get faceApiError;

  /// No description provided for @faceSimilarity.
  ///
  /// In en, this message translates to:
  /// **'Similarity: {value}'**
  String faceSimilarity(String value);

  /// No description provided for @doneAction.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneAction;

  /// No description provided for @retryAction.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryAction;

  /// No description provided for @closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingLabel;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get genericError;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission was denied. Enable it in settings to mark attendance.'**
  String get locationPermissionDenied;

  /// No description provided for @locationServiceDisabled.
  ///
  /// In en, this message translates to:
  /// **'Turn on device location (GPS) to mark attendance.'**
  String get locationServiceDisabled;

  /// No description provided for @cameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission was denied. Enable it in settings to capture evidence.'**
  String get cameraPermissionDenied;

  /// No description provided for @assignedForToday.
  ///
  /// In en, this message translates to:
  /// **'Assigned for today'**
  String get assignedForToday;

  /// No description provided for @taskStatusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get taskStatusUpcoming;

  /// No description provided for @taskStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get taskStatusInProgress;

  /// No description provided for @taskStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskStatusCompleted;

  /// No description provided for @noTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks assigned today'**
  String get noTasks;

  /// No description provided for @reportActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Report field activity'**
  String get reportActivityTitle;

  /// No description provided for @activityTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Activity type'**
  String get activityTypeLabel;

  /// No description provided for @activityTypeStreetSanitation.
  ///
  /// In en, this message translates to:
  /// **'Street sanitation'**
  String get activityTypeStreetSanitation;

  /// No description provided for @activityTypeToiletInspection.
  ///
  /// In en, this message translates to:
  /// **'Public toilet inspection'**
  String get activityTypeToiletInspection;

  /// No description provided for @activityTypeDrainageInspection.
  ///
  /// In en, this message translates to:
  /// **'Drainage inspection'**
  String get activityTypeDrainageInspection;

  /// No description provided for @activityTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other field work'**
  String get activityTypeOther;

  /// No description provided for @remarksLabel.
  ///
  /// In en, this message translates to:
  /// **'Remarks'**
  String get remarksLabel;

  /// No description provided for @remarksHint.
  ///
  /// In en, this message translates to:
  /// **'Describe work completed or issues found'**
  String get remarksHint;

  /// No description provided for @evidencePhotoAction.
  ///
  /// In en, this message translates to:
  /// **'Capture evidence photo'**
  String get evidencePhotoAction;

  /// No description provided for @evidencePhotoCount.
  ///
  /// In en, this message translates to:
  /// **'{count} evidence photo(s) attached'**
  String evidencePhotoCount(String count);

  /// No description provided for @saveActivityAction.
  ///
  /// In en, this message translates to:
  /// **'Save activity'**
  String get saveActivityAction;

  /// No description provided for @activitySavedLocally.
  ///
  /// In en, this message translates to:
  /// **'Activity saved on this device and queued for sync.'**
  String get activitySavedLocally;

  /// No description provided for @activitySavedAndSynced.
  ///
  /// In en, this message translates to:
  /// **'Activity saved and synced to the server.'**
  String get activitySavedAndSynced;

  /// No description provided for @activitySaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the activity. Try again.'**
  String get activitySaveFailed;

  /// No description provided for @evidenceRequired.
  ///
  /// In en, this message translates to:
  /// **'Attach at least one evidence photo.'**
  String get evidenceRequired;

  /// No description provided for @attendanceHistory.
  ///
  /// In en, this message translates to:
  /// **'Attendance history'**
  String get attendanceHistory;

  /// No description provided for @statusVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get statusVerified;

  /// No description provided for @statusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get statusLate;

  /// No description provided for @statusSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get statusSynced;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending sync'**
  String get statusPending;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get statusFailed;

  /// No description provided for @statusOffline.
  ///
  /// In en, this message translates to:
  /// **'Saved offline'**
  String get statusOffline;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No attendance records yet'**
  String get noHistory;

  /// No description provided for @historyIn.
  ///
  /// In en, this message translates to:
  /// **'In {time}'**
  String historyIn(String time);

  /// No description provided for @historyOut.
  ///
  /// In en, this message translates to:
  /// **'Out {time}'**
  String historyOut(String time);

  /// No description provided for @refreshAction.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refreshAction;

  /// No description provided for @profileAssignedArea.
  ///
  /// In en, this message translates to:
  /// **'Assigned area'**
  String get profileAssignedArea;

  /// No description provided for @profileMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile number'**
  String get profileMobileNumber;

  /// No description provided for @profileDesignation.
  ///
  /// In en, this message translates to:
  /// **'{designation} • {employeeId}'**
  String profileDesignation(String designation, String employeeId);

  /// No description provided for @profileJoinedOn.
  ///
  /// In en, this message translates to:
  /// **'Joined on {date}'**
  String profileJoinedOn(String date);

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get profileSyncNow;

  /// No description provided for @profileSyncQueue.
  ///
  /// In en, this message translates to:
  /// **'Sync queue'**
  String get profileSyncQueue;

  /// No description provided for @profileApiEndpoint.
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get profileApiEndpoint;

  /// No description provided for @profileAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get profileAppVersion;

  /// No description provided for @signOutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutAction;

  /// No description provided for @signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to sign out of this device?'**
  String get signOutConfirm;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @syncQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending sync queue'**
  String get syncQueueTitle;

  /// No description provided for @syncQueueEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to sync. All records are on the server.'**
  String get syncQueueEmpty;

  /// No description provided for @syncInProgress.
  ///
  /// In en, this message translates to:
  /// **'Syncing {count} record(s)...'**
  String syncInProgress(String count);

  /// No description provided for @syncCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count} record(s) synced'**
  String syncCompleted(String count);

  /// No description provided for @syncPartial.
  ///
  /// In en, this message translates to:
  /// **'{count} record(s) could not be synced'**
  String syncPartial(String count);

  /// No description provided for @syncNotPossible.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to sync pending records.'**
  String get syncNotPossible;

  /// No description provided for @pendingRecordAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance {type}'**
  String pendingRecordAttendance(String type);

  /// No description provided for @pendingRecordActivity.
  ///
  /// In en, this message translates to:
  /// **'Field activity {type}'**
  String pendingRecordActivity(String type);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
