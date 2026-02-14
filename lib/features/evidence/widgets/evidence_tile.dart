import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/evidence_model.dart';

/// Single evidence item tile shown in the Evidence screen list.
class EvidenceTile extends StatelessWidget {
  final EvidenceModel evidence;
  final VoidCallback onDelete;

  const EvidenceTile({
    super.key,
    required this.evidence,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isAudio = evidence.type == EvidenceType.audio;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Type icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isAudio
                    ? AppColors.info.withValues(alpha: 0.12)
                    : AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isAudio ? Icons.mic_rounded : Icons.videocam_rounded,
                color: isAudio ? AppColors.info : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type + SMS badge row
                  Row(
                    children: [
                      Text(
                        evidence.typeLabel,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (evidence.smsSent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'SMS Sent',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Timestamp
                  Text(
                    evidence.formattedDate,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Location + duration row
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 11,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          evidence.location == '0.0,0.0'
                              ? 'Location unavailable'
                              : evidence.location,
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.timer_outlined,
                        size: 11,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${evidence.durationSeconds}s',
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Delete button
            IconButton(
              onPressed: onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
