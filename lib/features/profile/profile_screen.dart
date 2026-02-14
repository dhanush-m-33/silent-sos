import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../data/repositories/contact_repository.dart';
import '../../data/repositories/evidence_repository.dart';
import '../../data/repositories/user_repository.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepo = UserRepository();
    final contactRepo = ContactRepository();
    final evidenceRepo = EvidenceRepository();
    final user = userRepo.getUser();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.myProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(user?.name ?? 'User'),
            const SizedBox(height: 28),
            _buildInfoCard(user?.name, user?.phone, user?.email),
            const SizedBox(height: 16),
            _buildStatsCard(
              contactRepo.contactCount,
              evidenceRepo.evidenceCount,
            ),
            const SizedBox(height: 16),
            _buildAppInfoCard(),
            const SizedBox(height: 32),
            _buildLogoutButton(context, userRepo),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ─── WIDGETS ────────────────────────────────────────────

  Widget _buildAvatar(String name) {
    final initials = _getInitials(name);
    return Center(
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            AppStrings.appTagline,
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String? name, String? phone, String? email) {
    return _card(
      title: 'Account Info',
      icon: Icons.person_outline,
      children: [
        _infoRow(Icons.person_outline, 'Name', name ?? '—'),
        const Divider(height: 1),
        _infoRow(Icons.phone_outlined, 'Phone', phone ?? '—'),
        const Divider(height: 1),
        _infoRow(Icons.mail_outline, 'Email', email ?? '—'),
      ],
    );
  }

  Widget _buildStatsCard(int contacts, int evidence) {
    return _card(
      title: 'Overview',
      icon: Icons.bar_chart_outlined,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: _statBox(
                  Icons.contacts_outlined,
                  '$contacts',
                  'Contacts',
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statBox(
                  Icons.folder_outlined,
                  '$evidence',
                  'Recordings',
                  AppColors.info,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statBox(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return _card(
      title: 'App Info',
      icon: Icons.info_outline,
      children: [
        _infoRow(Icons.shield_outlined, 'App', AppStrings.appName),
        const Divider(height: 1),
        _infoRow(Icons.tag, 'Version', '1.0.0'),
        const Divider(height: 1),
        _infoRow(Icons.storage_outlined, 'Storage', 'Local (Hive)'),
        const Divider(height: 1),
        _infoRow(Icons.sms_outlined, 'Alerts', 'Via SMS (no internet)'),
      ],
    );
  }

  Widget _card({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.textHint),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(4),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textHint),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, UserRepository repo) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context, repo),
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text(AppStrings.logout),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ─── ACTIONS ────────────────────────────────────────────

  void _confirmLogout(BuildContext context, UserRepository repo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Text(
          AppStrings.logoutTitle,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        content: const Text(
          AppStrings.logoutConfirm,
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
              await repo.logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: const Text(
              AppStrings.logout,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ────────────────────────────────────────────

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
