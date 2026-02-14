import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/evidence_model.dart';

/// Repository handling all Evidence (audio/video recordings) via Hive.
/// Hive stores metadata; actual files live on the device file system.
class EvidenceRepository {
  static const String _boxName = 'evidence';

  Box<EvidenceModel> get _box => Hive.box<EvidenceModel>(_boxName);

  // ─── CREATE ────────────────────────────────────────────────

  /// Saves evidence metadata to Hive after a recording is complete.
  Future<void> saveEvidence(EvidenceModel evidence) async {
    await _box.put(evidence.id, evidence);
  }

  // ─── READ ──────────────────────────────────────────────────

  /// Returns all evidence sorted by newest first.
  List<EvidenceModel> getAllEvidence() {
    final list = _box.values.toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  /// Returns only audio evidence.
  List<EvidenceModel> getAudioEvidence() {
    return getAllEvidence().where((e) => e.type == EvidenceType.audio).toList();
  }

  /// Returns only video evidence.
  List<EvidenceModel> getVideoEvidence() {
    return getAllEvidence().where((e) => e.type == EvidenceType.video).toList();
  }

  /// Returns a single evidence item by ID, or null.
  EvidenceModel? getEvidenceById(String id) {
    return _box.get(id);
  }

  /// Total count of saved evidence items.
  int get evidenceCount => _box.length;

  // ─── UPDATE ────────────────────────────────────────────────

  /// Marks evidence as SMS sent.
  Future<void> markSmsSent(String id) async {
    final evidence = _box.get(id);
    if (evidence != null) {
      final updated = EvidenceModel(
        id: evidence.id,
        filePath: evidence.filePath,
        type: evidence.type,
        timestamp: evidence.timestamp,
        location: evidence.location,
        durationSeconds: evidence.durationSeconds,
        smsSent: true,
      );
      await _box.put(id, updated);
    }
  }

  // ─── DELETE ────────────────────────────────────────────────

  /// Deletes evidence metadata from Hive AND deletes the actual file.
  Future<void> deleteEvidence(String id) async {
    final evidence = _box.get(id);
    if (evidence != null) {
      // Delete the actual audio/video file from storage
      final file = File(evidence.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      // Remove metadata from Hive
      await _box.delete(id);
    }
  }

  /// Deletes all evidence and their files.
  Future<void> clearAll() async {
    for (final evidence in _box.values) {
      final file = File(evidence.filePath);
      if (await file.exists()) {
        await file.delete();
      }
    }
    await _box.clear();
  }

  // ─── LISTENABLE ────────────────────────────────────────────

  /// Returns a listenable for reactive UI updates.
  /// Use with ValueListenableBuilder in EvidenceScreen.
  ValueListenable<Box<EvidenceModel>> get listenable => _box.listenable();
}
