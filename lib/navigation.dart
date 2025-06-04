import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/Services/mission_provider_calm.dart';
import 'package:flutter_app/Services/mission_provider_fast.dart';
import 'package:provider/provider.dart';
import 'Views/home_view.dart';
import 'Views/progress_view.dart';
import 'Views/learn_view.dart';
import 'Views/settings_view.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(), // Home
    GlobalKey<NavigatorState>(), // Progress
    GlobalKey<NavigatorState>(), // Learn
    GlobalKey<NavigatorState>(), // Settings
  ];

  final List<Widget> _tabs = [
    const HomeView(),
    const ProgressView(),
    const LearnView(),
    const SettingsView(),
  ];

  @override
  void initState() {
    super.initState();
    _loadAllProgress();
  }

  Future<void> _loadAllProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userId = user.uid;
    final missionsProviderBear =
        Provider.of<MissionsProviderCalm>(context, listen: false);

    for (final subject in missionsProviderBear.subjectKeys) {
      await missionsProviderBear.loadProgressFromFirestore(userId, subject);
    }
    final fastProvider =
        Provider.of<MissionsProviderFast>(context, listen: false);
    for (final subject in fastProvider.subjectKeys) {
      await fastProvider.loadProgressFromFirestore(userId, subject);
    }
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      _navigatorKeys[_currentIndex]
          .currentState
          ?.popUntil((route) => route.isFirst);
      setState(() {
        _currentIndex = index;
      });
    } else {
      _navigatorKeys[_currentIndex]
          .currentState
          ?.popUntil((route) => route.isFirst);
    }
  }

  Widget _buildTabNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => _tabs[index],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final currentNavigatorState =
            _navigatorKeys[_currentIndex].currentState;
        if (currentNavigatorState != null && currentNavigatorState.canPop()) {
          currentNavigatorState.pop();
          return false;
        }
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(_tabs.length, _buildTabNavigator),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: tr('navigation.home'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.show_chart),
              label: tr('navigation.progress'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.school),
              label: tr('navigation.learn'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: tr('navigation.settings'),
            ),
          ],
          selectedItemColor: const Color(0xffffa400),
          unselectedItemColor: Theme.of(context).colorScheme.primary,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
