import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets2/neo_design.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../../../services/api/api_service.dart';

// -----------------------------------------------------------------------------
// Global UI constants
//
// To unify the look and feel across the entire application we define a
// handful of colour and gradient constants here.  These values are shared
// throughout the widgets below to ensure a consistent 2025‑style aesthetic.
//
// The palette draws inspiration from deep‑space blues, electric purples and
// teal highlights, reminiscent of aurora borealis and holographic displays.
const Color kBackgroundStart = Color(0xFF071B2C);
const Color kBackgroundEnd   = Color(0xFF101E3C);

/// A vertical gradient for screen backgrounds.
const LinearGradient kBackgroundGradient = LinearGradient(
  colors: [kBackgroundStart, kBackgroundEnd],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);

/// A subtle diagonal gradient used for cards and panels.
const LinearGradient kCardGradient = LinearGradient(
  colors: [Color(0xFF0E1B40), Color(0xFF172452)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// The primary accent gradient used for active states and highlights.
const LinearGradient kAccentGradient = LinearGradient(
  colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ClinicalSection {
  final IconData icon;
  final Color color;
  final Color gradientStart;
  final Color gradientEnd;

  ClinicalSection(
      this.icon,
      this.color,
      this.gradientStart,
      this.gradientEnd,
      );
}

class DreamLabScreen extends StatefulWidget {
  final Map<String, dynamic> forecast;
  final VoidCallback onRetry;
  final Map<String, dynamic> enhancedDreamAnalysis;
  final Map<String, dynamic> sleepData;
  final bool autoPlaySections;
  final bool sliverMode;

  const DreamLabScreen({
    super.key,
    required this.forecast,
    required this.onRetry,
    required this.enhancedDreamAnalysis,
    required this.sleepData,
    this.autoPlaySections = true,
    this.sliverMode = false,
  });

  @override
  State<DreamLabScreen> createState() => _DreamLabScreenState();
}

class _DreamLabScreenState extends State<DreamLabScreen> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final ConfettiController _confettiController;
  int _activeSection = 0;
  final _pageController = PageController();
  bool _showTechnical = false;

  Map<String, dynamic>? _rawApiResponse;
  final List<Widget> _sectionWidgets = [];
  bool _sectionsBuilt = false;

  final List<ClinicalSection> _visualSections = [
    ClinicalSection(
      Icons.description,
      Colors.purple,
      const Color(0xFF6A11CB),
      const Color(0xFF2575FC),
    ),
    ClinicalSection(
      Icons.monitor_heart,
      Colors.blue,
      const Color(0xFF2193b0),
      const Color(0xFF6dd5ed),
    ),
    ClinicalSection(
      Icons.night_shelter,
      Colors.teal,
      const Color(0xFF11998e),
      const Color(0xFF38ef7d),
    ),
    ClinicalSection(
      Icons.psychology,
      Colors.pink,
      const Color(0xFFf857a6),
      const Color(0xFFff5858),
    ),
    ClinicalSection(
      Icons.lightbulb_outline,
      Colors.amber,
      const Color(0xFFFFA62E),
      const Color(0xFFEAECC6),
    ),
    ClinicalSection(
      Icons.medical_services,
      Colors.green,
      const Color(0xFF0ba360),
      const Color(0xFF3cba92),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _sectionWidgets.addAll(_buildSectionWidgets());
    _sectionsBuilt = true;

    // Always treat data as generated when using preloaded data
    _rawApiResponse = widget.enhancedDreamAnalysis;

    // Start auto-play if we have valid data
    if (widget.enhancedDreamAnalysis.isNotEmpty) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    if (widget.autoPlaySections) {
      Future.delayed(const Duration(seconds: 1), () {
        final pred = _apiString(dreamPrediction, 'prediction')?.toLowerCase() ?? '';
        final mood = _apiString(moodForecast, 'mood')?.toLowerCase() ?? '';
        if (pred.contains('vivid') || mood == 'positive') {
          _confettiController.play();
        }

        _pageController.animateToPage(
          1,
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void didUpdateWidget(DreamLabScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.enhancedDreamAnalysis != widget.enhancedDreamAnalysis) {
      setState(() {
        _rawApiResponse = widget.enhancedDreamAnalysis;
        _sectionWidgets.clear();
        _sectionWidgets.addAll(_buildSectionWidgets());
      });

      if (widget.enhancedDreamAnalysis.isNotEmpty) {
        _startAutoPlay();
      }
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _buildSectionWidgets() {
    return [
      KeepAliveWrapper(child: _buildExecutiveSummary()),
      KeepAliveWrapper(child: _buildNeuralProfile()),
      KeepAliveWrapper(child: _buildSleepArchitecture()),
      KeepAliveWrapper(child: _buildEmotionalProcessing()),
      KeepAliveWrapper(child: _buildCognitiveInsights()),
      KeepAliveWrapper(child: _buildClinicalRecommendations()),
    ];
  }

  Map<String, dynamic> _rootMap() {
    if (_rawApiResponse != null) return _rawApiResponse!;
    if (widget.enhancedDreamAnalysis.isNotEmpty) return widget.enhancedDreamAnalysis;
    return widget.forecast;
  }

  Map<String, dynamic> _prefMap(String key) {
    final root = _rootMap();
    final primary = root[key];
    if (primary is Map) return Map<String, dynamic>.from(primary);
    return <String, dynamic>{};
  }

  List<dynamic> _prefList(String key) {
    final root = _rootMap();
    final primary = root[key];
    if (primary is List) return List<dynamic>.from(primary);
    return <dynamic>[];
  }

  Map<String, dynamic> get dreamPrediction =>
      _prefMap('dream_prediction')..addAll(_prefMap('dream_metrics'));

  Map<String, dynamic> get moodForecast => _prefMap('mood_forecast');

  Map<String, dynamic> get neuralPatterns =>
      _prefMap('neural_patterns')..addAll(_prefMap('clinical_interpretation'));

  Map<String, dynamic> get clinicalInterpretation =>
      _prefMap('clinical_interpretation')..addAll(_prefMap('neural_patterns'));

  Map<String, dynamic> get sleepArchitecture => _prefMap('sleep_architecture');

  Map<String, dynamic> get cognitiveAssessment => _prefMap('cognitive_assessment');

  Map<String, dynamic> get uiTexts {
    final root = _rootMap();
    final primary = root['ui_texts'];
    if (primary is Map) return Map<String, dynamic>.from(primary);

    return {
      'header_title': 'DreamLab Analysis',
      'header_subtitle': 'Neuroscientific Sleep Insights',
      'sections': [
        'Summary', 'Neural', 'Sleep',
        'Emotions', 'Cognition', 'Recommendations'
      ],
      'card_primary_diagnosis': 'Primary Diagnosis',
      'card_affective_state': 'Affective State',
      'card_key_neural_indicators': 'Key Neural Indicators',
      'card_clinical_impression': 'Clinical Impression',
      'view_technical': 'View Technical Data',
      'hide_technical': 'Hide Technical Data',
      'card_technical_data': 'Technical Data',
      'export_action': 'Export Clinical Report',
      'section_clinical_dream_summary': 'Clinical Dream Summary',
      'section_quantitative_eeg': 'Quantitative EEG Analysis',
      'section_sleep_architecture': 'Sleep Architecture',
      'section_emotional_processing': 'Emotional Processing',
      'section_cognitive_assessment': 'Cognitive Assessment',
      'section_recommendations': 'Clinical Recommendations',
      'card_spectral_power': 'Spectral Power Distribution',
      'card_hemispheric_coherence': 'Hemispheric Coherence',
      'card_interhemispheric_asymmetry': 'Interhemispheric Asymmetry',
      'card_neural_interpretation': 'Neural Interpretation',
      'card_sleep_stage_distribution': 'Sleep Stage Distribution',
      'card_architecture_metrics': 'Architecture Metrics',
      'card_architecture_interpretation': 'Architecture Interpretation',
      'card_emotional_processing_index': 'Emotional Processing Index',
      'card_threat_simulation': 'Threat Simulation',
      'card_emotional_details': 'Emotional Details',
      'card_cognitive_performance': 'Cognitive Performance',
      'card_key_cognitive_metrics': 'Key Cognitive Metrics',
      'card_cognitive_interpretation': 'Cognitive Interpretation',
      'card_recommendations': 'Clinical Recommendations',
      'card_personalized_analysis': 'Personalized Analysis',
    };
  }

  String? _ui(String key) => uiTexts.containsKey(key) ? uiTexts[key].toString() : null;

  String? _apiString(Map<String, dynamic> map, String key) {
    if (map.containsKey(key) && map[key] != null) return map[key].toString();
    return null;
  }

  double? _apiDouble(dynamic v) {
    if (v == null) return null;
    return double.tryParse(v.toString());
  }

  bool _hasDouble(dynamic v) => _apiDouble(v) != null;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Apply our unified background gradient to the entire screen.  The
    // underlying colours are defined in the constants at the top of this file
    // and provide a cohesive cosmic feel across the app.
    return NeoBackground(child: Stack(
      children: [
        Column(
          children: [
            if (_ui('header_title') != null) _buildModernHeader(),
            if (_uiSectionTitles().isNotEmpty) _buildSectionTabs(_uiSectionTitles()),
            if (widget.sliverMode)
              _buildMainContent()
            else
              Expanded(child: _buildMainContent()),
          ],
        ),
        IgnorePointer(
          ignoring: true,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildMainContent() {
    if (widget.sliverMode) {
      return IndexedStack(
        index: _activeSection,
        children: _sectionWidgets,
      );
    }
    return PageView(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _activeSection = index),
      children: _sectionWidgets,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  List<String> _uiSectionTitles() {
    final s = uiTexts['sections'];
    if (s is List) return s.map((e) => e?.toString() ?? '').where((t) => t.isNotEmpty).toList();
    return <String>[];
  }

  Widget _buildModernHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: kCardGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          // Soft inner shadow for depth
          BoxShadow(
            color: Colors.black.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          // Subtle coloured glow to tie into the accent colours
          BoxShadow(
            color: Color(0xFF2575FC).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6A11CB),
                  const Color(0xFF2575FC),
                ],
              ),
            ),
            child: Icon(Icons.psychology_alt, color: Colors.white, size: 24.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _ui('header_title')!,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
                if (_ui('header_subtitle') != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    _ui('header_subtitle')!,
                    style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
          _buildHeaderActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeaderActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_ui('export_action') != null)
          _buildIconButton(
            icon: Icons.picture_as_pdf,
            color: Colors.red[300]!,
            onPressed: _exportClinicalReport,
          ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color],
        ),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20.r),
        color: Colors.white,
        onPressed: onPressed,
        padding: EdgeInsets.all(6.r),
      ),
    );
  }

  Widget _buildSectionTabs(List<String> sectionTitles) {
    return Container(
      height: 70.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sectionTitles.length.clamp(0, _visualSections.length),
        itemBuilder: (context, index) {
          final title = sectionTitles[index];
          final visual = _visualSections[index];
          final isActive = _activeSection == index;

          return GestureDetector(
            onTap: () {
              if (widget.sliverMode) {
                setState(() => _activeSection = index);
              } else {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isActive ? 120.w : 100.w,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                gradient: isActive ? kAccentGradient : null,
                borderRadius: BorderRadius.circular(14.r),
                border: isActive ? null : Border.all(color: Colors.white24),
                boxShadow: isActive
                    ? [
                  BoxShadow(
                    color: visual.color.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    visual.icon,
                    color: isActive ? Colors.white : Colors.white54,
                    size: 18.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    title,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontSize: 13.sp,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }




    Widget _buildClinicalCard({
    required String title,
    required Widget content,
    required IconData icon,
    required Color color,
    }) {
    return Padding(
    padding: EdgeInsets.only(bottom: 16.h),
    child: NeoCard(
    padding: EdgeInsets.all(16.w),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    _neoSectionHeader(title: title, icon: icon),
    SizedBox(height: 12.h),
    content,
    ],
    ),
    ),
    );
    }





// === Inserted helpers and sections to restore functionality ===

    Widget _neoSectionHeader({required String title, required IconData icon}) {
    return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    Container(
    height: 24.h,
    width: 4.w,
    decoration: BoxDecoration(
    gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
    borderRadius: BorderRadius.circular(4.r),
    ),
    ),
    SizedBox(width: 10.w),
    Expanded(
    child: Text(
    title,
    style: TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.2,
    ),
    ),
    ),
    Container(
    height: 34.h,
    width: 34.h,
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.08),
    borderRadius: BorderRadius.circular(10.r),
    border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
    ),
    child: Icon(icon, size: 18.sp, color: Colors.white),
    ),
    ],
    );
    }

    Widget _buildNeuralProfile() {
    final spectralTitle = _ui('card_spectral_power');
    final coherenceTitle = _ui('card_hemispheric_coherence');
    final asymTitle = _ui('card_interhemispheric_asymmetry');
    final interpretationTitle = _ui('card_neural_interpretation');

    final hasWaveValues = neuralPatterns.isNotEmpty &&
    (neuralPatterns.containsKey('delta') ||
    neuralPatterns.containsKey('theta') ||
    neuralPatterns.containsKey('alpha') ||
    neuralPatterns.containsKey('beta') ||
    neuralPatterns.containsKey('gamma'));

    final coherence = neuralPatterns['coherence'];
    final asym = neuralPatterns['asymmetry'];

    final anyVisible = (spectralTitle != null && hasWaveValues) ||
    (coherenceTitle != null && coherence is Map && coherence.isNotEmpty) ||
    (asymTitle != null && asym is Map && asym.isNotEmpty) ||
    (interpretationTitle != null && clinicalInterpretation.isNotEmpty);

    if (!anyVisible) {
    return Center(
    child: Text(
    'No neural data available',
    style: TextStyle(fontSize: 16.sp, color: Colors.white70),
    ),
    );
    }

    return Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    if (_ui('section_quantitative_eeg') != null)
    _buildSectionHeader(_ui('section_quantitative_eeg')!),

    SizedBox(height: 16.h),
    Text(
    "EEG patterns during sleep reveal how your brain processes information. Each frequency band corresponds "
    "to different cognitive functions and emotional regulation processes.",
    style: TextStyle(fontSize: 14.sp, color: Colors.white70),
    ),
    SizedBox(height: 24.h),

    if (spectralTitle != null && hasWaveValues)
    _buildClinicalCard(
    title: spectralTitle!,
    content: Column(
    children: [
    SizedBox(height: 220.h, child: _buildEEGBarChart()),
    SizedBox(height: 16.h),
    _buildEEGLegend(),
    SizedBox(height: 16.h),
    Text(
    "Delta waves (0.5-4Hz) dominate deep sleep. Theta waves (4-8Hz) enhance during REM and correlate "
    "with dream intensity. Alpha waves (8-12Hz) indicate relaxed awareness between sleep stages.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.auto_graph,
    color: Colors.blue,
    ),

    if (coherenceTitle != null && coherence is Map && coherence.isNotEmpty)
    _buildClinicalCard(
    title: coherenceTitle!,
    content: Column(
    children: [
    Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
    if (coherence.containsKey('frontal') && _hasDouble(coherence['frontal']))
    _buildBrainRegion("Frontal", coherence['frontal']),
    if (coherence.containsKey('temporal') && _hasDouble(coherence['temporal']))
    _buildBrainRegion("Temporal", coherence['temporal']),
    if (coherence.containsKey('occipital') && _hasDouble(coherence['occipital']))
    _buildBrainRegion("Occipital", coherence['occipital']),
    ],
    ),
    ),
    SizedBox(height: 16.h),
    Text(
    "Frontal coherence measures executive function integration. Temporal coherence relates to memory "
    "consolidation. Values above 0.7 indicate optimal neural network integration.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.bubble_chart,
    color: Colors.purple,
    ),
    if (asymTitle != null && asym is Map && asym.isNotEmpty)
    _buildClinicalCard(
    title: asymTitle!,
    content: Column(
    children: [
    Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
    if (asym.containsKey('alpha_frontal') && _hasDouble(asym['alpha_frontal']))
    _buildAsymmetryIndicator("Alpha Frontal", asym['alpha_frontal']),
    if (asym.containsKey('beta_parietal') && _hasDouble(asym['beta_parietal']))
    _buildAsymmetryIndicator("Beta Parietal", asym['beta_parietal']),
    ],
    ),
    ),
    SizedBox(height: 16.h),
    Text(
    "Frontal alpha asymmetry indicates emotional processing style. Left dominance correlates with "
    "positive affect, while right dominance suggests negative emotional processing.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.compare_arrows,
    color: Colors.teal,
    ),
    if (interpretationTitle != null && clinicalInterpretation.isNotEmpty)
    _buildClinicalCard(
    title: interpretationTitle!,
    content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    ...clinicalInterpretation.entries.map((e) {
    if (e.value == null) return const SizedBox.shrink();
    return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Text(
    "${e.key}: ${e.value}",
    style: TextStyle(fontSize: 16.sp, color: Colors.white70),
    ),
    );
    }).toList(),
    SizedBox(height: 16.h),
    Text(
    "Neural interpretations correlate EEG patterns with psychological functions. High frontal theta "
    "suggests emotional processing, while parietal beta indicates cognitive activation during sleep.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.psychology,
    color: Colors.amber,
    ),
    ],
    ),
    );
    }

    Widget _buildSleepArchitecture() {
    final stageTitle = _ui('card_sleep_stage_distribution');
    final metricsTitle = _ui('card_architecture_metrics');
    final interpTitle = _ui('card_architecture_interpretation');

    final arch = sleepArchitecture;
    final rem = arch['rem_percent'];
    final n3 = arch['n3_percent'];
    final hasStageNumbers = _hasDouble(rem) && _hasDouble(n3);

    final anyVisible = (stageTitle != null && hasStageNumbers) ||
    (metricsTitle != null && arch.isNotEmpty) ||
    (interpTitle != null && arch['interpretation'] != null);

    if (!anyVisible) {
    return Center(
    child: Text(
    'No sleep architecture data available',
    style: TextStyle(fontSize: 16.sp, color: Colors.white70),
    ),
    );
    }

    return Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    if (_ui('section_sleep_architecture') != null)
    _buildSectionHeader(_ui('section_sleep_architecture')!),

    SizedBox(height: 16.h),
    Text(
    "Healthy sleep cycles through multiple stages 4-5 times per night. Each stage serves different "
    "restorative functions, with REM being crucial for emotional processing and memory consolidation.",
    style: TextStyle(fontSize: 14.sp, color: Colors.white70),
    ),
    SizedBox(height: 24.h),

    if (stageTitle != null && hasStageNumbers)
    _buildClinicalCard(
    title: stageTitle!,
    content: Column(
    children: [
    SizedBox(height: 220.h, child: _buildSleepStagePieChart()),
    SizedBox(height: 16.h),
    Text(
    "REM sleep (20-25% of total) is when most dreaming occurs. Deep N3 sleep (15-20%) is essential for "
    "physical restoration. Light sleep (N1/N2) makes up the remaining 55-65% of healthy sleep architecture.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.pie_chart,
    color: Colors.teal,
    ),
    if (metricsTitle != null)
    _buildClinicalCard(
    title: metricsTitle!,
    content: Column(
    children: [
    ...arch.entries.map((e) {
    if (e.value == null) return const SizedBox.shrink();
    return _buildArchitectureMetric(e.key, e.value);
    }).toList(),
    SizedBox(height: 16.h),
    Text(
    "Sleep efficiency above 85% is optimal. REM latency between 70-110 minutes indicates healthy "
    "circadian rhythm. Frequent awakenings reduce sleep quality and dream recall.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.timeline,
    color: Colors.blue,
    ),
    if (interpTitle != null && arch['interpretation'] != null)
    _buildClinicalCard(
    title: interpTitle!,
    content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    arch['interpretation'].toString(),
    style: TextStyle(fontSize: 16.sp, color: Colors.white70),
    ),
    SizedBox(height: 16.h),
    Text(
    "Architecture interpretation considers stage transitions and duration. Fragmented REM reduces "
    "emotional processing, while insufficient deep sleep impairs physical recovery.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.medical_information,
    color: Colors.purple,
    ),
    ],
    ),
    );
    }

    Widget _buildEmotionalProcessing() {
    final epiTitle = _ui('card_emotional_processing_index');
    final threatTitle = _ui('card_threat_simulation');

    final epi = clinicalInterpretation['emotional_processing_index'];
    final threat = clinicalInterpretation['threat_simulation'];

    final anyVisible = (epiTitle != null && epi != null) ||
    (threatTitle != null && threat != null) ||
    (clinicalInterpretation.isNotEmpty && _ui('card_emotional_details') != null);

    if (!anyVisible) {
    return Center(
    child: Text(
    'No emotional processing data available',
    style: TextStyle(fontSize: 16.sp, color: Colors.white70),
    ),
    );
    }

    return Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    if (_ui('section_emotional_processing') != null)
    _buildSectionHeader(_ui('section_emotional_processing')!),

    SizedBox(height: 16.h),
    Text(
    "Dreams serve as overnight therapy, helping process emotional experiences. The limbic system activates "
    "during REM sleep to regulate emotional memories without the stress hormones of waking consciousness.",
    style: TextStyle(fontSize: 14.sp, color: Colors.white70),
    ),
    SizedBox(height: 24.h),

    if (epiTitle != null && epi != null)
    _buildClinicalCard(
    title: epiTitle!,
    content: Column(
    children: [
    Center(
    child: Text(
    epi.toString(),
    style: TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    ),
    ),
    ),
    SizedBox(height: 16.h),
    Text(
    "Emotional Processing Index (EPI) measures amygdala-hippocampal communication efficiency. "
    "Scores above 75 indicate effective emotional resolution, while below 50 suggests unresolved distress.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.emoji_emotions,
    color: Colors.pink,
    ),
    if (threatTitle != null && threat != null)
    _buildClinicalCard(
    title: threatTitle!,
    content: Column(
    children: [
    _buildThreatIndicator("Threat Simulation", threat),
    SizedBox(height: 16.h),
    Text(
    "Threat simulation activates the amygdala during REM sleep. Moderate levels help prepare for "
    "real-world challenges, while high levels may indicate unresolved anxiety or trauma.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.warning,
    color: Colors.orange,
    ),
    if (_ui('card_emotional_details') != null && clinicalInterpretation.isNotEmpty)
    _buildClinicalCard(
    title: _ui('card_emotional_details')!,
    content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    ...clinicalInterpretation.entries.map((e) {
    if (e.value == null) return const SizedBox.shrink();
    return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Text(
    "${e.key}: ${e.value}",
    style: TextStyle(fontSize: 16.sp, color: Colors.white70),
    ),
    );
    }).toList(),
    SizedBox(height: 16.h),
    Text(
    "Emotional details reflect how your brain processes daily experiences during sleep. Positive "
    "valence dreams help reinforce rewarding experiences, while negative dreams facilitate coping.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.info,
    color: Colors.blueGrey,
    ),
    ],
    ),
    );
    }

    Widget _buildCognitiveInsights() {
    final cognition = cognitiveAssessment;

    final validMetrics = [
    'problem_solving_index',
    'emotional_insight_index',
    'memory_consolidation_index',
    'creative_processing_index',
    'threat_processing_index'
    ];

    final hasCognitionMetrics = validMetrics.any((metric) =>
    cognition.containsKey(metric) && cognition[metric] != null
    );

    final hasExplanation = cognition['explanation'] != null;

    final anyVisible = hasCognitionMetrics || hasExplanation;

    if (!anyVisible) {
    return Center(
    child: Text(
    'No cognitive insights available',
    style: TextStyle(fontSize: 16.sp, color: Colors.white70),
    ),
    );
    }

    return Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    if (_ui('section_cognitive_assessment') != null)
    _buildSectionHeader(_ui('section_cognitive_assessment')!),

    SizedBox(height: 16.h),
    Text(
    "Sleep enhances cognitive functions through synaptic pruning and memory consolidation. REM sleep "
    "strengthens procedural memories while deep sleep consolidates declarative memories.",
    style: TextStyle(fontSize: 14.sp, color: Colors.white70),
    ),
    SizedBox(height: 24.h),

    if (hasCognitionMetrics)
    _buildClinicalCard(
    title: _ui('card_cognitive_performance') ?? 'Cognitive Performance',
    content: Column(
    children: [
    SizedBox(height: 220.h, child: _buildCognitiveRadarChart()),
    SizedBox(height: 16.h),
    Text(
    "The cognitive radar shows relative strengths across key domains. Optimal problem-solving requires "
    "balanced prefrontal activation. Creativity benefits from high frontal-theta coherence during REM sleep.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.psychology,
    color: Colors.amber,
    ),

    if (cognition.isNotEmpty)
    _buildClinicalCard(
    title: _ui('card_key_cognitive_metrics') ?? 'Key Cognitive Metrics',
    content: Column(
    children: [
    ...cognition.entries.where((e) =>
    e.value != null && validMetrics.contains(e.key)
    ).map((e) => _buildCognitiveMetric(e.key, e.value)).toList(),

    if (cognition.entries.where((e) =>
    e.value != null && validMetrics.contains(e.key)).isEmpty)
    Text(
    'No measurable cognitive metrics available',
    style: TextStyle(fontSize: 14.sp, color: Colors.white70),
    ),

    SizedBox(height: 16.h),
    Text(
    "Cognitive metrics reflect neural efficiency during sleep. Scores above 75 are optimal, 50-75 "
    "indicate average performance, and below 50 suggest potential areas for improvement.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.analytics,
    color: Colors.blue,
    ),

    if (hasExplanation)
    _buildClinicalCard(
    title: _ui('card_cognitive_interpretation') ?? 'Cognitive Interpretation',
    content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    cognition['explanation'].toString(),
    style: TextStyle(fontSize: 16.sp, color: Colors.white70),
    ),
    SizedBox(height: 16.h),
    Text(
    "Cognitive interpretation connects sleep architecture with daytime functioning. High REM density "
    "enhances creative problem-solving, while deep sleep improves factual memory consolidation.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.lightbulb,
    color: Colors.purple,
    ),
    ],
    ),
    );
    }

    Widget _buildClinicalRecommendations() {
    final recTitle = _ui('card_recommendations');
    final personalTitle = _ui('card_personalized_analysis');
    final recs = _prefList('recommendations');
    final dreamType = _apiString(dreamPrediction, 'prediction');
    final mood = _apiString(moodForecast, 'mood');

    final anyVisible = (recTitle != null && recs.isNotEmpty) ||
    (personalTitle != null && (dreamType != null || mood != null));

    if (!anyVisible) {
    return Center(
    child: Text(
    'No clinical recommendations available',
    style: TextStyle(fontSize: 16.sp, color: Colors.white70),
    ),
    );
    }

    return Padding(
    padding: EdgeInsets.all(16.w),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    if (_ui('section_recommendations') != null)
    _buildSectionHeader(_ui('section_recommendations')!),

    SizedBox(height: 16.h),
    Text(
    "These personalized recommendations are based on your unique sleep architecture and neural patterns. "
    "Implementing these can enhance dream recall, emotional processing, and overall sleep quality.",
    style: TextStyle(fontSize: 14.sp, color: Colors.white70),
    ),
    SizedBox(height: 24.h),

    if (recTitle != null && recs.isNotEmpty)
    _buildClinicalCard(
    title: recTitle!,
    content: Column(
    children: [
    ...recs.map((r) {
    if (r == null) return const SizedBox.shrink();
    if (r is String && r.isNotEmpty) {
    return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Icon(Icons.check_circle, color: Colors.green[300], size: 18.r),
    SizedBox(width: 8.w),
    Expanded(
    child: Text(
    r,
    style: TextStyle(
    fontSize: 15.sp,
    color: Colors.white70,
    height: 1.4,
    ),
    ),
    ),
    ],
    ),
    );
    }
    if (r is Map) {
    final t = r['title']?.toString();
    final d = r['description']?.toString();
    if (t == null && d == null) return const SizedBox.shrink();
    return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    if (t != null)
    Row(
    children: [
    Icon(Icons.star, color: Colors.amber, size: 16.r),
    SizedBox(width: 8.w),
    Text(
    t,
    style: TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 16.sp,
    ),
    ),
    ],
    ),
    if (d != null) SizedBox(height: 4.h),
    if (d != null)
    Padding(
    padding: EdgeInsets.only(left: 24.w),
    child: Text(
    d,
    style: TextStyle(
    color: Colors.white70,
    fontSize: 14.sp,
    ),
    ),
    ),
    ],
    ),
    );
    }
    return const SizedBox.shrink();
    }).toList(),
    SizedBox(height: 16.h),
    Text(
    "Recommendations are generated using clinical sleep research. Consistency is key - most techniques "
    "require 2-4 weeks of regular practice to significantly impact sleep architecture and dream content.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.list_alt,
    color: Colors.green,
    ),
    if (personalTitle != null && (dreamType != null || mood != null))
    _buildClinicalCard(
    title: personalTitle!,
    content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    if (dreamType != null)
    Text(
    dreamType,
    style: TextStyle(fontSize: 16.sp, color: Colors.white70),
    ),
    if (mood != null) SizedBox(height: 8.h),
    if (mood != null)
    Text(
    mood,
    style: TextStyle(fontSize: 16.sp, color: Colors.white70),
    ),
    SizedBox(height: 16.h),
    Text(
    "Your personalized analysis considers both dream content and emotional tone. Combining these "
    "factors provides unique insights into your subconscious processing during sleep.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.person,
    color: Colors.purple,
    ),
    ],
    ),
    );
    }

    void _exportClinicalReport() {
    final action = _ui('export_action');
    if (action != null) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
    content: Text(action),
    backgroundColor: Colors.green,
    ),
    );
    }
    }



// === Inserted missing helper widgets (restored) ===

// Compatibility wrapper to keep old calls working while using the new unified Neo header.

    Widget _buildSectionHeader(String title, [IconData icon = Icons.auto_awesome]) {
    return _neoSectionHeader(title: title, icon: icon);
    }


    Widget _buildEEGBarChart() {
    final waves = <String, double>{};
    if (_hasDouble(neuralPatterns['delta'])) waves['Delta'] = _apiDouble(neuralPatterns['delta'])!;
    if (_hasDouble(neuralPatterns['theta'])) waves['Theta'] = _apiDouble(neuralPatterns['theta'])!;
    if (_hasDouble(neuralPatterns['alpha'])) waves['Alpha'] = _apiDouble(neuralPatterns['alpha'])!;
    if (_hasDouble(neuralPatterns['beta'])) waves['Beta'] = _apiDouble(neuralPatterns['beta'])!;
    if (_hasDouble(neuralPatterns['gamma'])) waves['Gamma'] = _apiDouble(neuralPatterns['gamma'])!;

    if (waves.isEmpty) return const SizedBox.shrink();

    final entries = waves.entries.toList();
    return BarChart(
    BarChartData(
    alignment: BarChartAlignment.spaceAround,
    barTouchData: BarTouchData(enabled: false),
    titlesData: FlTitlesData(
    bottomTitles: AxisTitles(
    sideTitles: SideTitles(
    showTitles: true,
    getTitlesWidget: (value, meta) {
    final idx = value.toInt();
    if (idx >= 0 && idx < entries.length) {
    return Padding(
    padding: EdgeInsets.only(top: 8.h),
    child: Text(
    entries[idx].key,
    style: TextStyle(color: Colors.white70, fontSize: 12.sp),
    ),
    );
    }
    return const SizedBox.shrink();
    },
    ),
    ),
    leftTitles: AxisTitles(
    sideTitles: SideTitles(
    showTitles: true,
    getTitlesWidget: (value, meta) => Text(
    value.toInt().toString(),
    style: TextStyle(color: Colors.white70, fontSize: 10.sp),
    ),
    reservedSize: 40.w,
    ),
    ),
    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    ),
    gridData: FlGridData(
    show: true,
    drawVerticalLine: false,
    getDrawingHorizontalLine: (v) => FlLine(
    color: Colors.blueGrey[800]!,
    strokeWidth: 1,
    ),
    ),
    borderData: FlBorderData(show: false),
    barGroups: List.generate(entries.length, (i) {
    final entry = entries[i];
    return BarChartGroupData(
    x: i,
    barRods: [
    BarChartRodData(
    toY: entry.value,
    color: _getWaveColor(entry.key),
    width: 22.w,
    borderRadius: BorderRadius.circular(4.r),
    ),
    ],
    );
    }),
    ),
    );
    }

    Widget _buildEEGLegend() {
    return Wrap(
    spacing: 16.w,
    runSpacing: 8.h,
    children: [
    _buildLegendItem('Delta', _getWaveColor('Delta')),
    _buildLegendItem('Theta', _getWaveColor('Theta')),
    _buildLegendItem('Alpha', _getWaveColor('Alpha')),
    _buildLegendItem('Beta', _getWaveColor('Beta')),
    _buildLegendItem('Gamma', _getWaveColor('Gamma')),
    ],
    );
    }

    Widget _buildBrainRegion(String region, dynamic value) {
    if (!_hasDouble(value)) return const SizedBox.shrink();
    final numValue = _apiDouble(value)!;
    return Column(
    children: [
    Text(region, style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
    SizedBox(height: 8.h),
    Stack(
    alignment: Alignment.center,
    children: [
    SizedBox(
    width: 80.w,
    height: 80.h,
    child: CircularProgressIndicator(
    value: numValue.clamp(0.0, 1.0),
    strokeWidth: 8.w,
    backgroundColor: Colors.blueGrey[800],
    color: _getCoherenceColor(numValue),
    ),
    ),
    Text(
    numValue.toStringAsFixed(2),
    style: TextStyle(fontSize: 12.sp, color: Colors.white),
    ),
    ],
    ),
    ],
    );
    }

    Widget _buildAsymmetryIndicator(String label, dynamic value) {
    if (!_hasDouble(value)) return const SizedBox.shrink();
    final numValue = _apiDouble(value)!;
    return Column(
    children: [
    Text(label, style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
    SizedBox(height: 12.h),
    Container(
    width: 120.w,
    height: 40.h,
    decoration: BoxDecoration(
    color: Colors.blueGrey[800],
    borderRadius: BorderRadius.circular(20.r),
    ),
    child: Center(
    child: Text(
    numValue.toStringAsFixed(3),
    style: TextStyle(color: Colors.white),
    ),
    ),
    ),
    ],
    );
    }

    Widget _buildSleepStagePieChart() {
    final rem = sleepArchitecture['rem_percent'];
    final n3 = sleepArchitecture['n3_percent'];
    final light = sleepArchitecture['light_percent'];

    if (!_hasDouble(rem) || !_hasDouble(n3) || !_hasDouble(light)) {
    return Center(
    child: Text(
    'Incomplete sleep stage data',
    style: TextStyle(fontSize: 14.sp, color: Colors.white70),
    ),
    );
    }

    final remD = _apiDouble(rem)!;
    final n3D = _apiDouble(n3)!;
    final lightD = _apiDouble(light)!;

    // Normalize percentages to sum to 100
    final total = remD + n3D + lightD;
    final normalizedRem = (remD / total) * 100;
    final normalizedN3 = (n3D / total) * 100;
    final normalizedLight = (lightD / total) * 100;

    final sections = <PieChartSectionData>[
    PieChartSectionData(
    value: normalizedRem,
    color: _getStageColor('REM'),
    radius: 60.r,
    title: '${normalizedRem.toStringAsFixed(1)}%',
    titleStyle: TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    ),
    ),
    PieChartSectionData(
    value: normalizedN3,
    color: _getStageColor('N3'),
    radius: 60.r,
    title: '${normalizedN3.toStringAsFixed(1)}%',
    titleStyle: TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    ),
    ),
    PieChartSectionData(
    value: normalizedLight,
    color: _getStageColor('Light'),
    radius: 60.r,
    title: '${normalizedLight.toStringAsFixed(1)}%',
    titleStyle: TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    ),
    ),
    ];

    return PieChart(
    PieChartData(
    sections: sections,
    centerSpaceRadius: 40.r,
    sectionsSpace: 0,
    pieTouchData: PieTouchData(
    touchCallback: (FlTouchEvent event, pieTouchResponse) {},
    ),
    ),
    );
    }

    Widget _buildArchitectureMetric(String label, dynamic value) {
    if (value == null) return const SizedBox.shrink();
    return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    label,
    style: TextStyle(
    color: Colors.white70,
    fontSize: 14.sp,
    ),
    ),
    SizedBox(height: 4.h),
    Row(
    children: [
    Expanded(
    child: Container(
    height: 300,
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
    decoration: BoxDecoration(
    color: Colors.blueGrey[800],
    borderRadius: BorderRadius.circular(20.r),
    ),
    child: Text(
    value.toString(),
    style: TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    ),
    ),
    ),
    ),
    ],
    ),
    ],
    ),
    );
    }

    Widget _buildThreatIndicator(String label, dynamic value) {
    if (value == null) return const SizedBox.shrink();
    return Row(
    children: [
    Container(
    width: 24.w,
    height: 24.h,
    decoration: BoxDecoration(
    color: Colors.blueGrey,
    shape: BoxShape.circle,
    ),
    ),
    SizedBox(width: 12.w),
    Text(
    "$label: ${value.toString()}",
    style: TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white70,
    ),
    ),
    ],
    );
    }

    Widget _buildCognitiveRadarChart() {
    final c = cognitiveAssessment;
    final validMetrics = [
    'problem_solving_index',
    'emotional_insight_index',
    'memory_consolidation_index',
    'creative_processing_index',
    'threat_processing_index'
    ];
    final entries = validMetrics
        .where((metric) => _hasDouble(c[metric]))
        .map((metric) => MapEntry(metric, _apiDouble(c[metric])!))
        .toList();

    if (entries.isEmpty) {
    return Center(
    child: Text(
    'No cognitive metrics available',
    style: TextStyle(fontSize: 14.sp, color: Colors.white70),
    ),
    );
    }

    return RadarChart(
    RadarChartData(
    dataSets: [
    RadarDataSet(
    dataEntries: entries.map((e) => RadarEntry(value: e.value)).toList(),
    fillColor: Colors.purple.withOpacity(0.3),
    borderColor: Colors.purple,
    borderWidth: 2.w,
    ),
    ],
    radarShape: RadarShape.polygon,
    radarBorderData: BorderSide(
    color: Colors.blueGrey[700]!,
    width: 1.w,
    ),
    tickCount: 4,
    ticksTextStyle: TextStyle(color: Colors.transparent, fontSize: 10.sp),
    radarBackgroundColor: Colors.transparent,
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 12.sp),
    getTitle: (index, angle) {
    final titles = [
    "Problem Solving",
    "Emotional Insight",
    "Memory",
    "Creativity",
    "Threat Processing"
    ];
    if (index < titles.length) {
    return RadarChartTitle(
    text: titles[index],
    angle: angle,
    positionPercentageOffset: 0.1,
    );
    }
    return const RadarChartTitle(text: "");
    },
    titlePositionPercentageOffset: 0.15,
    ),
    );
    }

    Widget _buildCognitiveMetric(String label, dynamic value) {
    if (value == null) return const SizedBox.shrink();
    final friendlyNames = {
    'problem_solving_index': 'Problem Solving',
    'emotional_insight_index': 'Emotional Insight',
    'memory_consolidation_index': 'Memory Consolidation',
    'creative_processing_index': 'Creative Processing',
    'threat_processing_index': 'Threat Processing',
    };
    final hasNum = _hasDouble(value);

    return Padding(
    padding: EdgeInsets.symmetric(vertical: 8.h),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    Text(friendlyNames[label] ?? label, style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
    Text(value.toString(), style: TextStyle(color: Colors.white, fontSize: 14.sp)),
    ],
    ),
    SizedBox(height: 4.h),
    if (hasNum)
    LinearProgressIndicator(
    value: (_apiDouble(value)! / 100).clamp(0.0, 1.0),
    minHeight: 6.h,
    backgroundColor: Colors.blueGrey[800],
    color: _getCognitiveColor(_apiDouble(value)!.toInt()),
    ),
    ],
    ),
    );
    }


