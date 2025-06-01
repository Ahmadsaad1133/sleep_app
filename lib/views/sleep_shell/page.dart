import 'package:flutter/material.dart';
import 'package:first_flutter_app/widgets/navbar.dart';
import 'package:first_flutter_app/routes.dart';
import '../sleep_page/page.dart';
class SleepShellPage extends StatefulWidget {
  const SleepShellPage({Key? key}) : super(key: key);
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  _SleepShellPageState createState() => _SleepShellPageState();
}
class _SleepShellPageState extends State<SleepShellPage> {
  int _selectedIndex = 2;
  final List<String> _allRoutes = const [
    Routes.home,
    '/meditate',
    Routes.sleep,
    Routes.sleepMusic,
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
        .pushReplacementNamed(_allRoutes[index]);
    _navbarVisibleNotifier.value = true;
  }
  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final builderFn = Routes.sleepBuilders[settings.name];

    if (builderFn != null) {
      return MaterialPageRoute(
        builder: (_) => builderFn(_navbarVisibleNotifier),
        settings: settings,
      );
    }
    return MaterialPageRoute(
      builder: (_) => SleepPage(onNavbarVisibilityChange: _navbarVisibleNotifier),
      settings: settings,
    );
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
        initialRoute: Routes.sleep,
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
