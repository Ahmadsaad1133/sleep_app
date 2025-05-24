
import 'package:flutter/material.dart';
import 'package:first_flutter_app/views/home_page/home_page.dart';
import 'package:first_flutter_app/views/sign_in/sign_in_page.dart';
import 'package:first_flutter_app/views/sign_up/sign_up_page.dart';
import 'package:first_flutter_app/views/welcome_page/welcome_page.dart';
import 'package:first_flutter_app/views/choose_topic/choose_topic_page.dart';
import 'package:first_flutter_app/views/reminders/reminder_page.dart';
import 'package:first_flutter_app/views/home_page_7/home_page_7.dart';
import 'package:first_flutter_app/views/meditate_page/meditate_page.dart';
import 'package:first_flutter_app/views/sleep_page/sleep_page.dart';
import 'package:first_flutter_app/widgets/navbar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',

      routes: {
        '/home':         (_) => const HomePage(),
        '/sign_in':      (_) => const SignInPage(),
        '/sign_up':      (_) => const SignUnPage(),
        '/welcome':      (_) => const WelcomePage(),
        '/choose_topic': (_) => const ChooseTopicPage(),
        '/reminders':    (_) => const ReminderPage(),
        '/tabs': (_) => const TabsContainer(),
      },
      initialRoute: '/home',
    );
  }
}
class TabsContainer extends StatelessWidget {
  const TabsContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navbarPages = <Widget>[
      const HomePage7(),
      const MeditatePage(),
      const SleepPage(),
    ];

    return NavBarContainer(
      pages: navbarPages,
      scale: 1.0,
    );
  }
}
