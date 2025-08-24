import 'package:first_flutter_app/constants/fonts.dart';
import 'package:first_flutter_app/constants/colors.dart';
import 'package:first_flutter_app/constants/sizes.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/ai_chat_page.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_analysis/result/sleep_analysis_page.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleeplog_history_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/api/api_service.dart';

class AIChatPage extends StatefulWidget {
  final String? initialPrompt;
  const AIChatPage({Key? key, this.initialPrompt}) : super(key: key);

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      _sendInitialPrompt(widget.initialPrompt!);
    }
  }

  Future<void> _sendInitialPrompt(String input) async {
    setState(() => _isLoading = true);
    try {
      final logs = await _fetchRecentSleepLogs();
      final finalPrompt = _formatSleepLogPrompt(logs) + "\n\n" + input;
      final response = await ApiService.generateResponse(finalPrompt);
      setState(() => _messages.add({'role': 'assistant', 'content': response}));
      await _saveMessageToFirestore('assistant', response);
    } catch (e) {
      setState(() => _messages.add({'role': 'assistant', 'content': 'Error: $e'}));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitPrompt(String input) async {
    if (input.trim().isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'content': input});
      _isLoading = true;
    });
    _controller.clear();
    await _saveMessageToFirestore('user', input);

    try {
      String finalPrompt = input;
      if (_messages.where((m) => m['role'] == 'assistant').isEmpty) {
        final logs = await _fetchRecentSleepLogs();
        finalPrompt = _formatSleepLogPrompt(logs) + "\n\n" + input;
      }
      final response = await ApiService.generateResponse(finalPrompt);
      setState(() => _messages.add({'role': 'assistant', 'content': response}));
      await _saveMessageToFirestore('assistant', response);
    } catch (e) {
      setState(() => _messages.add({'role': 'assistant', 'content': 'Error: $e'}));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveMessageToFirestore(String role, String content) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('chat_history')
        .add({
      'role': role,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> _fetchRecentSleepLogs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('sleep_logs')
        .orderBy('date', descending: true)
        .limit(5)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  String _formatSleepLogPrompt(List<Map<String, dynamic>> logs) {
    if (logs.isEmpty) return "No sleep log data available.";
    final buf = StringBuffer("Here is my recent sleep history:\n");
    for (var log in logs) {
      final date = (log['date'] as Timestamp)
          .toDate()
          .toLocal()
          .toString()
          .split(' ')
          .first;
      buf.writeln(
          "- Date: $date, Bedtime: ${log['bedtime']}, Wake Time: ${log['wake_time']}, Quality: ${log['quality']}/10, Caffeine: ${log['caffeine_intake']}, Exercise: ${log['exercise']}, Screen Time: ${log['screen_time_before_bed']}");
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text(
          'AI Assistant',
          style: TextStyle(
            fontFamily: AppFonts.AirbnbCerealBook,
            letterSpacing: 1,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: Colors.black54),
            tooltip: 'Chat History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AnalysisHistoryPage()),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.pagePaddingH,
                    vertical: AppSizes.pagePaddingV,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius2),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: EdgeInsets.all(AppSizes.cardInnerPadding),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius:
                          BorderRadius.circular(AppSizes.cardBorderRadius2),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (ctx, i) {
                            final msg = _messages[i];
                            final isUser = msg['role'] == 'user';
                            return Align(
                              alignment:
                              isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical: AppSizes.contentSpacing / 2),
                                padding: EdgeInsets.all(AppSizes.contentSpacing),
                                decoration: BoxDecoration(
                                  gradient: isUser
                                      ? LinearGradient(
                                    colors: [
                                      AppColors.improvePerformance,
                                      AppColors.reduceStress
                                    ],
                                  )
                                      : LinearGradient(
                                    colors: [
                                      Colors.grey.shade200,
                                      Colors.grey.shade300
                                    ],
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(AppSizes.borderRadiusHigh),
                                ),
                                child: Text(
                                  msg['content'] ?? '',
                                  style: TextStyle(
                                    color: isUser ? Colors.white : Colors.black87,
                                    fontFamily: AppFonts.AirbnbCerealBook,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.contentSpacing),
                  child: CircularProgressIndicator(color: AppColors.reduceAnxiety),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePaddingH,
                  vertical: AppSizes.pagePaddingV,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius2),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.contentSpacing,
                          vertical: AppSizes.contentSpacing / 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius:
                        BorderRadius.circular(AppSizes.cardBorderRadius2),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              textInputAction: TextInputAction.send,
                              onSubmitted: _submitPrompt,
                              style: TextStyle(color: Colors.black87),
                              decoration: InputDecoration(
                                hintText: "Ask something…",
                                hintStyle:
                                TextStyle(color: Colors.black54, fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send, color: AppColors.reduceAnxiety),
                            onPressed: () => _submitPrompt(_controller.text),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