// === Inserted remaining helpers ===
    Widget _buildExecutiveSummary() {
    final title = _ui('card_primary_diagnosis');
    final affectTitle = _ui('card_affective_state');
    final keyNeuralTitle = _ui('card_key_neural_indicators');
    final impressionTitle = _ui('card_clinical_impression');
    final prediction = _apiString(dreamPrediction, 'prediction');
    final explanation = _apiString(dreamPrediction, 'explanation');
    final mood = _apiString(moodForecast, 'mood');
    final moodConfidence = _apiString(moodForecast, 'confidence');

    final anyData = dreamPrediction.isNotEmpty || moodForecast.isNotEmpty || clinicalInterpretation.isNotEmpty;

    if (!anyData) {
    return Center(
    child: Text(
    'No dream analysis data available',
    style: TextStyle(fontSize: 16.sp, color: Colors.white70),
    ),
    );
    }

    return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    if (_ui('section_clinical_dream_summary') != null)
    _buildSectionHeader(_ui('section_clinical_dream_summary')!),

    SizedBox(height: 16.h),
    Text(
    "Your dream patterns reveal important insights about your subconscious mind and emotional state. "
    "This analysis combines neuroscientific data with psychological interpretation.",
    style: TextStyle(fontSize: 14.sp, color: Colors.white70),
    ),
    SizedBox(height: 24.h),

    if (title != null && prediction != null)
    _buildClinicalCard(
    title: title!,
    content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    prediction!,
    style: TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: Colors.purple[300],
    height: 1.4,
    ),
    ),
    if (explanation != null) ...[
    SizedBox(height: 12.h),
    Text(
    explanation!,
    style: TextStyle(
    fontSize: 15.sp,
    color: Colors.white70,
    height: 1.5,
    ),
    ),
    ],
    SizedBox(height: 16.h),
    Text(
    "Dream prediction is based on EEG patterns during REM sleep. Vivid dreams correlate with "
    "increased theta wave activity in the prefrontal cortex, suggesting heightened emotional processing.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.nightlight_round,
    color: Colors.purple,
    ),

    if (affectTitle != null && (mood != null || moodConfidence != null))
    _buildClinicalCard(
    title: affectTitle!,
    content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    if (mood != null) ...[
    Row(
    children: [
    _buildMoodIndicator(mood!),
    SizedBox(width: 12.w),
    Expanded(
    child: Text(
    mood!,
    style: TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: _getMoodColor(mood!),
    ),
    ),
    ),
    ],
    ),
    SizedBox(height: 8.h),
    ],
    if (moodConfidence != null) ...[
    Text(
    "Confidence:",
    style: TextStyle(fontSize: 14.sp, color: Colors.white70),
    ),
    SizedBox(height: 4.h),
    LinearProgressIndicator(
    value: _parseConfidence(moodConfidence!),
    minHeight: 8.h,
    backgroundColor: Colors.blueGrey[800],
    color: Colors.green[400],
    borderRadius: BorderRadius.circular(4.r),
    ),
    SizedBox(height: 4.h),
    Text(
    "${(_parseConfidence(moodConfidence!) * 100).toStringAsFixed(1)}%",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54),
    textAlign: TextAlign.right,
    ),
    ],
    SizedBox(height: 16.h),
    Text(
    "Affective state is measured through amygdala activation patterns. Positive moods correlate with "
    "balanced interhemispheric communication, while negative moods show right hemisphere dominance.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.mood,
    color: Colors.pink,
    ),

    if (keyNeuralTitle != null && clinicalInterpretation.isNotEmpty)
    _buildClinicalCard(
    title: keyNeuralTitle!,
    content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    ...clinicalInterpretation.entries.map((e) {
    if (e.value == null) return const SizedBox.shrink();
    return _buildIndicatorRow(e.key, e.value);
    }).toList(),
    SizedBox(height: 16.h),
    Text(
    "Neural indicators measure communication between brain regions. High coherence values suggest "
    "efficient information transfer, while asymmetry indicates specialized hemispheric processing.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.bar_chart,
    color: Colors.blue,
    ),
    if (impressionTitle != null && explanation != null)
    _buildClinicalCard(
    title: impressionTitle!,
    content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    explanation!,
    style: TextStyle(fontSize: 16.sp, color: Colors.white70),
    ),
    SizedBox(height: 16.h),
    Text(
    "Clinical impressions integrate EEG patterns, sleep architecture, and emotional content to form "
    "a comprehensive understanding of your unique dream neurobiology.",
    style: TextStyle(fontSize: 12.sp, color: Colors.white54, fontStyle: FontStyle.italic),
    ),
    ],
    ),
    icon: Icons.assignment,
    color: Colors.teal,
    ),
    SizedBox(height: 16.h),
    if (_ui('view_technical') != null && _ui('hide_technical') != null)
    _buildTechnicalToggle(),
    if (_showTechnical) _buildTechnicalData(),
    ],
    );
    }

    Color _getWaveColor(String wave) {
    switch (wave) {
    case 'Delta': return Colors.purple[300]!;
    case 'Theta': return Colors.blue[300]!;
    case 'Alpha': return Colors.green[300]!;
    case 'Beta': return Colors.orange[300]!;
    case 'Gamma': return Colors.red[300]!;
    default: return Colors.grey;
    }
    }

    Widget _buildLegendItem(String label, Color color) {
    return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Container(
    width: 12.r,
    height: 12.r,
    decoration: BoxDecoration(
    color: color,
    shape: BoxShape.circle,
    ),
    ),
    SizedBox(width: 6.w),
    Text(
    label,
    style: TextStyle(fontSize: 12.sp, color: Colors.white70),
    ),
    ],
    );
    }

    Color _getCoherenceColor(double value) {
    if (value < 0.3) return Colors.red[300]!;
    if (value < 0.6) return Colors.orange[300]!;
    return Colors.green[300]!;
    }

    Color _getStageColor(String stage) {
    switch (stage) {
    case 'REM': return Colors.purple[300]!;
    case 'N3': return Colors.blue[300]!;
    case 'Light': return Colors.teal[300]!;
    default: return Colors.grey;
    }
    }

    Color _getCognitiveColor(int value) {
    if (value < 50) return Colors.red[300]!;
    if (value < 75) return Colors.orange[300]!;
    return Colors.green[300]!;
    }

