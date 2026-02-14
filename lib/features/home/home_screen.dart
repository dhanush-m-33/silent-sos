import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/sos_service.dart';
import '../../data/repositories/contact_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'widgets/sos_button.dart';
import 'widgets/cancel_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final SOSService _sosService = SOSService();
  final ContactRepository _contactRepo = ContactRepository();
  final UserRepository _userRepo = UserRepository();

  bool _sosActive = false; // cancel overlay visible
  bool _alertSending = false; // recording + sending in progress
  bool _alertSent = false; // success state

  late AnimationController _statusAnimController;
  late Animation<double> _statusFade;

  @override
  void initState() {
    super.initState();

    _statusAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _statusFade = CurvedAnimation(
      parent: _statusAnimController,
      curve: Curves.easeInOut,
    );

    // Start shake + voice listeners
    _sosService.initialize(onSOSTriggered: _onSOSTriggered);
  }

  @override
  void dispose() {
    _sosService.dispose();
    _statusAnimController.dispose();
    super.dispose();
  }

  // ─── SOS FLOW ───────────────────────────────────────────

  /// Step 1 — Trigger: show cancel overlay
  void _onSOSTriggered() {
    if (_sosActive || _alertSending) return;

    // Warn if no contacts added
    if (_contactRepo.isEmpty) {
      _showNoContactsWarning();
      return;
    }

    setState(() {
      _sosActive = true;
      _alertSent = false;
    });

    // Show the cancel overlay as a dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => CancelOverlay(
        onCancel: _onCancelled,
        onExpired: _onCountdownExpired,
      ),
    );

    // Start the SOS delay in parallel
    _sosService.executeAfterDelay().then((_) {
      if (!mounted) return;
      setState(() {
        _alertSending = false;
        _alertSent = true;
      });
      _statusAnimController.forward(from: 0);

      // Reset success state after 5 seconds
      Future.delayed(const Duration(seconds: 5), () {
        if (!mounted) return;
        _statusAnimController.reverse().then((_) {
          if (mounted) setState(() => _alertSent = false);
        });
      });
    });
  }

  /// Step 2a — User tapped CANCEL
  void _onCancelled() {
    _sosService.cancel();
    if (mounted) {
      setState(() => _sosActive = false);
      Navigator.of(context).pop(); // close overlay
      _showSnackBar('SOS cancelled.', AppColors.warning, Icons.cancel_outlined);
    }
  }

  /// Step 2b — 10s elapsed, no cancel
  void _onCountdownExpired() {
    if (mounted) {
      setState(() {
        _sosActive = false;
        _alertSending = true;
      });
      Navigator.of(context).pop(); // close overlay
    }
  }

  /// Button press trigger
  void _onSOSButtonPressed() {
    _onSOSTriggered();
  }

  // ─── HELPERS ────────────────────────────────────────────

  void _showNoContactsWarning() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.warning, size: 22),
            SizedBox(width: 10),
            Text(
              'No Contacts',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          AppStrings.noContactsWarning,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.contacts);
            },
            child: const Text('Add Contacts'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Dismiss',
              style: TextStyle(color: AppColors.textHint),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(msg),
          ],
        ),
      ),
    );
  }

  // ─── BUILD ──────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = _userRepo.getUser();
    final contactCount = _contactRepo.contactCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(user?.name ?? 'User', contactCount),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatusBadge(),
                  const SizedBox(height: 16),
                  SOSButton(
                    onPressed: _onSOSButtonPressed,
                    isArmed: !_alertSending,
                  ),
                  const SizedBox(height: 40),
                  _buildDescription(),
                ],
              ),
            ),
            _buildTriggerIcons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(String name, int contactCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${name.split(' ').first}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  AppStrings.appTagline,
                  style: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Contact count badge
          GestureDetector(
            onTap: () => context.go(AppRoutes.contacts),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: contactCount > 0
                    ? AppColors.success.withValues(alpha: 0.12)
                    : AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: contactCount > 0
                      ? AppColors.success.withValues(alpha: 0.3)
                      : AppColors.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.contacts_outlined,
                    size: 14,
                    color: contactCount > 0
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$contactCount contact${contactCount == 1 ? '' : 's'}',
                    style: TextStyle(
                      color: contactCount > 0
                          ? AppColors.success
                          : AppColors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (_alertSending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.warning,
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Sending alert...',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_alertSent) {
      return FadeTransition(
        opacity: _statusFade,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline,
                  color: AppColors.success, size: 14),
              SizedBox(width: 8),
              Text(
                'Alert sent!',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Default — ready state
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fiber_manual_record, color: AppColors.success, size: 10),
          SizedBox(width: 8),
          Text(
            'Armed & Ready',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        AppStrings.sosDescription,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textHint,
          fontSize: 13,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildTriggerIcons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _triggerIcon(
            icon: Icons.touch_app_outlined,
            label: 'Press',
          ),
          _divider(),
          _triggerIcon(
            icon: Icons.vibration,
            label: 'Shake ×3',
          ),
          _divider(),
          _triggerIcon(
            icon: Icons.mic_outlined,
            label: '"Help Help"',
          ),
        ],
      ),
    );
  }

  Widget _triggerIcon({required IconData icon, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Icon(icon, color: AppColors.textSecondary, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 20,
      color: AppColors.cardBorder,
    );
  }
}
