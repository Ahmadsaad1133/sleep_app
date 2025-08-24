// lib/widgets/environment_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../../../core/utils/screen_utils.dart';
import '../../sleep_analysis/models/sleeplog_model_page.dart';

class EnvironmentSection extends StatelessWidget {
  const EnvironmentSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SleepLog>();

    return Container(
      padding: ScreenUtils.paddingAll(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ScreenUtils.scale(24)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x252A2740), Color(0x101A237E)],
        ),
        border: Border.all(color: const Color(0xFF5A6BC0).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(),
          SizedBox(height: ScreenUtils.height(28)),
          _buildFactorSection(
            title: 'NOISE LEVEL',
            icon: Icons.volume_down,
            options: ['Quiet', 'Moderate', 'Noisy'],
            currentValue: model.noiseLevel,
            onChanged: model.setNoiseLevel,
            color: const Color(0xFF5A6BC0),
          ),
          SizedBox(height: ScreenUtils.height(28)),
          _buildFactorSection(
            title: 'LIGHT EXPOSURE',
            icon: Icons.light_mode,
            options: ['Dark', 'Dim', 'Bright'],
            currentValue: model.lightExposure,
            onChanged: model.setLightExposure,
            color: const Color(0xFFFCE38A),
          ),
          SizedBox(height: ScreenUtils.height(28)),
          _buildFactorSection(
            title: 'TEMPERATURE',
            icon: Icons.thermostat,
            options: ['Cold', 'Cool', 'Comfortable', 'Warm', 'Hot'],
            currentValue: model.temperature,
            onChanged: model.setTemperature,
            color: const Color(0xFFE57373),
          ),
          SizedBox(height: ScreenUtils.height(28)),
          _buildFactorSection(
            title: 'COMFORT LEVEL',
            icon: Icons.king_bed,
            options: ['Uncomfortable', 'Neutral', 'Comfortable'],
            currentValue: model.comfortLevel,
            onChanged: model.setComfortLevel,
            color: const Color(0xFF81C784),
          ),
          SizedBox(height: ScreenUtils.height(28)),
          _buildNotesField(model),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Shimmer(
          duration: const Duration(seconds: 3),
          child: Container(
            padding: ScreenUtils.paddingAll(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5A6BC0).withOpacity(0.2),
            ),
            child: Icon(
              Icons.nightlight_round,
              color: const Color(0xFF37B9C6),
              size: ScreenUtils.textScale(20),
            ),
          ),
        ),
        SizedBox(width: ScreenUtils.width(12)),
        Expanded(
          child: AutoSizeText(
            'SLEEP ENVIRONMENT',
            maxLines: 1,
            minFontSize: 14,
            style: TextStyle(
              fontSize: ScreenUtils.textScale(18),
              fontWeight: FontWeight.w600,
              color: Colors.amber[100],
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: Colors.blueAccent.withOpacity(0.4),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFactorSection({
    required String title,
    required IconData icon,
    required List<String> options,
    required String currentValue,
    required Function(String) onChanged,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: ScreenUtils.paddingAll(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.1),
              ),
              child: Icon(icon, size: ScreenUtils.textScale(20), color: color),
            ),
            SizedBox(width: ScreenUtils.width(12)),
            Expanded(
              child: Shimmer(
                duration: const Duration(seconds: 3),
                child: AutoSizeText(
                  title,
                  maxLines: 1,
                  minFontSize: 10,
                  style: TextStyle(
                    color: color,
                    fontSize: ScreenUtils.textScale(14),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtils.height(16)),
        Wrap(
          spacing: ScreenUtils.width(12),
          runSpacing: ScreenUtils.height(12),
          children: options.map((option) {
            final isSelected = currentValue == option;
            return _DreamyOption(
              label: option,
              isSelected: isSelected,
              onSelected: () => onChanged(option),
              color: color,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildNotesField(SleepLog model) {
    return TextField(
      onChanged: model.setSleepEnvironment,
      style: TextStyle(
        color: Colors.white,
        fontSize: ScreenUtils.textScale(14),
      ),
      decoration: InputDecoration(
        labelText: 'Additional environment notes',
        labelStyle: TextStyle(
          color: Colors.white70,
          fontSize: ScreenUtils.textScale(14),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
      ),
      maxLines: 2,
    );
  }
}

class _DreamyOption extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color color;

  const _DreamyOption({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.color,
  }) : super(key: key);

  @override
  State<_DreamyOption> createState() => _DreamyOptionState();
}

class _DreamyOptionState extends State<_DreamyOption> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: widget.onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: ScreenUtils.symmetric(h: 20, v: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ScreenUtils.scale(20)),
          gradient: widget.isSelected
              ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.color.withOpacity(0.2),
              widget.color.withOpacity(0.05),
            ],
          )
              : null,
          border: Border.all(
            color: widget.isSelected
                ? widget.color.withOpacity(0.4)
                : Colors.blueGrey.withOpacity(0.2),
            width: ScreenUtils.scale(1.0),
          ),
          boxShadow: widget.isSelected
              ? [
            BoxShadow(
              color: widget.color.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            )
          ]
              : null,
        ),
        child: Shimmer(
          duration: const Duration(seconds: 3),
          child: AutoSizeText(
            widget.label,
            maxLines: 1,
            minFontSize: 10,
            style: TextStyle(
              fontSize: ScreenUtils.textScale(14),
              fontWeight: FontWeight.w500,
              color:
              widget.isSelected ? Colors.white : Colors.blueGrey[100],
            ),
          ),
        ),
      ),
    );
  }
}
