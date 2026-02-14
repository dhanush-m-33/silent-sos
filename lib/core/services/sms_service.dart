import 'package:flutter_sms/flutter_sms.dart';
import '../../../data/repositories/contact_repository.dart'; // ✅ Fixed: proper import

/// Sends SOS SMS to all emergency contacts using native Android SMS.
/// Works without internet — only needs cellular signal.
class SmsService {
  final ContactRepository _contactRepo;

  SmsService(this._contactRepo);

  Future<bool> sendAlert({
    required String userName,
    required String coords,
  }) async {
    final contacts = _contactRepo.getAllContacts();

    if (contacts.isEmpty) return false;

    final numbers = contacts.map((c) => c.phone).toList();

    final now = DateTime.now();
    final timeStr = '${now.day}/${now.month}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    final message = '🆘 SILENT SOS ALERT\n'
        '$userName needs help!\n'
        'Location: https://maps.google.com/?q=$coords\n'
        'Time: $timeStr\n'
        '— Sent automatically by Silent SOS app';

    try {
      await sendSMS(message: message, recipients: numbers);
      return true;
    } catch (e) {
      return false;
    }
  }
}
