import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/models/user_model.dart';
import 'data/models/contact_model.dart';
import 'data/models/evidence_model.dart';
import 'core/utils/file_util.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Initialize Hive ─────────────────────────────────────
  await Hive.initFlutter();

  // ── 2. Register all Hive type adapters ────────────────────
  // Order matters: register before opening boxes
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(ContactModelAdapter());
  Hive.registerAdapter(EvidenceTypeAdapter()); // register enum first
  Hive.registerAdapter(EvidenceModelAdapter());

  // ── 3. Open Hive boxes ────────────────────────────────────
  await Future.wait([
    Hive.openBox<UserModel>('user'),
    Hive.openBox<ContactModel>('contacts'),
    Hive.openBox<EvidenceModel>('evidence'),
  ]);

  // ── 4. Ensure media storage directories exist ─────────────
  await FileUtil.getAudioDir();
  await FileUtil.getVideoDir();

  // ── 5. Launch app ─────────────────────────────────────────
  runApp(const SilentSOSApp());
}
