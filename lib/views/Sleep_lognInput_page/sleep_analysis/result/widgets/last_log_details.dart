import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../../constants/fonts.dart';
import '../../../../../constants/colors.dart';
import '../../models/sleeplog_model_page.dart';

class LastLogDetails extends StatelessWidget {
  final SleepLog? lastSleepLog;

  const LastLogDetails({super.key, required this.lastSleepLog});

  @override
  Widget build(BuildContext context) {
    if (lastSleepLog == null) return const SizedBox();
    final durationHours = lastSleepLog!.durationMinutes ~/ 60;
    final durationMinutes = lastSleepLog!.durationMinutes % 60;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.nightlight_round,
            title: 'SLEEP DETAILS',
            iconColor: AppColors.primary,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailCard(
                      Icons.calendar_today,
                      'Date',
                      DateFormat.yMMMd().format(lastSleepLog!.date), // REMOVED .toDate()
                    ),
                    _buildDetailCard(
                      Icons.bedtime,
                      'Bedtime',
                      lastSleepLog!.bedtime,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailCard(
                      Icons.wb_sunny,
                      'Wake Time',
                      lastSleepLog!.wakeTime,
                    ),
                    _buildDetailCard(
                      Icons.timer,
                      'Duration',
                      '$durationHours h $durationMinutes m',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailCard(
                      Icons.star,
                      'Quality',
                      '${lastSleepLog!.quality}/10',
                    ),
                    _buildDetailCard(
                      Icons.mood,
                      'Mood',
                      lastSleepLog!.mood,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailCard(
                      Icons.emoji_emotions,
                      'Stress',
                      '${lastSleepLog!.stressLevel}/10',
                    ),
                    _buildDetailCard(
                      Icons.home,
                      'Environment',
                      lastSleepLog!.sleepEnvironment,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            AutoSizeText(
              title,
              maxLines: 1,
              minFontSize: 12,
              maxFontSize: 14,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontFamily: AppFonts.nunitoSansRegular,
              ),
            ),
            const SizedBox(height: 4),
            AutoSizeText(
              value,
              maxLines: 1,
              minFontSize: 14,
              maxFontSize: 16,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: AppFonts.nunitoSansBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: AutoSizeText(
              title,
              maxLines: 1,
              minFontSize: 14,
              maxFontSize: 18,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: iconColor,
                fontFamily: AppFonts.nunitoSansBold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}