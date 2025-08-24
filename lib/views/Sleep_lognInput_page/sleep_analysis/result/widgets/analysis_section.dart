import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import '../../../../../constants/colors.dart';

class AnalysisSection extends StatefulWidget {
  final String detailedReport;
  final VoidCallback? onExpand;

  const AnalysisSection({
    Key? key,
    required this.detailedReport,
    this.onExpand,
  }) : super(key: key);

  @override
  State<AnalysisSection> createState() => _AnalysisSectionState();
}

class _AnalysisSectionState extends State<AnalysisSection>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  final double _collapsedHeight = 200;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        widget.onExpand?.call();
      } else {
        _controller.reverse();
      }

      // Scroll to top when expanding
      if (_isExpanded && _scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [Color(0x501A237E), Color(0x000A0E21)],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white30),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 8,
          )
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with proper tap handling
            _buildCosmicHeader(),
            const Divider(height: 1, color: Colors.white30),
            // Report content
            _buildReportContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildCosmicHeader() {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: _toggleExpanded,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Shimmer(
                duration: const Duration(seconds: 3),
                color: Colors.blueAccent.withOpacity(0.3),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    ),
                  ),
                  child: const Icon(
                    Icons.insights,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Shimmer(
                  duration: const Duration(seconds: 3),
                  color: Colors.blueAccent.withOpacity(0.2),
                  child: AutoSizeText(
                    'COSMIC SLEEP ANALYSIS',
                    maxLines: 1,
                    minFontSize: 16,
                    maxFontSize: 22,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.95),
                      fontFamily: 'NunitoSansBold',
                      letterSpacing: 1.8,
                      shadows: [
                        Shadow(
                          blurRadius: 12,
                          color: Colors.blueAccent.withOpacity(0.6),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * pi,
                    child: Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white,
                      size: 28,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportContent() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: _isExpanded ? double.infinity : _collapsedHeight,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          child: _ContentWrapper(
            isExpanded: _isExpanded,
            detailedReport: widget.detailedReport,
            scrollController: _scrollController,
            toggleExpanded: _toggleExpanded,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _ContentWrapper extends StatelessWidget {
  final bool isExpanded;
  final String detailedReport;
  final ScrollController scrollController;
  final VoidCallback toggleExpanded;

  const _ContentWrapper({
    required this.isExpanded,
    required this.detailedReport,
    required this.scrollController,
    required this.toggleExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Starry background
        Positioned.fill(
          child: CustomPaint(
            painter: _StarryBackgroundPainter(),
          ),
        ),

        // Scrollable content
        SingleChildScrollView(
          controller: scrollController,
          physics: isExpanded
              ? const BouncingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: MarkdownBody(
            data: detailedReport,
            styleSheet: _cosmicMarkdownStyle,
            selectable: true,
            imageBuilder: (uri, title, alt) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(uri.toString()),
              );
            },
          ),
        ),

        // Expand hint overlay with tap handling
        if (!isExpanded)
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: toggleExpanded,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        const Color(0xFF0A0E21).withOpacity(0.85),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Shimmer(
                          duration: const Duration(seconds: 2),
                          color: Colors.blueAccent.withOpacity(0.2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                )
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.unfold_more, color: Colors.white70),
                                SizedBox(width: 8),
                                Text(
                                  'Expand Full Analysis',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'NunitoSans',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  static final MarkdownStyleSheet _cosmicMarkdownStyle = MarkdownStyleSheet(
    p: TextStyle(
      color: Colors.white.withOpacity(0.85),
      height: 1.7,
      fontFamily: 'NunitoSans',
      fontSize: 16,
    ),
    h1: TextStyle(
      fontWeight: FontWeight.bold,
      color: AppColors.primaryPurple,
      fontFamily: 'NunitoSansBold',
      fontSize: 26,
      shadows: [
        Shadow(
          blurRadius: 15,
          color: AppColors.primaryPurple.withOpacity(0.4),
        )
      ],
    ),
    h2: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.cyanAccent,
      fontFamily: 'NunitoSansBold',
      fontSize: 22,
      shadows: [
        Shadow(
          blurRadius: 12,
          color: Colors.cyanAccent.withOpacity(0.4),
        )
      ],
    ),
    h3: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.amberAccent,
      fontFamily: 'NunitoSansBold',
      fontSize: 19,
      shadows: [
        Shadow(
          blurRadius: 10,
          color: Colors.amberAccent.withOpacity(0.4),
        )
      ],
    ),
    h4: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.lightGreenAccent,
      fontFamily: 'NunitoSansBold',
      fontSize: 17,
    ),
    listBullet: TextStyle(
      color: Colors.white.withOpacity(0.75),
      fontFamily: 'NunitoSans',
      fontSize: 16,
    ),
    em: TextStyle(
      fontStyle: FontStyle.italic,
      color: Colors.amberAccent,
      fontWeight: FontWeight.w500,
    ),
    strong: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.cyanAccent,
    ),
    blockquote: TextStyle(
      color: Colors.lightBlueAccent.withOpacity(0.9),
      fontStyle: FontStyle.italic,
      fontSize: 15,
    ),
    code: TextStyle(
      backgroundColor: Colors.black.withOpacity(0.3),
      color: Colors.lightGreenAccent,
      fontFamily: 'RobotoMono',
      fontSize: 14,
    ),
    tableBody: TextStyle(
      color: Colors.white.withOpacity(0.8),
    ),
    tableHead: TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.cyanAccent,
    ),
    tableBorder: TableBorder(
      horizontalInside: BorderSide(
        color: Colors.white30,
        width: 0.5,
      ),
      verticalInside: BorderSide(
        color: Colors.white30,
        width: 0.5,
      ),
    ),
  );
}

class _StarryBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    final paint = Paint()..color = Colors.white;
    final starCount = (size.width * size.height / 200).clamp(80, 200).toInt();

    // Draw twinkling stars
    for (int i = 0; i < starCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.8;
      final opacity = 0.2 + random.nextDouble() * 0.5;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = Colors.white.withOpacity(opacity),
      );
    }

    // Draw larger stars
    for (int i = 0; i < starCount ~/ 4; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1.0 + random.nextDouble() * 1.5;
      final opacity = 0.5 + random.nextDouble() * 0.5;
      final color = i % 3 == 0
          ? Colors.cyanAccent
          : i % 3 == 1
          ? Colors.amberAccent
          : Colors.lightBlueAccent;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint..color = color.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}