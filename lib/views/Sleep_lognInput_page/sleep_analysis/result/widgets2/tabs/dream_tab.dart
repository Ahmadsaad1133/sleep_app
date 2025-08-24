import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../constants/colors.dart';
import '../../widgets/dream_mood_forecast/dream_mood_forecast.dart';

class DreamTab extends StatelessWidget {
  final Map<String, dynamic>? dreamMoodForecast;
  final Map<String, dynamic>? enhancedDreamAnalysis;
  final VoidCallback? onRetry;
  final bool isLoading;
  final double dreamLabHeight;
  final Map<String, dynamic> sleepData;
  final bool autoPlaySections;

  const DreamTab({
    super.key,
    required this.dreamMoodForecast,
    this.enhancedDreamAnalysis,
    this.onRetry,
    required this.isLoading,
    required this.sleepData,
    this.dreamLabHeight = 4000,
    this.autoPlaySections = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = dreamMoodForecast != null && dreamMoodForecast!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: dreamLabHeight,
            child: DreamLabScreen(
              forecast: dreamMoodForecast ?? {},
              onRetry: onRetry ?? () {},
              enhancedDreamAnalysis: enhancedDreamAnalysis ?? {},
              sleepData: sleepData,
              autoPlaySections: autoPlaySections,
            ),
          ),

          if (!hasData && !isLoading)
            _buildEmptyState(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No dream data available for this session',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildSlivers({
    required BuildContext context,
    required Map<String, dynamic>? dreamMoodForecast,
    required double bottomPadding,
    required double backgroundHeight,
    required double dreamLabMinHeight,
  }) {
    return [
      SliverToBoxAdapter(
        child: SizedBox(
          height: dreamLabMinHeight,
          child: DreamLabScreen(
            forecast: dreamMoodForecast ?? {},
            onRetry: onRetry ?? () {},
            enhancedDreamAnalysis: enhancedDreamAnalysis ?? {},
            sleepData: sleepData,
            autoPlaySections: autoPlaySections,
          ),
        ),
      ),
      SliverPadding(padding: EdgeInsets.only(bottom: bottomPadding)),
    ];
  }
}

class _DreamsJsonBackground extends StatefulWidget {
  const _DreamsJsonBackground({super.key});

  @override
  State<_DreamsJsonBackground> createState() => _DreamsJsonBackgroundState();
}

class _DreamsJsonBackgroundState extends State<_DreamsJsonBackground> {
  List<dynamic> dreamsData = [];

  @override
  void initState() {
    super.initState();
    _loadDreamsJson();
  }

  Future<void> _loadDreamsJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/dreams.json');
      final data = json.decode(jsonString);
      setState(() {
        dreamsData = data['dreams'] ?? [];
      });
    } catch (e) {
      debugPrint("Error loading dreams.json: $e");
      setState(() {
        dreamsData = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (dreamsData.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: dreamsData.map((dream) {
        final x = (dream['x'] ?? 0).toDouble();
        final y = (dream['y'] ?? 0).toDouble();
        final size = (dream['size'] ?? 20).toDouble();

        Color color;
        try {
          final colorRaw = dream['color'] ?? '0xFFFFFFFF';
          color = Color(int.parse(colorRaw.toString()));
        } catch (_) {
          color = Colors.white;
        }

        return Positioned(
          left: x,
          top: y,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.5),
            ),
          ),
        );
      }).toList(),
    );
  }
}