// === Added: mood & technical helpers to resolve missing method errors ===

    /// Small circular mood indicator with an icon whose color reflects the mood.
    Widget _buildMoodIndicator(String mood) {
    final color = _getMoodColor(mood);
    IconData icon;
    final m = mood.toLowerCase().trim();
    if (m.contains('positive') || m.contains('happy') || m.contains('good') || m.contains('excited') || m.contains('optimistic')) {
    icon = Icons.mood;
    } else if (m.contains('neutral') || m.contains('ok')) {
    icon = Icons.sentiment_neutral;
    } else if (m.contains('calm') || m.contains('relaxed') || m.contains('peace')) {
    icon = Icons.sentiment_satisfied_alt;
    } else if (m.contains('anxious') || m.contains('stress') || m.contains('worried')) {
    icon = Icons.sentiment_dissatisfied;
    } else if (m.contains('negative') || m.contains('sad') || m.contains('bad') || m.contains('angry') || m.contains('fear')) {
    icon = Icons.mood_bad;
    } else {
    icon = Icons.psychology;
    }

    return Container(
    height: 28.h,
    width: 28.h,
    decoration: BoxDecoration(
    color: color.withOpacity(0.15),
    borderRadius: BorderRadius.circular(14.r),
    border: Border.all(color: color.withOpacity(0.6), width: 1.2),
    ),
    child: Icon(icon, size: 18.sp, color: color),
    );
    }

    /// Maps mood text to a consistent accent color used across the UI.
    Color _getMoodColor(String mood) {
    final m = mood.toLowerCase().trim();
    if (m.contains('positive') || m.contains('happy') || m.contains('good') || m.contains('excited') || m.contains('optimistic')) {
    return Colors.green[300]!;
    }
    if (m.contains('calm') || m.contains('relaxed') || m.contains('peace')) {
    return Colors.blue[300]!;
    }
    if (m.contains('neutral') || m == 'neutral') {
    return Colors.blueGrey[300]!;
    }
    if (m.contains('anxious') || m.contains('stress') || m.contains('worried')) {
    return Colors.orange[300]!;
    }
    if (m.contains('negative') || m.contains('sad') || m.contains('bad') || m.contains('angry') || m.contains('fear')) {
    return Colors.red[300]!;
    }
    return Colors.purple[300]!; // default accent
    }

    /// Parses confidence values like "0.76", "76%", "76 %", or "76" into 0..1.
    double _parseConfidence(String input) {
    final s = input.trim();
    final percentMatch = RegExp(r"([0-9]+(?:\.[0-9]+)?)\s*%").firstMatch(s);
    if (percentMatch != null) {
    final v = double.tryParse(percentMatch.group(1) ?? "");
    if (v != null) return (v / 100.0).clamp(0.0, 1.0);
    }
    // If plain number, attempt parse
    final v = double.tryParse(s);
    if (v != null) {
    if (v > 1.0) return (v / 100.0).clamp(0.0, 1.0);
    return v.clamp(0.0, 1.0);
    }
    // Fallback: extract first number in the string
    final anyNum = RegExp(r"([0-9]+(?:\.[0-9]+)?)").firstMatch(s);
    if (anyNum != null) {
    final v2 = double.tryParse(anyNum.group(1) ?? "0") ?? 0.0;
    if (s.contains('%') || v2 > 1.0) return (v2 / 100.0).clamp(0.0, 1.0);
    return v2.clamp(0.0, 1.0);
    }
    return 0.0;
    }

    /// Builds a labeled row. If the value is numeric (0..1), show a progress bar;
    /// otherwise render the value as text on the right.
    Widget _buildIndicatorRow(String label, dynamic value) {
    String prettyLabel = label.replaceAll('_', ' ')
        .replaceAll(RegExp(r"\s+"), ' ')
        .trim();
    if (prettyLabel.isNotEmpty) {
    prettyLabel = prettyLabel[0].toUpperCase() + prettyLabel.substring(1);
    }

    final hasNum = _hasDouble(value);
    final numVal = hasNum ? _apiDouble(value)! : null;
    final showBar = hasNum && numVal != null && numVal >= 0.0 && numVal <= 1.0;

    return Padding(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    Expanded(
    flex: 2,
    child: Text(
    prettyLabel,
    style: TextStyle(fontSize: 14.sp, color: Colors.white70, fontWeight: FontWeight.w500),
    overflow: TextOverflow.ellipsis,
    ),
    ),
    SizedBox(width: 12.w),
    if (showBar) ...[
    Expanded(
    flex: 3,
    child: ClipRRect(
    borderRadius: BorderRadius.circular(8.r),
    child: LinearProgressIndicator(
    value: numVal!.clamp(0.0, 1.0),
    minHeight: 6.h,
    backgroundColor: Colors.blueGrey[800],
    color: _getCoherenceColor(numVal),
    ),
    ),
    ),
    SizedBox(width: 8.w),
    Text(
    "${(numVal * 100).toStringAsFixed(0)}%",
    style: TextStyle(fontSize: 12.sp, color: Colors.white),
    ),
    ] else ...[
    Expanded(
    flex: 3,
    child: Align(
    alignment: Alignment.centerRight,
    child: Text(
    value?.toString() ?? '',
    style: TextStyle(fontSize: 14.sp, color: Colors.white70),
    textAlign: TextAlign.right,
    ),
    ),
    ),
    ],
    ],
    ),
    );
    }

    /// Toggle to show/hide the technical data view.
    Widget _buildTechnicalToggle() {
    final viewText = _ui('view_technical') ?? 'View Technical Data';
    final hideText = _ui('hide_technical') ?? 'Hide Technical Data';
    final label = _showTechnical ? hideText : viewText;

    return Align(
    alignment: Alignment.centerRight,
    child: TextButton.icon(
    onPressed: () => setState(() => _showTechnical = !_showTechnical),
    icon: Icon(Icons.science, size: 16.sp, color: Colors.white70),
    label: Text(
    label,
    style: TextStyle(fontSize: 13.sp, color: Colors.white70, fontWeight: FontWeight.w500),
    ),
    style: TextButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
    foregroundColor: Colors.white70,
    backgroundColor: Colors.white.withOpacity(0.04),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    ),
    ),
    );
    }

    /// Compact technical data card aggregating raw neural metrics for power users.
    Widget _buildTechnicalData() {
    final title = _ui('card_technical_data') ?? 'Technical Data';
    final waves = <String, double>{};
    if (_hasDouble(neuralPatterns['delta'])) waves['Delta'] = _apiDouble(neuralPatterns['delta'])!;
    if (_hasDouble(neuralPatterns['theta'])) waves['Theta'] = _apiDouble(neuralPatterns['theta'])!;
    if (_hasDouble(neuralPatterns['alpha'])) waves['Alpha'] = _apiDouble(neuralPatterns['alpha'])!;
    if (_hasDouble(neuralPatterns['beta'])) waves['Beta'] = _apiDouble(neuralPatterns['beta'])!;
    if (_hasDouble(neuralPatterns['gamma'])) waves['Gamma'] = _apiDouble(neuralPatterns['gamma'])!;

    final coherence = neuralPatterns['coherence'];
    final asym = neuralPatterns['asymmetry'];
    final moodConf = _apiString(moodForecast, 'confidence');

    return _buildClinicalCard(
    title: title,
    icon: Icons.science,
    color: Colors.blueGrey,
    content: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    if (moodConf != null) ...[
    Text('Mood confidence', style: TextStyle(fontSize: 13.sp, color: Colors.white70)),
    SizedBox(height: 6.h),
    ClipRRect(
    borderRadius: BorderRadius.circular(8.r),
    child: LinearProgressIndicator(
    value: _parseConfidence(moodConf).clamp(0.0, 1.0),
    minHeight: 6.h,
    backgroundColor: Colors.blueGrey[800],
    color: Colors.purple[300],
    ),
    ),
    SizedBox(height: 12.h),
    ],

    if (waves.isNotEmpty) ...[
    Text('Spectral power (a.u.)', style: TextStyle(fontSize: 13.sp, color: Colors.white70)),
    SizedBox(height: 8.h),
    Wrap(
    spacing: 10.w,
    runSpacing: 8.h,
    children: waves.entries.map((e) {
    return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.03),
    borderRadius: BorderRadius.circular(10.r),
    border: Border.all(color: _getWaveColor(e.key).withOpacity(0.5), width: 1),
    ),
    child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
    Container(height: 10.h, width: 10.h, decoration: BoxDecoration(color: _getWaveColor(e.key), shape: BoxShape.circle)),
    SizedBox(width: 8.w),
    Text('${e.key}: ${e.value.toStringAsFixed(2)}', style: TextStyle(fontSize: 12.sp, color: Colors.white)),
    ],
    ),
    );
    }).toList(),
    ),
    SizedBox(height: 12.h),
    ],

    if (coherence is Map && coherence.isNotEmpty) ...[
    Text('Coherence (0..1)', style: TextStyle(fontSize: 13.sp, color: Colors.white70)),
    SizedBox(height: 8.h),
    ...['frontal', 'temporal', 'occipital'].where((k) => (coherence as Map).containsKey(k)).map((k) {
    return _buildIndicatorRow(k, (coherence as Map)[k]);
    }).toList(),
    SizedBox(height: 8.h),
    ],

    if (asym is Map && asym.isNotEmpty) ...[
    Text('Asymmetry (signed)', style: TextStyle(fontSize: 13.sp, color: Colors.white70)),
    SizedBox(height: 8.h),
    ... (asym as Map).entries.map((e) => _buildIndicatorRow(e.key, e.value)).toList(),
    ],
    ],
    ),
    );
    }

    }

    class KeepAliveWrapper extends StatefulWidget {
    final Widget child;

    const KeepAliveWrapper({super.key, required this.child});

    @override
    State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
    }

    class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
    @override
    bool get wantKeepAlive => true;

    @override
    Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
    }
    }