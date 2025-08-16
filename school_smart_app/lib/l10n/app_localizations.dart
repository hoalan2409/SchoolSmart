import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SchoolSmart'**
  String get appTitle;

  /// No description provided for @studentsManagement.
  ///
  /// In en, this message translates to:
  /// **'Students Management'**
  String get studentsManagement;

  /// No description provided for @attendanceManagement.
  ///
  /// In en, this message translates to:
  /// **'Attendance Management'**
  String get attendanceManagement;

  /// No description provided for @gradesManagement.
  ///
  /// In en, this message translates to:
  /// **'Grades Management'**
  String get gradesManagement;

  /// No description provided for @addNewStudent.
  ///
  /// In en, this message translates to:
  /// **'Add New Student'**
  String get addNewStudent;

  /// No description provided for @addNewGrade.
  ///
  /// In en, this message translates to:
  /// **'Add New Grade'**
  String get addNewGrade;

  /// No description provided for @searchStudents.
  ///
  /// In en, this message translates to:
  /// **'Search students by name or email...'**
  String get searchStudents;

  /// No description provided for @searchGrades.
  ///
  /// In en, this message translates to:
  /// **'Search grades...'**
  String get searchGrades;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get grade;

  /// No description provided for @allGrades.
  ///
  /// In en, this message translates to:
  /// **'All Grades'**
  String get allGrades;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @parentName.
  ///
  /// In en, this message translates to:
  /// **'Parent Name'**
  String get parentName;

  /// No description provided for @parentPhone.
  ///
  /// In en, this message translates to:
  /// **'Parent Phone'**
  String get parentPhone;

  /// No description provided for @parentEmail.
  ///
  /// In en, this message translates to:
  /// **'Parent Email'**
  String get parentEmail;

  /// No description provided for @studentCode.
  ///
  /// In en, this message translates to:
  /// **'Student Code'**
  String get studentCode;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdAt;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadingStudents.
  ///
  /// In en, this message translates to:
  /// **'Loading students...'**
  String get loadingStudents;

  /// No description provided for @loadingGrades.
  ///
  /// In en, this message translates to:
  /// **'Loading grades...'**
  String get loadingGrades;

  /// No description provided for @noStudentsFound.
  ///
  /// In en, this message translates to:
  /// **'No students found'**
  String get noStudentsFound;

  /// No description provided for @noGradesFound.
  ///
  /// In en, this message translates to:
  /// **'No grades found'**
  String get noGradesFound;

  /// No description provided for @tryAdjustingSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjustingSearch;

  /// No description provided for @addFirstStudent.
  ///
  /// In en, this message translates to:
  /// **'Add First Student'**
  String get addFirstStudent;

  /// No description provided for @addFirstGrade.
  ///
  /// In en, this message translates to:
  /// **'Add First Grade'**
  String get addFirstGrade;

  /// No description provided for @studentsFound.
  ///
  /// In en, this message translates to:
  /// **'students found'**
  String get studentsFound;

  /// No description provided for @gradesFound.
  ///
  /// In en, this message translates to:
  /// **'grades found'**
  String get gradesFound;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorLoadingStudents.
  ///
  /// In en, this message translates to:
  /// **'Error loading students'**
  String get errorLoadingStudents;

  /// No description provided for @errorLoadingGrades.
  ///
  /// In en, this message translates to:
  /// **'Error loading grades'**
  String get errorLoadingGrades;

  /// No description provided for @failedToLoadGrades.
  ///
  /// In en, this message translates to:
  /// **'Failed to load grades'**
  String get failedToLoadGrades;

  /// No description provided for @studentAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Student added successfully!'**
  String get studentAddedSuccessfully;

  /// No description provided for @studentUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Student updated successfully!'**
  String get studentUpdatedSuccessfully;

  /// No description provided for @studentDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Student deleted successfully!'**
  String get studentDeletedSuccessfully;

  /// No description provided for @gradeAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Grade added successfully!'**
  String get gradeAddedSuccessfully;

  /// No description provided for @gradeUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Grade updated successfully!'**
  String get gradeUpdatedSuccessfully;

  /// No description provided for @gradeDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Grade deleted successfully!'**
  String get gradeDeletedSuccessfully;

  /// No description provided for @areYouSureDeleteStudent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this student?'**
  String get areYouSureDeleteStudent;

  /// No description provided for @areYouSureDeleteGrade.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this grade?'**
  String get areYouSureDeleteGrade;

  /// No description provided for @thisActionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get thisActionCannotBeUndone;

  /// No description provided for @attendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendance;

  /// No description provided for @present.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get present;

  /// No description provided for @absent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absent;

  /// No description provided for @late.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// No description provided for @attendanceSummary.
  ///
  /// In en, this message translates to:
  /// **'Attendance Summary'**
  String get attendanceSummary;

  /// No description provided for @totalStudents.
  ///
  /// In en, this message translates to:
  /// **'Total Students'**
  String get totalStudents;

  /// No description provided for @presentCount.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get presentCount;

  /// No description provided for @absentCount.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get absentCount;

  /// No description provided for @lateCount.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get lateCount;

  /// No description provided for @attendanceRate.
  ///
  /// In en, this message translates to:
  /// **'Attendance Rate'**
  String get attendanceRate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @markAllPresent.
  ///
  /// In en, this message translates to:
  /// **'Mark All Present'**
  String get markAllPresent;

  /// No description provided for @markAllAbsent.
  ///
  /// In en, this message translates to:
  /// **'Mark All Absent'**
  String get markAllAbsent;

  /// No description provided for @saveAttendance.
  ///
  /// In en, this message translates to:
  /// **'Save Attendance'**
  String get saveAttendance;

  /// No description provided for @attendanceSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Attendance saved successfully!'**
  String get attendanceSavedSuccessfully;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @viewAttendance.
  ///
  /// In en, this message translates to:
  /// **'View Attendance'**
  String get viewAttendance;

  /// No description provided for @studentDetails.
  ///
  /// In en, this message translates to:
  /// **'Student Details'**
  String get studentDetails;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @editFunctionalityComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Edit functionality coming soon!'**
  String get editFunctionalityComingSoon;

  /// No description provided for @attendanceViewComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Attendance view coming soon!'**
  String get attendanceViewComingSoon;

  /// No description provided for @deleteStudent.
  ///
  /// In en, this message translates to:
  /// **'Delete Student'**
  String get deleteStudent;

  /// No description provided for @areYouSureYouWantToDeleteStudent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {studentName}? This action cannot be undone.'**
  String areYouSureYouWantToDeleteStudent(String studentName);

  /// No description provided for @errorDeletingStudent.
  ///
  /// In en, this message translates to:
  /// **'Error deleting student: {error}'**
  String errorDeletingStudent(String error);
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
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
