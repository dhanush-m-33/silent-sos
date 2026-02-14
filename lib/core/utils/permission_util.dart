import 'package:permission_handler/permission_handler.dart';

/// Handles all runtime permission requests for Silent SOS.
/// Call [requestAllPermissions] once at app startup.
class PermissionUtil {
  // ─── ALL PERMISSIONS ───────────────────────────────────────

  /// Requests all permissions the app needs.
  /// Returns true only if ALL critical permissions are granted.
  static Future<bool> requestAllPermissions() async {
    final results = await [
      Permission.camera,
      Permission.microphone,
      Permission.locationWhenInUse,
      Permission.sms,
      Permission.storage,
      Permission.speech, // for voice trigger
    ].request();

    // Check critical permissions (app cannot function without these)
    final critical = [
      Permission.camera,
      Permission.microphone,
      Permission.locationWhenInUse,
      Permission.sms,
    ];

    for (final permission in critical) {
      if (results[permission] != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  // ─── INDIVIDUAL CHECKS ────────────────────────────────────

  static Future<bool> hasCameraPermission() async =>
      await Permission.camera.isGranted;

  static Future<bool> hasMicrophonePermission() async =>
      await Permission.microphone.isGranted;

  static Future<bool> hasLocationPermission() async =>
      await Permission.locationWhenInUse.isGranted;

  static Future<bool> hasSmsPermission() async =>
      await Permission.sms.isGranted;

  static Future<bool> hasSpeechPermission() async =>
      await Permission.speech.isGranted;

  // ─── INDIVIDUAL REQUESTS ──────────────────────────────────

  static Future<bool> requestCamera() async =>
      await Permission.camera.request() == PermissionStatus.granted;

  static Future<bool> requestMicrophone() async =>
      await Permission.microphone.request() == PermissionStatus.granted;

  static Future<bool> requestLocation() async =>
      await Permission.locationWhenInUse.request() == PermissionStatus.granted;

  static Future<bool> requestSms() async =>
      await Permission.sms.request() == PermissionStatus.granted;

  static Future<bool> requestSpeech() async =>
      await Permission.speech.request() == PermissionStatus.granted;

  // ─── OPEN SETTINGS ────────────────────────────────────────

  /// Opens device app settings if user permanently denied a permission.
  static Future<void> openSettings() async {
    await openAppSettings();
  }

  /// Checks if a permission is permanently denied (user clicked "Don't ask again").
  static Future<bool> isPermanentlyDenied(Permission permission) async =>
      await permission.isPermanentlyDenied;

  // ─── STATUS CHECK ALL ─────────────────────────────────────

  /// Returns a map of all permission statuses for diagnostic use.
  static Future<Map<String, bool>> getAllPermissionStatuses() async {
    return {
      'camera': await hasCameraPermission(),
      'microphone': await hasMicrophonePermission(),
      'location': await hasLocationPermission(),
      'sms': await hasSmsPermission(),
      'speech': await hasSpeechPermission(),
    };
  }
}
