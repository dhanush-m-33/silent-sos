import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/evidence_model.dart';
import '../../data/repositories/evidence_repository.dart';
import 'widgets/evidence_tile.dart';

class EvidenceScreen extends StatelessWidget {
  const EvidenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final evidenceRepo = EvidenceRepository();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.evidence),
        actions: [
          // Clear all button — only shown when there's evidence
          ValueListenableBuilder<Box<EvidenceModel>>(
            valueListenable: evidenceRepo.listenable,
            builder: (_, box, __) {
              if (box.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Clear all',
                onPressed: () => _confirmClearAll(context, evidenceRepo),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<EvidenceModel>>(
        valueListenable: evidenceRepo.listenable,
        builder: (context, box, _) {
          final items = evidenceRepo.getAllEvidence();

          if (items.isEmpty) {
            return _buildEmpty();
          }

          return Column(
            children: [
              _buildSummaryBar(items),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: items.length,
                  itemBuilder: (_, index) {
                    final evidence = items[index];
                    return EvidenceTile(
                      evidence: evidence,
                      onDelete: () =>
                          _confirmDelete(context, evidenceRepo, evidence),
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

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          SizedBox(height: 16),
          Text(
            AppStrings.noEvidence,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            AppStrings.noEvidenceSubtitle,
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(List<EvidenceModel> items) {
    final audioCount = items.where((e) => e.type == EvidenceType.audio).length;
    final videoCount = items.where((e) => e.type == EvidenceType.video).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          _summaryChip(
            Icons.mic_rounded,
            '$audioCount audio',
            AppColors.info,
          ),
          const SizedBox(width: 16),
          _summaryChip(
            Icons.videocam_rounded,
            '$videoCount video',
            AppColors.primary,
          ),
          const Spacer(),
          Text(
            '${items.length} total',
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ─── DIALOGS ────────────────────────────────────────────

  void _confirmDelete(
    BuildContext context,
    EvidenceRepository repo,
    EvidenceModel evidence,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Text(
          AppStrings.deleteEvidence,
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        content: const Text(
          AppStrings.deleteEvidenceConfirm,
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
              await repo.deleteEvidence(evidence.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, EvidenceRepository repo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Text(
          'Clear All Evidence',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 17),
        ),
        content: const Text(
          'This will permanently delete all recordings and files. This cannot be undone.',
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
              await repo.clearAll();
            },
            child: const Text(
              'Clear All',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
