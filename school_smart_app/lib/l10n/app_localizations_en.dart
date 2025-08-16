// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SchoolSmart';

  @override
  String get studentsManagement => 'Students Management';

  @override
  String get attendanceManagement => 'Attendance Management';

  @override
  String get gradesManagement => 'Grades Management';

  @override
  String get addNewStudent => 'Add New Student';

  @override
  String get addNewGrade => 'Add New Grade';

  @override
  String get searchStudents => 'Search students by name or email...';

  @override
  String get searchGrades => 'Search grades...';

  @override
  String get grade => 'Grade';

  @override
  String get allGrades => 'All Grades';

  @override
  String get name => 'Name';

  @override
  String get email => 'Email';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get parentName => 'Parent Name';

  @override
  String get parentPhone => 'Parent Phone';

  @override
  String get parentEmail => 'Parent Email';

  @override
  String get studentCode => 'Student Code';

  @override
  String get status => 'Status';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get created => 'Created';

  @override
  String get createdAt => 'Created';

  @override
  String get updated => 'Updated';

  @override
  String get actions => 'Actions';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading => 'Loading...';

  @override
  String get loadingStudents => 'Loading students...';

  @override
  String get loadingGrades => 'Loading grades...';

  @override
  String get noStudentsFound => 'No students found';

  @override
  String get noGradesFound => 'No grades found';

  @override
  String get tryAdjustingSearch => 'Try adjusting your search or filters';

  @override
  String get addFirstStudent => 'Add First Student';

  @override
  String get addFirstGrade => 'Add First Grade';

  @override
  String get studentsFound => 'students found';

  @override
  String get gradesFound => 'grades found';

  @override
  String get refresh => 'Refresh';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Error';

  @override
  String get errorLoadingStudents => 'Error loading students';

  @override
  String get errorLoadingGrades => 'Error loading grades';

  @override
  String get failedToLoadGrades => 'Failed to load grades';

  @override
  String get studentAddedSuccessfully => 'Student added successfully!';

  @override
  String get studentUpdatedSuccessfully => 'Student updated successfully!';

  @override
  String get studentDeletedSuccessfully => 'Student deleted successfully!';

  @override
  String get gradeAddedSuccessfully => 'Grade added successfully!';

  @override
  String get gradeUpdatedSuccessfully => 'Grade updated successfully!';

  @override
  String get gradeDeletedSuccessfully => 'Grade deleted successfully!';

  @override
  String get areYouSureDeleteStudent =>
      'Are you sure you want to delete this student?';

  @override
  String get areYouSureDeleteGrade =>
      'Are you sure you want to delete this grade?';

  @override
  String get thisActionCannotBeUndone => 'This action cannot be undone.';

  @override
  String get attendance => 'Attendance';

  @override
  String get present => 'Present';

  @override
  String get absent => 'Absent';

  @override
  String get late => 'Late';

  @override
  String get attendanceSummary => 'Attendance Summary';

  @override
  String get totalStudents => 'Total Students';

  @override
  String get presentCount => 'Present';

  @override
  String get absentCount => 'Absent';

  @override
  String get lateCount => 'Late';

  @override
  String get attendanceRate => 'Attendance Rate';

  @override
  String get selectDate => 'Select Date';

  @override
  String get markAllPresent => 'Mark All Present';

  @override
  String get markAllAbsent => 'Mark All Absent';

  @override
  String get saveAttendance => 'Save Attendance';

  @override
  String get attendanceSavedSuccessfully => 'Attendance saved successfully!';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signIn => 'Sign In';

  @override
  String get logout => 'Logout';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get contact => 'Contact';

  @override
  String get help => 'Help';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get viewDetails => 'View Details';

  @override
  String get viewAttendance => 'View Attendance';

  @override
  String get studentDetails => 'Student Details';

  @override
  String get close => 'Close';

  @override
  String get editFunctionalityComingSoon => 'Edit functionality coming soon!';

  @override
  String get attendanceViewComingSoon => 'Attendance view coming soon!';

  @override
  String get deleteStudent => 'Delete Student';

  @override
  String areYouSureYouWantToDeleteStudent(String studentName) {
    return 'Are you sure you want to delete $studentName? This action cannot be undone.';
  }

  @override
  String errorDeletingStudent(String error) {
    return 'Error deleting student: $error';
  }
}
