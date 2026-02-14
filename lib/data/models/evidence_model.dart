import 'package:hive/hive.dart';

part 'evidence_model.g.dart';

/// Enum to distinguish evidence type
@HiveType(typeId: 3)
enum EvidenceType {
  @HiveField(0)
  audio,

  @HiveField(1)
  video,
}

@HiveType(typeId: 2)
class EvidenceModel extends HiveObject {
  @HiveField(0)
  String id;

  /// Absolute path to the file on device storage
  @HiveField(1)
  String filePath;

  /// 'audio' or 'video'
  @HiveField(2)
  EvidenceType type;

  /// When the SOS was triggered
  @HiveField(3)
  DateTime timestamp;

  /// "lat,lng" string e.g. "12.9716,77.5946"
  @HiveField(4)
  String location;

  /// Duration of the recording in seconds
  @HiveField(5)
  int durationSeconds;

  /// Whether SMS was sent successfully for this evidence
  @HiveField(6)
  bool smsSent;

  EvidenceModel({
    required this.id,
    required this.filePath,
    required this.type,
    required this.timestamp,
    required this.location,
    required this.durationSeconds,
    this.smsSent = false,
  });

  /// Human-readable label for display
  String get typeLabel => type == EvidenceType.audio ? 'Audio' : 'Video';

  /// File extension based on type
  String get fileExtension => type == EvidenceType.audio ? '.aac' : '.mp4';

  /// Formatted timestamp for display
  String get formattedDate {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} '
        '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}';
  }

  EvidenceModel copyWith({bool? smsSent}) {
    return EvidenceModel(
      id: id,
      filePath: filePath,
      type: type,
      timestamp: timestamp,
      location: location,
      durationSeconds: durationSeconds,
      smsSent: smsSent ?? this.smsSent,
    );
  }

  @override
  String toString() =>
      'EvidenceModel(id: $id, type: $typeLabel, timestamp: $formattedDate, location: $location)';
}
