// ignore_for_file: prefer_const_constructors

import 'package:first_flutter_app/constants/fonts.dart';
import 'package:first_flutter_app/views/Sleep_lognInput_page/sleep_loginput/sleep_loginput_page_state.dart';
import 'package:first_flutter_app/views/home_page/page.dart';
import 'package:first_flutter_app/views/home_page_7/home_Page_7.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Firebase موجود
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 Pro Max as base size
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: AppFonts.AirbnbCerealBook, // ✅ الخط الجديد
          ),
          home: child,
        );
      },
      child: const HomePage(),
    );
  }
}
