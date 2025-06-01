import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/app_drawer.dart';

class HomeNavigation extends StatefulWidget {
  @override
  _HomeNavigationState createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    DashboardScreen(),
    ProfileScreen(),
    SettingsScreen(), // Pastikan SettingsScreen ada konstruktor default
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.deepPurpleAccent,
        unselectedItemColor: Colors.white54,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }
}
//  ---- Fx 1 
