import 'shake_service.dart'; // ✅ proper import
import 'voice_trigger_service.dart'; // ✅ proper import
import 'location_service.dart'; // ✅ proper import
import 'recording_service.dart'; // ✅ proper import
import 'sms_service.dart'; // ✅ proper import
import '../../data/models/evidence_model.dart';
import '../../data/repositories/evidence_repository.dart'; // ✅ proper import
import '../../data/repositories/contact_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'package:uuid/uuid.dart';

/// Master orchestrator for the SOS system.
/// Initializes all triggers (button, shake, voice) and
/// coordinates the full alert sequence when triggered.
class SOSService {
  // ✅ Fixed: instantiated as fields, not called as methods
  final ShakeService _shakeService = ShakeService();
  final VoiceTriggerService _voiceService = VoiceTriggerService();
  final EvidenceRepository _evidenceRepo = EvidenceRepository();
  final ContactRepository _contactRepo = ContactRepository();
  final UserRepository _userRepo = UserRepository();

  bool _isCancelled = false;
  bool _isActive = false;

  /// Call once from HomeScreen.initState() to start all background listeners.
  void initialize({required Function onSOSTriggered}) {
    _shakeService.onTripleShake = () => _trigger(onSOSTriggered);
    _voiceService.onHelpDetected = () => _trigger(onSOSTriggered);
    _shakeService.start();
    _voiceService.start();
  }

  void _trigger(Function onSOSTriggered) {
    // Prevent multiple simultaneous triggers
    if (_isActive) return;
    _isActive = true;
    _isCancelled = false;
    onSOSTriggered();
  }

  /// Called after the 10s cancel window expires without cancellation.
  Future<void> executeAfterDelay() async {
    await Future.delayed(const Duration(seconds: 10));
    if (_isCancelled) {
      _isActive = false;
      return;
    }

    try {
      // 1. Get GPS location
      final coords = await LocationService.getCoordinates();

      // 2. Record audio + video concurrently
      final recordings = await RecordingService.recordBoth();

      // 3. Save evidence to Hive
      final timestamp = DateTime.now();
      const uuid = Uuid();

      if (recordings['audioPath'] != null) {
        await _evidenceRepo.saveEvidence(EvidenceModel(
          id: uuid.v4(),
          filePath: recordings['audioPath']!,
          type: EvidenceType.audio,
          timestamp: timestamp,
          location: coords,
          durationSeconds: 10,
        ));
      }

      if (recordings['videoPath'] != null) {
        await _evidenceRepo.saveEvidence(EvidenceModel(
          id: uuid.v4(),
          filePath: recordings['videoPath']!,
          type: EvidenceType.video,
          timestamp: timestamp,
          location: coords,
          durationSeconds: 10,
        ));
      }

      // 4. Send SMS to all emergency contacts
      final user = _userRepo.getUser();
      final smsService = SmsService(_contactRepo);
      await smsService.sendAlert(
        userName: user?.name ?? 'Someone',
        coords: coords,
      );
    } finally {
      _isActive = false;
    }
  }

  /// Call this when user taps CANCEL during the 10s window.
  void cancel() {
    _isCancelled = true;
    _isActive = false;
  }

  void dispose() {
    _shakeService.stop();
    _voiceService.stop();
  }
}
