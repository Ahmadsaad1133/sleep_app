import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/constants/assets.dart';
import '/constants/sizes.dart';

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
    widget.onNavbarVisibilityChange(true);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SvgPicture.asset(
        AppAssets.sleepFrame,
        width: AppSizes.screenWidth(context),
        height: AppSizes.screenHeight(context),
        fit: AppSizes.sleepImageFit,
      ),
    );
  }
}
