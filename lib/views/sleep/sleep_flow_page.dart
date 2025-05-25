import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SleepFlowPage extends StatefulWidget {
  final ValueChanged<bool> onNavbarVisibilityChange;

  const SleepFlowPage({
    Key? key,
    required this.onNavbarVisibilityChange,
  }) : super(key: key);

  @override
  _SleepFlowPageState createState() => _SleepFlowPageState();
}

class _SleepFlowPageState extends State<SleepFlowPage> {
  @override
  void initState() {
    super.initState();
    // Ensure the navbar is visible when entering the page
    widget.onNavbarVisibilityChange(true);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        'assets/images/sleepframe.png',
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        fit: BoxFit.cover,
      ),
    );
  }
}
