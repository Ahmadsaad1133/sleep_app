// lib/app_router.dart
import 'package:flutter/material.dart';
import 'routes.dart';
import 'views/home_page/page.dart';
import 'views/sign_in/page.dart';
import 'views/sign_up/page.dart';
import 'views/choose_topic/page.dart';
import 'views/reminders/page.dart';
import 'views/home_page_7/home_page_7.dart';
import 'views/meditate_page/page.dart';
import 'views/music_page/music_page.dart';
import 'views/profile_page/page.dart';
import 'widgets/navbar.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return _buildRoute(settings, const HomePage());
      case Routes.signIn:
        return _buildRoute(settings, const SignInPage());
      case Routes.signUp:
        return _buildRoute(settings, const SignUpPage());
      case Routes.chooseTopic:
        return _buildRoute(settings, const ChooseTopicPage());
      case Routes.reminders:
        return _buildRoute(settings, const ReminderPage());
      case Routes.mainNav:
        final args = settings.arguments;
        int initialIndex = (args is int && args >= 0 && args < 5) ? args : 0;
        return _buildRoute(
          settings,
          NavBarContainer(
            initialIndex: initialIndex,
            pages: const [
              HomePage7(),
              MeditatePage(),
              SizedBox.shrink(),
              MusicPage(),
              ProfilePage(),
            ],
          ),
        );
      default:
        return _buildRoute(
          settings,
          Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static MaterialPageRoute _buildRoute(RouteSettings settings, Widget child) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}
