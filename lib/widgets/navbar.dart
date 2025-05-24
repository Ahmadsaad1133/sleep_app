
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
class CustomNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final double scale;

  const CustomNavbar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    this.scale = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const double navHeight = 107.0;
    const double iconSize = 22.0;
    const double fontSize = 12.0;

    return SafeArea(
      top: false,
      child: Container(
        height: navHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(
              asset: 'assets/images/home105.svg',
              label: 'Home',
              index: 0,
              selectedIndex: selectedIndex,
              iconSize: iconSize,
              fontSize: fontSize,
              onTap: onTap,
            ),
            _NavItem(
              asset: 'assets/images/meditateIcon.svg',
              label: 'Meditate',
              index: 1,
              selectedIndex: selectedIndex,
              iconSize: iconSize,
              fontSize: fontSize,
              onTap: onTap,
            ),
            _NavItem(
              asset: 'assets/images/sleepIcon.svg',
              label: 'Sleep',
              index: 2,
              selectedIndex: selectedIndex,
              iconSize: iconSize,
              fontSize: fontSize,
              onTap: onTap,
            ),
            _NavItem(
              asset: 'assets/images/musicIcon.svg',
              label: 'Music',
              index: 3,
              selectedIndex: selectedIndex,
              iconSize: iconSize,
              fontSize: fontSize,
              onTap: onTap,
            ),
            _NavItem(
              asset: 'assets/images/profileIcon.svg',
              label: 'Profile',
              index: 4,
              selectedIndex: selectedIndex,
              iconSize: iconSize,
              fontSize: fontSize,
              onTap: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String asset;
  final String label;
  final int index;
  final int selectedIndex;
  final double iconSize;
  final double fontSize;
  final ValueChanged<int> onTap;

  const _NavItem({
    Key? key,
    required this.asset,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.iconSize,
    required this.fontSize,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    const activeColor = Color(0xFF8E97FD);
    const inactiveColor = Color(0xFFA0A3B1);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isSelected ? activeColor : Colors.transparent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              asset,
              width: iconSize,
              height: iconSize,
              color: isSelected ? Colors.white : inactiveColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// A container that hosts up to five pages and shows the navbar.
class NavBarContainer extends StatefulWidget {
  final double scale;
  final List<Widget> pages;

  const NavBarContainer({
    Key? key,
    this.scale = 1.0,
    required this.pages,
  }) : super(key: key);

  @override
  _NavBarContainerState createState() => _NavBarContainerState();
}

class _NavBarContainerState extends State<NavBarContainer> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Clamp the index so it never goes out of bounds
    final safeIndex = _currentIndex.clamp(0, widget.pages.length - 1);

    return Scaffold(
      body: widget.pages[safeIndex],
      bottomNavigationBar: CustomNavbar(
        selectedIndex: safeIndex,
        scale: widget.scale,
        onTap: (newIndex) {
          setState(() => _currentIndex = newIndex);
        },
      ),
    );
  }
}
