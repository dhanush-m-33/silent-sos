import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Animated pulsing SOS button.
/// Shows a triple-ring pulse animation when [isArmed] is true.
class SOSButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isArmed; // true = pulse animation active

  const SOSButton({
    super.key,
    required this.onPressed,
    this.isArmed = true,
  });

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulse1;
  late Animation<double> _pulse2;
  late Animation<double> _pulse3;
  late Animation<double> _opacity1;
  late Animation<double> _opacity2;
  late Animation<double> _opacity3;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Three rings staggered in time
    _pulse1 = Tween<double>(begin: 1.0, end: 1.9).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _pulse2 = Tween<double>(begin: 1.0, end: 1.9).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );
    _pulse3 = Tween<double>(begin: 1.0, end: 1.9).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _opacity1 = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _opacity2 = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );
    _opacity3 = Tween<double>(begin: 0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 160.0;

    return GestureDetector(
      onTap: widget.onPressed,
      child: SizedBox(
        width: buttonSize * 2,
        height: buttonSize * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse rings (behind button)
            if (widget.isArmed) ...[
              _buildPulseRing(buttonSize, _pulse3, _opacity3),
              _buildPulseRing(buttonSize, _pulse2, _opacity2),
              _buildPulseRing(buttonSize, _pulse1, _opacity1),
            ],

            // Outer glow ring
            Container(
              width: buttonSize + 20,
              height: buttonSize + 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
            ),

            // Main button
            Container(
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFFEF5350),
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield,
                    color: Colors.white,
                    size: 38,
                  ),
                  SizedBox(height: 6),
                  Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPulseRing(
    double size,
    Animation<double> scale,
    Animation<double> opacity,
  ) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (_, __) {
        return Transform.scale(
          scale: scale.value,
          child: Opacity(
            opacity: opacity.value.clamp(0.0, 1.0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
