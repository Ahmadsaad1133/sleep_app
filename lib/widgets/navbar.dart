// lib/widgets/navbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/nav_constants.dart';
import '../constants/colors.dart';
import '../constants/sizes.dart';
import 'package:first_flutter_app/views/sleep/flow_page.dart';

class CustomNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Color backgroundColor;
  final List<int> disabledIndices;

  const CustomNavbar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.disabledIndices = const [],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: AppSizes.navbarHeight,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            AppNavConstants.labels.length,
                (i) {
              final isSelected = i == selectedIndex;
              final isDisabled = disabledIndices.contains(i);

              return GestureDetector(
                onTap: () {
                  if (!isSelected && !isDisabled) {
                    onTap(i);
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: AppSizes.navbarCircleSize,
                      height: AppSizes.navbarCircleSize,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.navbarActive
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        AppNavConstants.iconPaths[i],
                        width: AppSizes.navbarIconSize,
                        height: AppSizes.navbarIconSize,
                        color: isSelected
                            ? Colors.white
                            : AppColors.navbarInactive,
                      ),
                    ),
                    const SizedBox(height: AppSizes.navbarLabelSpacing),
                    Text(
                      AppNavConstants.labels[i],
                      style: TextStyle(
                        fontSize: AppSizes.navbarFontSize,
                        fontWeight: FontWeight.w400,
                        color: isSelected
                            ? AppColors.navbarActive
                            : AppColors.navbarInactive,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class NavBarContainer extends StatefulWidget {
  final List<Widget> pages;
  final int initialIndex;
  final Color navbarBackgroundColor;

  const NavBarContainer({
    Key? key,
    required this.pages,
    this.initialIndex = 0,
    this.navbarBackgroundColor = Colors.white,
  })  : assert(
  pages.length == AppNavConstants.labels.length,
  'pages length must match labels/assets count',
  ),
        assert(
        initialIndex >= 0 &&
            initialIndex < AppNavConstants.labels.length,
        'initialIndex out of range',
        ),
        super(key: key);

  @override
  _NavBarContainerState createState() => _NavBarContainerState();
}

class _NavBarContainerState extends State<NavBarContainer> {
  static const int _sleepIndex = 2;

  late int _currentIndex;
  bool _showNavbar = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  bool get _isOnSleepPage => _currentIndex == _sleepIndex;
  bool _isNavDisabled(int newIndex) {
    if (_isOnSleepPage && newIndex != _sleepIndex) {
      return true;
    }
    return false;
  }
  List<int> get _disabledIndices {
    if (_isOnSleepPage) {
      return List<int>.generate(AppNavConstants.labels.length, (i) => i)
          .where((i) => i != _sleepIndex)
          .toList();
    }
    return <int>[];
  }

  void _onNavItemTapped(int newIndex) {
    if (_isNavDisabled(newIndex)) return;
    if (newIndex == _currentIndex) return;

    setState(() {
      _currentIndex = newIndex;
      _showNavbar = true;
    });
  }

  void _handleNavbarVisibility(bool visible) {
    setState(() => _showNavbar = visible);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> contentPages = widget.pages.asMap().entries.map<Widget>(
          (entry) {
        if (entry.key == _sleepIndex) {
          return SleepFlowPage(
            onNavbarVisibilityChange: _handleNavbarVisibility,
          );
        }
        return entry.value;
      },
    ).toList();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: contentPages,
      ),
      bottomNavigationBar: _showNavbar
          ? CustomNavbar(
        selectedIndex: _currentIndex,
        onTap: _onNavItemTapped,
        backgroundColor: widget.navbarBackgroundColor,
        disabledIndices: _disabledIndices,
      )
          : null,
    );
  }
}
