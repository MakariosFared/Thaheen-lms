import 'package:flutter/material.dart';
import '../../application/course_details/course_details_state.dart';
import '../../domain/entities/lesson_progress.dart';
import '../theme/app_theme.dart';

class LessonListItem extends StatelessWidget {
  final LessonItemViewData item;
  final VoidCallback onTap;
  final VoidCallback onLockedTap;

  const LessonListItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLockedTap,
  });

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    if (mins > 0) {
      return '$mins:${secs.toString().padLeft(2, '0')} دقيقة';
    }
    return '$secs ثانية';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final lesson = item.lesson;
    final status = item.status;
    final isUnlocked = item.isUnlocked;

    Widget statusIcon;
    Color? badgeBg;
    Color? badgeTextColor;
    String statusText;

    switch (status) {
      case LessonStatus.completed:
        statusIcon = const Icon(
          Icons.check_circle_rounded,
          color: AppColors.success,
          size: 24,
        );
        badgeBg = isDark ? const Color(0xFF064E3B) : AppColors.successLight;
        badgeTextColor = isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46);
        statusText = 'مكتمل';
        break;

      case LessonStatus.inProgress:
        statusIcon = const Icon(
          Icons.play_circle_fill_rounded,
          color: AppColors.warning,
          size: 24,
        );
        badgeBg = isDark ? const Color(0xFF78350F) : AppColors.warningLight;
        badgeTextColor = isDark ? const Color(0xFFFCD34D) : const Color(0xFF92400E);
        statusText = 'قيد المشاهدة';
        break;

      case LessonStatus.locked:
        statusIcon = Icon(
          Icons.lock_rounded,
          color: isDark ? AppColors.locked : AppColors.locked,
          size: 22,
        );
        badgeBg = isDark ? AppColors.surfaceVariantDark : AppColors.lockedLight;
        badgeTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
        statusText = 'مقفول';
        break;

      case LessonStatus.notStarted:
        statusIcon = Icon(
          Icons.play_circle_outline_rounded,
          color: isDark ? AppColors.textSecondaryDark : AppColors.primary,
          size: 24,
        );
        badgeBg = isDark ? AppColors.surfaceVariantDark : AppColors.primaryLight;
        badgeTextColor = isDark ? AppColors.textPrimaryDark : AppColors.primaryDark;
        statusText = 'لم يبدأ';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnlocked
              ? (isDark ? AppColors.borderDark : AppColors.borderLight)
              : (isDark ? Colors.white10 : Colors.black12),
          width: 1,
        ),
      ),
      child: Material(
        color: isUnlocked
            ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
            : (isDark ? const Color(0xFF0B111D) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isUnlocked ? onTap : onLockedTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Status indicator
                statusIcon,
                const SizedBox(width: 14),

                // Title & Duration
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked
                              ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                              : (isDark ? AppColors.textSecondaryDark : Colors.black45),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDuration(lesson.durationSec),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                          if (item.progress != null &&
                              item.progress!.lastPositionSec > 0 &&
                              status == LessonStatus.inProgress)
                            Text(
                              '• تم مشاهدة ${_formatDuration(item.progress!.lastPositionSec)} (${item.watchedPercent.toStringAsFixed(0)}%)',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.warning : const Color(0xFFD97706),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      if (status == LessonStatus.inProgress && item.watchedFraction > 0) ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: item.watchedFraction,
                            minHeight: 4,
                            backgroundColor: isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariantLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Status Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
