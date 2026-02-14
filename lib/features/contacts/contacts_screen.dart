import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/contact_model.dart';
import '../../data/repositories/contact_repository.dart';
import 'widgets/contact_tile.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contactRepo = ContactRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.emergencyContacts),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddContactSheet(context, contactRepo),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text(
          'Add Contact',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ValueListenableBuilder<Box<ContactModel>>(
        valueListenable: contactRepo.listenable,
        builder: (context, box, _) {
          final contacts = contactRepo.getAllContacts();

          if (contacts.isEmpty) {
            return _buildEmpty(context, contactRepo);
          }

          return Column(
            children: [
              _buildInfoBanner(contacts.length),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: contacts.length,
                  itemBuilder: (_, index) {
                    final contact = contacts[index];
                    return ContactTile(
                      contact: contact,
                      onDelete: () =>
                          _confirmDelete(context, contactRepo, contact),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── WIDGETS ────────────────────────────────────────────

  Widget _buildEmpty(BuildContext context, ContactRepository repo) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.contacts_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.noContacts,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.noContactsSubtitle,
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddContactSheet(context, repo),
            icon: const Icon(Icons.person_add_outlined, size: 18),
            label: const Text('Add First Contact'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(int count) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'SOS alerts will be sent to all $count contact${count == 1 ? '' : 's'} via SMS.',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── ADD CONTACT BOTTOM SHEET ────────────────────────────

  void _showAddContactSheet(BuildContext context, ContactRepository repo) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                AppStrings.addContact,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'This person will receive SOS alerts via SMS.',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),

              // Name field
              TextFormField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: AppStrings.contactName,
                  prefixIcon: Icon(Icons.person_outline, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone field
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: AppStrings.contactPhone,
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                  hintText: '+91 9999999999',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  final digits = val.replaceAll(RegExp(r'[\s\+\-\(\)]'), '');
                  if (digits.length < 10) return AppStrings.invalidPhone;
                  if (repo.phoneExists(val.trim())) {
                    return AppStrings.phoneAlreadyExists;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final contact = ContactModel(
                      id: const Uuid().v4(),
                      name: nameController.text.trim(),
                      phone: phoneController.text.trim(),
                      addedAt: DateTime.now(),
                    );

                    await repo.addContact(contact);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text(AppStrings.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── DIALOGS ────────────────────────────────────────────

  void _confirmDelete(
    BuildContext context,
    ContactRepository repo,
    ContactModel contact,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: Text(
          'Remove ${contact.name}?',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        content: const Text(
          AppStrings.deleteContactConfirm,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              AppStrings.cancel,
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await repo.deleteContact(contact.id);
            },
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
