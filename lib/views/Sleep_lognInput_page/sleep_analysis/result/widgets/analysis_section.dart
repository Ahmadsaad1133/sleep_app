import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

class _AnalysisSectionState extends State<AnalysisSection> {
  String _sanitizeReport(String input) {
    final text = input.trim();
    if (text.isEmpty) return "";
    // Hide JSON strings (valid JSON map/list)
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map || decoded is List) {
        return "";
      }
    } catch (_) {
      // Not valid JSON -> continue checks
    }
    // Hide common Map.toString() format like {key: value}
    final looksLikeMapToString = text.startsWith('{') && text.contains(':') && !text.contains('\"');
    if (looksLikeMapToString) {
      return "";
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    final textRaw = widget.detailedReport;
    final cleaned = _sanitizeReport(textRaw);
    final text = cleaned.isEmpty
        ? "_No detailed report available yet._"
        : cleaned;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: _glassTile(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  colors: [_neonA, _neonB, _neonC],
                ).createShader(rect),
                child: Text(
                  "Sleep Report",
                  style: TextStyle(
                    color: Colors.white, // masked
                    fontWeight: FontWeight.w800,
                    fontSize: 16.sp,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const Spacer(),
              if (widget.onExpand != null)
                IconButton(
                  onPressed: widget.onExpand,
                  tooltip: "Expand",
                  icon: const Icon(Icons.open_in_full, color: Colors.white70, size: 18),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(height: 1, color: Colors.white12),
          SizedBox(height: 12.h),
          MarkdownBody(
            data: text,
            selectable: false,
            styleSheet: _markdownStyle(context),
          ),
        ],
      ),
    );
  }

  MarkdownStyleSheet _markdownStyle(BuildContext context) {
    // Force a dark base to avoid any black text from inherited themes
    final base = MarkdownStyleSheet.fromTheme(
      ThemeData(
        brightness: Brightness.dark,
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 13.5.sp),
        ),
      ),
    );

    return base.copyWith(
      p: TextStyle(color: Colors.white70, fontSize: 13.5.sp, height: 1.5),
      a: TextStyle(color: _neonA.withOpacity(0.95), decoration: TextDecoration.underline),
      h1: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900),
      h2: TextStyle(color: Colors.white, fontSize: 16.5.sp, fontWeight: FontWeight.w800),
      h3: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700),
      strong: const TextStyle(color: Colors.white),
      em: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
      blockquote: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.white24, width: 3)),
        color: Colors.white.withOpacity(0.04),
      ),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 12.5.sp,
        color: Colors.cyanAccent.shade100,
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF0E1221).withOpacity(0.6),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white12),
      ),
      listBullet: TextStyle(color: Colors.white70, fontSize: 13.5.sp),
      horizontalRuleDecoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.transparent, Colors.white24, Colors.transparent],
        ),
      ),
      tableHead: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.sp),
      tableBody: TextStyle(color: Colors.white70, fontSize: 12.5.sp),
      tableBorder: TableBorder.all(color: Colors.white12, width: 1),
      tableCellsPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
    );
  }
}

// ---- Shared neon palette (local to this file to avoid extra deps) ----
const _neonA = Color(0xFF00E5FF);
const _neonB = Color(0xFF7C4DFF);
const _neonC = Color(0xFFFF4081);

// ---- Glass tile identical to other sections ----
BoxDecoration _glassTile() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(16.r),
    border: Border.all(color: Colors.white12),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.white54, Colors.white12],
      stops: [0.0, 1.0],
    ).scale(0.11),
  );
}
