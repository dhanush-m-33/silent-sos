import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

/// Detects 3 shakes within a 3-second window and fires [onTripleShake].
class ShakeService {
  static const double _shakeThreshold = 15.0;
  static const int _requiredShakes = 3;
  static const int _windowMs = 3000;

  int _shakeCount = 0;
  DateTime? _firstShakeTime;

  /// Called when triple-shake is detected.
  Function? onTripleShake;

  void start() {
    accelerometerEventStream().listen((event) {
      final magnitude = sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      if (magnitude > _shakeThreshold) {
        final now = DateTime.now();

        // ✅ Fixed: null-aware assignment
        _firstShakeTime ??= now;

        final elapsed = now.difference(_firstShakeTime!).inMilliseconds;

        if (elapsed <= _windowMs) {
          _shakeCount++;
          if (_shakeCount >= _requiredShakes) {
            _shakeCount = 0;
            _firstShakeTime = null;
            onTripleShake?.call();
          }
        } else {
          // Reset window — new shake sequence starts
          _shakeCount = 1;
          _firstShakeTime = now;
        }
      }
    });
  }

  void stop() {
    _shakeCount = 0;
    _firstShakeTime = null;
  }
}
