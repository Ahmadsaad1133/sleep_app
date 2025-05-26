
import 'package:flutter/material.dart';
import 'package:first_flutter_app/views/home_page_7/home_page_7.dart';
import 'package:first_flutter_app/views/meditate_page/meditate_page.dart';
import 'package:first_flutter_app/views/music_page/music_page.dart';
import 'package:first_flutter_app/views/profile_page/profile_page.dart';
import 'package:first_flutter_app/views/home_page/home_page.dart';
import 'package:first_flutter_app/views/welcome_page/welcome_page.dart';
import 'package:first_flutter_app/views/sign_in/sign_in_page.dart';
import 'package:first_flutter_app/views/sign_up/sign_up_page.dart';
import 'package:first_flutter_app/views/choose_topic/choose_topic_page.dart';
import 'package:first_flutter_app/views/reminders/reminder_page.dart';

import 'package:first_flutter_app/widgets/navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/home',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(
              builder: (_) => const HomePage(),
              settings: settings,
            );

          case '/sign_in':
            return MaterialPageRoute(
              builder: (_) => const SignInPage(),
              settings: settings,
            );

          case '/sign_up':
            return MaterialPageRoute(
              builder: (_) => const SignUpPage(),
              settings: settings,
            );

          case '/choose_topic':
            return MaterialPageRoute(
              builder: (_) => const ChooseTopicPage(),
              settings: settings,
            );

          case '/reminders':
            return MaterialPageRoute(
              builder: (_) => const ReminderPage(),
              settings: settings,
            );

          case '/main':
          // allow passing an optional initialIndex (0–4)
            final args = settings.arguments;
            int initialIndex = 0;
            if (args is int && args >= 0 && args < 5) {
              initialIndex = args;
            }

            return MaterialPageRoute(
              builder: (_) => NavBarContainer(
                initialIndex: initialIndex,
                pages: const [
                  HomePage7(),
                  MeditatePage(),
                  SizedBox.shrink(),
                  MusicPage(),
                  ProfilePage(),
                ],
              ),
              settings: settings,
            );

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: const Text('Page Not Found')),
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
              settings: settings,
            );
        }
      },
    );
  }
}
