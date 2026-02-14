import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Full-screen overlay shown for 10 seconds after SOS is triggered.
/// User can tap CANCEL to abort. If not cancelled, [onExpired] fires.
class CancelOverlay extends StatefulWidget {
  final VoidCallback onCancel;
  final VoidCallback onExpired;
  static const int countdownSeconds = 10;

  const CancelOverlay({
    super.key,
    required this.onCancel,
    required this.onExpired,
  });

  @override
  State<CancelOverlay> createState() => _CancelOverlayState();
}

class _CancelOverlayState extends State<CancelOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Timer _countdownTimer;
  int _secondsLeft = CancelOverlay.countdownSeconds;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();

    // Circular progress drains over 10 seconds
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: CancelOverlay.countdownSeconds),
    )..forward();

    // Countdown ticker
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        timer.cancel();
        if (!_cancelled) widget.onExpired();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _countdownTimer.cancel();
    super.dispose();
  }

  void _handleCancel() {
    _cancelled = true;
    _countdownTimer.cancel();
    widget.onCancel();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // prevent back button dismissing overlay
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.92),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWarningIcon(),
                const SizedBox(height: 32),
                _buildTitle(),
                const SizedBox(height: 12),
                _buildSubtitle(),
                const SizedBox(height: 56),
                _buildCountdownRing(),
                const SizedBox(height: 56),
                _buildCancelButton(),
                const SizedBox(height: 24),
                _buildHint(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWarningIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.15),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.primary,
        size: 36,
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'SOS TRIGGERED',
      style: TextStyle(
        color: AppColors.primary,
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Text(
        'Alert will be sent to your emergency contacts.\nTap CANCEL to stop.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildCountdownRing() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (_, __) {
        return SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              const SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  color: AppColors.surfaceVariant,
                ),
              ),
              // Draining foreground ring
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: 1.0 - _progressController.value,
                  strokeWidth: 8,
                  color: AppColors.primary,
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Countdown number
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_secondsLeft',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'seconds',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCancelButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: _handleCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cancelButton,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.close_rounded, size: 22),
              SizedBox(width: 10),
              Text(
                'CANCEL',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHint() {
    return const Text(
      'Recording will begin automatically',
      style: TextStyle(
        color: AppColors.textHint,
        fontSize: 12,
      ),
    );
  }
}
