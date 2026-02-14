import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Utility class for managing file paths and directories
/// used to store SOS audio and video recordings.
class FileUtil {
  // ─── DIRECTORY PATHS ───────────────────────────────────────

  /// Returns (and creates if needed) the audio recordings directory.
  static Future<String> getAudioDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${dir.path}/sos_audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir.path;
  }

  /// Returns (and creates if needed) the video recordings directory.
  static Future<String> getVideoDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final videoDir = Directory('${dir.path}/sos_video');
    if (!await videoDir.exists()) {
      await videoDir.create(recursive: true);
    }
    return videoDir.path;
  }

  // ─── FILE PATHS ────────────────────────────────────────────

  /// Generates a unique audio file path using current timestamp.
  /// Format: /sos_audio/audio_20240115_143022.aac
  static Future<String> generateAudioFilePath() async {
    final dir = await getAudioDir();
    final timestamp = _formatTimestamp(DateTime.now());
    return '$dir/audio_$timestamp.aac';
  }

  /// Generates a unique video file path using current timestamp.
  /// Format: /sos_video/video_20240115_143022.mp4
  static Future<String> generateVideoFilePath() async {
    final dir = await getVideoDir();
    final timestamp = _formatTimestamp(DateTime.now());
    return '$dir/video_$timestamp.mp4';
  }

  // ─── STORAGE INFO ──────────────────────────────────────────

  /// Returns total size of all evidence files in MB.
  static Future<double> getTotalEvidenceSizeMB() async {
    double totalBytes = 0;
    final dirs = [
      await getAudioDir(),
      await getVideoDir(),
    ];
    for (final dirPath in dirs) {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File) {
            totalBytes += await entity.length();
          }
        }
      }
    }
    return totalBytes / (1024 * 1024);
  }

  /// Returns count of files in evidence directories.
  static Future<int> getTotalEvidenceCount() async {
    int count = 0;
    final dirs = [
      await getAudioDir(),
      await getVideoDir(),
    ];
    for (final dirPath in dirs) {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File) count++;
        }
      }
    }
    return count;
  }

  // ─── HELPERS ───────────────────────────────────────────────

  /// Checks if a file exists at a given path.
  static Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  /// Formats DateTime to a filename-safe string.
  /// e.g. 2024-01-15 14:30:22 → 20240115_143022
  static String _formatTimestamp(DateTime dt) {
    final year = dt.year.toString();
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final sec = dt.second.toString().padLeft(2, '0');
    return '$year$month${day}_$hour$min$sec';
  }

  /// Formats file size in human-readable form.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
