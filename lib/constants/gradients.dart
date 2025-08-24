import 'package:flutter/material.dart';

const kBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color(0xFF0C1D40),
    Color(0xFF0F2A5B),
    Color(0xFF1A3A6F),
  ],
);

const kCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color.fromRGBO(255, 255, 255, 0.10), // white10
    Color.fromRGBO(255, 255, 255, 0.05), // white5
  ],
);

const kActiveCardGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color.fromRGBO(33, 150, 243, 0.12), // blueAccent12
    Color.fromRGBO(33, 150, 243, 0.08), // blueAccent8
  ],
);
