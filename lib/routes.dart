// lib/routes.dart

import 'package:flutter/material.dart';
import 'package:first_flutter_app/views/night_island/page.dart';
import 'package:first_flutter_app/views/sleep_music/page.dart';
import 'package:first_flutter_app/views/sleep_page/page.dart';

abstract class Routes {
  static const String home        = '/home';
  static const String signIn      = '/sign_in';
  static const String signUp      = '/sign_up';
  static const String chooseTopic = '/choose_topic';
  static const String reminders   = '/reminders';
  static const String mainNav     = '/main';

  // ─────── Added for Sleep Shell ───────
  static const String sleep       = '/sleep';
  static const String nightIsland = '/night_island';
  static const String sleepMusic  = '/sleep_music';
  // ──────────────────────────────────────

  /// A map from route‐name → Widget builder function.
  ///
  /// Each builder gets a [ValueNotifier<bool> onNavbarVisibilityChange]
  /// so that pages can toggle the bottom navbar.
  static final Map<String, Widget Function(ValueNotifier<bool>)> sleepBuilders = {
    sleep: (notifier) => SleepPage(onNavbarVisibilityChange: notifier),
    nightIsland: (notifier) => NightIslandPage(onNavbarVisibilityChange: notifier),
    sleepMusic: (notifier) => SleepMusicPage(onNavbarVisibilityChange: notifier),
  };
}
