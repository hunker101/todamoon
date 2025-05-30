import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todamoon_app/screens/nav/home_page.dart';
import 'package:todamoon_app/screens/nav/market_page.dart';
import 'package:todamoon_app/screens/nav/profile_page.dart';
import 'package:todamoon_app/screens/nav/watchlist.dart';

class MainNavScreen extends StatefulWidget {
  final String uid;

  const MainNavScreen({super.key, required this.uid});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      HomePage(uid: widget.uid),
      MarketPage(),
      WatchlistPage(uid: widget.uid),
      ProfilePage(uid: FirebaseAuth.instance.currentUser!.uid),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1C1F2A),
        selectedItemColor: Colors.lightBlueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Market',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Watchlist'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
