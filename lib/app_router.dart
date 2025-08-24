// lib/app_router.dart
import 'package:first_flutter_app/views/chat_page/chat_page.dart';
import 'package:first_flutter_app/views/home_page/page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes.dart';
import 'views/home_page_7/home_page_7.dart';
import 'views/sign_in/page.dart';
import 'views/sign_up/page.dart';
import 'widgets/navbar.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    const publicRoutes = [
      Routes.signIn,
      Routes.signUp,
      Routes.home,
      Routes.mainNav,
    ];

    if (user == null && !publicRoutes.contains(settings.name)) {
      return _buildRoute(settings, const SignInPage());
    }

    if (user != null && publicRoutes.contains(settings.name)) {
      return _buildRoute(settings, const HomePage7());
    }

    switch (settings.name) {
      case Routes.home:
        return _buildRoute(settings, const HomePage());
      case Routes.home7:
        return _buildRoute(settings, const HomePage7());
      case Routes.signIn:
        return _buildRoute(settings, const SignInPage());
      case Routes.chat:
        return MaterialPageRoute(builder: (_) => const ChatPage());
      case Routes.signUp:
        return _buildRoute(settings, const SignUpPage());
      case Routes.mainNav:
        final args = settings.arguments;
        int initialIndex = (args is int && args >= 0 && args < 5) ? args : 0;
        return _buildRoute(
          settings,
          NavBarContainer(
            initialIndex: initialIndex,
            pages: const [
              HomePage7(),
              SizedBox.shrink(),
            ],
          ),
        );
      default:
        return _buildRoute(
          settings,
          Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Text('No route defined for \${settings.name}'),
            ),
          ),
        );
    }
  }

  static MaterialPageRoute _buildRoute(RouteSettings settings, Widget child) {
    return MaterialPageRoute(builder: (_) => child, settings: settings);
  }
}
