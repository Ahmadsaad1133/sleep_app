import 'package:flutter/material.dart';
import 'package:first_flutter_app/views/home_page_7/home_Page_7.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Just show HomePage7 immediately—no auth checks
    return const HomePage7();
  }
}
