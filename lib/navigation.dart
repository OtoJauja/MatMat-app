import 'package:flutter/material.dart';
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

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      // Reset the current tab to its root when switching
      _navigatorKeys[_currentIndex].currentState?.popUntil((route) => route.isFirst);

      // Switch to the new tab
      setState(() {
        _currentIndex = index;
      });
    } else {
      // If the current tab is selected, pop to the root of that tab
      _navigatorKeys[_currentIndex].currentState?.popUntil((route) => route.isFirst);
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
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(_tabs.length, _buildTabNavigator),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learn'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedItemColor: const Color(0xffffa400),
        unselectedItemColor: const Color.fromARGB(255, 50, 50, 50),  
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}