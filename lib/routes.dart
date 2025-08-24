// lib/routes.dart

import 'package:first_flutter_app/views/bedtime_page/bedtime_story_page.dart';
import 'package:flutter/material.dart';
abstract class Routes {
  static const String home            = '/home';
  static const String home7            = '/home';
  static const String chat            = '/chat';
  static const String sleepLoginput   = '/sleep_loginput';
  static const String signIn          = '/sign_in';
  static const String signUp          = '/sign_up';
  static const String mainNav         = '/main';

  // ─────── Sleep Shell ───────
  static const String bedtimeStory    = '/story';
  // ────────────────────────────

  /// Map from route‐name → Widget builder taking a Navbar‐visibility notifier.
  /// Pages that don’t use the notifier can just ignore it.
  static final Map<String, Widget Function(ValueNotifier<bool>)> sleepBuilders = {
    bedtimeStory: (_)       => const BedtimeStoryPage(),
  };
}
