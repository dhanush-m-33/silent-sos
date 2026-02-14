/// All user-facing strings defined centrally.
/// Makes future localization easy — just swap this file.
class AppStrings {
  AppStrings._();

  // ─── APP ──────────────────────────────────────────────────
  static const String appName = 'Silent SOS';
  static const String appTagline = 'Your silent guardian';

  // ─── AUTH ─────────────────────────────────────────────────
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String phoneNumber = 'Phone Number';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already have an account? Login';
  static const String dontHaveAccount = "Don't have an account? Sign Up";
  static const String loginSuccess = 'Welcome back!';
  static const String signupSuccess = 'Account created successfully!';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String emailAlreadyExists = 'Email already registered.';
  static const String passwordMismatch = 'Passwords do not match.';

  // ─── VALIDATION ───────────────────────────────────────────
  static const String fieldRequired = 'This field is required';
  static const String invalidEmail = 'Enter a valid email address';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String invalidPhone = 'Enter a valid phone number';

  // ─── HOME / SOS ───────────────────────────────────────────
  static const String sosButton = 'SOS';
  static const String sosActivated = 'SOS Activated!';
  static const String sosTriggered = 'SOS Triggered';
  static const String cancelSos = 'CANCEL';
  static const String cancelCountdown = 'Tap to cancel';
  static const String sendingAlert = 'Sending alert...';
  static const String alertSent = 'Alert sent to emergency contacts!';
  static const String noContactsWarning =
      'No emergency contacts added. Add contacts first.';
  static const String sosDescription =
      'Press the SOS button, shake your device 3 times,\nor say "Help Help" to trigger an alert.';

  // ─── EVIDENCE ─────────────────────────────────────────────
  static const String evidence = 'Evidence';
  static const String noEvidence = 'No recordings yet';
  static const String noEvidenceSubtitle = 'SOS recordings will appear here';
  static const String deleteEvidence = 'Delete Recording';
  static const String deleteEvidenceConfirm =
      'This will permanently delete the recording and file. Continue?';
  static const String audio = 'Audio';
  static const String video = 'Video';

  // ─── CONTACTS ─────────────────────────────────────────────
  static const String emergencyContacts = 'Emergency Contacts';
  static const String addContact = 'Add Contact';
  static const String editContact = 'Edit Contact';
  static const String deleteContact = 'Delete Contact';
  static const String deleteContactConfirm =
      'Remove this contact from emergency list?';
  static const String contactName = 'Contact Name';
  static const String contactPhone = 'Phone Number';
  static const String noContacts = 'No emergency contacts';
  static const String noContactsSubtitle =
      'Add contacts who will receive SOS alerts';
  static const String phoneAlreadyExists = 'This number is already saved.';
  static const String save = 'Save';
  static const String cancel = 'Cancel';

  // ─── PROFILE ──────────────────────────────────────────────
  static const String profile = 'Profile';
  static const String myProfile = 'My Profile';
  static const String logoutConfirm = 'Are you sure you want to logout?';
  static const String logoutTitle = 'Logout';

  // ─── NAV ──────────────────────────────────────────────────
  static const String navHome = 'Home';
  static const String navEvidence = 'Evidence';
  static const String navContacts = 'Contacts';
  static const String navProfile = 'Profile';

  // ─── SMS TEMPLATE ─────────────────────────────────────────
  static String sosMessage(String name, String coords, String time) =>
      '🆘 SILENT SOS ALERT\n'
      '$name needs help!\n'
      'Location: https://maps.google.com/?q=$coords\n'
      'Time: $time\n'
      '— Sent automatically by Silent SOS app';

  // ─── ERRORS ───────────────────────────────────────────────
  static const String genericError = 'Something went wrong. Try again.';
  static const String locationError = 'Could not get location.';
  static const String recordingError = 'Could not start recording.';
  static const String smsError = 'Could not send SMS.';
  static const String permissionDenied =
      'Required permissions denied. Please enable in Settings.';
}
