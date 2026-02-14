import 'package:record/record.dart';
import 'package:camera/camera.dart';
import '../../core/utils/file_util.dart';

/// Handles 10-second audio and video recording when SOS is triggered.
class RecordingService {
  static final AudioRecorder _audioRecorder = AudioRecorder();
  static CameraController? _cameraController;

  /// Records audio and video concurrently for 10 seconds.
  /// Returns a map with 'audioPath' and 'videoPath'.
  static Future<Map<String, String?>> recordBoth() async {
    final results = await Future.wait([
      _recordAudio(),
      _recordVideo(),
    ]);
    return {
      'audioPath': results[0],
      'videoPath': results[1],
    };
  }

  /// Records audio for 10 seconds. Returns file path or null on failure.
  static Future<String?> _recordAudio() async {
    try {
      final path = await FileUtil.generateAudioFilePath();
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) return null;

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      await Future.delayed(const Duration(seconds: 10));
      await _audioRecorder.stop();
      return path;
    } catch (_) {
      return null;
    }
  }

  /// Records video for 10 seconds. Returns file path or null on failure.
  static Future<String?> _recordVideo() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return null;

      // Use front camera for better evidence capture
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false, // audio handled separately
      );

      await _cameraController!.initialize();

      await _cameraController!.startVideoRecording();
      await Future.delayed(const Duration(seconds: 10));

      final file = await _cameraController!.stopVideoRecording();
      await _cameraController!.dispose();
      _cameraController = null;

      return file.path;
    } catch (_) {
      _cameraController?.dispose();
      _cameraController = null;
      return null;
    }
  }

  static Future<void> dispose() async {
    await _audioRecorder.dispose();
    await _cameraController?.dispose();
  }
}
