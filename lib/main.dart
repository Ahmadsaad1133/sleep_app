// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ Add this
import 'package:first_flutter_app/splash_page/splash_page.dart';
import 'package:first_flutter_app/widgets/notifications.dart';
import 'app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Optional: Sign out any cached user on startup
  await FirebaseAuth.instance.signOut();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(412, 732), // ✅ Set your fixed design resolution
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Sleep Moon',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: const SplashPage(),
          onGenerateRoute: AppRouter.generateRoute,
          builder: (context, child) {
            return _InitNotifications(child: child!);
          },
        );
      },
    );
  }
}

class _InitNotifications extends StatefulWidget {
  final Widget child;
  const _InitNotifications({required this.child});

  @override
  State<_InitNotifications> createState() => _InitNotificationsState();
}

class _InitNotificationsState extends State<_InitNotifications> {
  @override
  void initState() {
    super.initState();
    initNotifications();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
