import 'package:flutter/material.dart';
import 'package:first_flutter_app/widgets/navbar.dart';
import 'package:first_flutter_app/views/sleep_page/sleep_page.dart';
import 'package:first_flutter_app/views/night_island/night_island_page.dart';
import 'package:first_flutter_app/views/sleep_music/sleep_music_page.dart';

class SleepShellPage extends StatefulWidget {
  const SleepShellPage({Key? key}) : super(key: key);

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  _SleepShellPageState createState() => _SleepShellPageState();
}

class _SleepShellPageState extends State<SleepShellPage> {
  int _selectedIndex = 2;

  final _routes = const [
    '/home',
    '/meditate',
    '/sleep',
    '/music',
    '/profile',
  ];
  final ValueNotifier<bool> _navbarVisibleNotifier = ValueNotifier<bool>(true);

  void _onNavTap(int index) {
    if (_selectedIndex == 2 && index != 2) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
    SleepShellPage.navigatorKey.currentState!
        .pushReplacementNamed(_routes[index]);
    _navbarVisibleNotifier.value = true;
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    Widget page;
    switch (settings.name) {
      case '/sleep':
        page = SleepPage(
          onNavbarVisibilityChange: _navbarVisibleNotifier,
        );
        break;
      case '/night_island':
        page = NightIslandPage(
          onNavbarVisibilityChange: _navbarVisibleNotifier,
        );
        break;
      case '/sleep_music':
        page = SleepMusicPage(
          onNavbarVisibilityChange: _navbarVisibleNotifier,
        );
        break;
      default:
        page = SleepPage(
          onNavbarVisibilityChange: _navbarVisibleNotifier,
        );
    }
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }

  @override
  void dispose() {
    _navbarVisibleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03174C),

      body: Navigator(
        key: SleepShellPage.navigatorKey,
        initialRoute: '/sleep',
        onGenerateRoute: _onGenerateRoute,
      ),

      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: _navbarVisibleNotifier,
        builder: (context, visible, _) {
          return visible
              ? CustomNavbar(
            selectedIndex: _selectedIndex,
            onTap: _onNavTap,
            backgroundColor: const Color(0xFF03174D),
            disabledIndices:
            _selectedIndex == 2 ? [0, 1, 3, 4] : <int>[],
          )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
