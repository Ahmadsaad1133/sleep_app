import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:first_flutter_app/views/sleep/sleep_flow_page.dart';

class CustomNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Color backgroundColor;

  const CustomNavbar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  static const double _navHeight = 107.0;
  static const double _iconSize = 22.0;
  static const double _fontSize = 12.0;
  static const Color _activeColor = Color(0xFF8E97FD);
  static const Color _inactiveColor = Color(0xFFA0A3B1);

  static const _assets = [
    'assets/images/home105.svg',
    'assets/images/meditateIcon.svg',
    'assets/images/sleepIcon.svg',
    'assets/images/musicIcon.svg',
    'assets/images/profileIcon.svg',
  ];
  static const _labels = [
    'Home',
    'Meditate',
    'Sleep',
    'Music',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: _navHeight,
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
          children: List.generate(_labels.length, (i) {
            final isSelected = i == selectedIndex;
            return GestureDetector(
              onTap: () {
                if (!isSelected) onTap(i); // ✅ Only trigger if not already selected
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isSelected ? _activeColor : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      _assets[i],
                      width: _iconSize,
                      height: _iconSize,
                      color: isSelected ? Colors.white : _inactiveColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _labels[i],
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w400,
                      color: isSelected ? _activeColor : _inactiveColor,
                    ),
                  ),
                ],
              ),
            );
          }),
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
  })  : assert(pages.length == CustomNavbar._labels.length,
  'pages length must match labels/assets count'),
        assert(initialIndex >= 0 && initialIndex < CustomNavbar._labels.length,
        'initialIndex out of range'),
        super(key: key);

  @override
  _NavBarContainerState createState() => _NavBarContainerState();
}

class _NavBarContainerState extends State<NavBarContainer> {
  late int _currentIndex;
  bool _showNavbar = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onNavItemTapped(int newIndex) {
    if (newIndex == _currentIndex) return; // ✅ Prevent redundant navigation
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
    final contentPages = widget.pages.asMap().entries.map<Widget>((e) {
      if (e.key == 2) {
        // Special handling for Sleep tab (index 2)
        return SleepFlowPage(
          onNavbarVisibilityChange: _handleNavbarVisibility,
        );
      }
      return e.value;
    }).toList();

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
      )
          : null,
    );
  }
}
