import 'package:flutter/material.dart';
import '../core/app_icon.dart';
import 'home/home_tab.dart';
import 'notices_screen.dart';
import 'services_tab.dart';
import 'blog_screen.dart';
import 'more_tab.dart';

class HomeNavigation {
  HomeNavigation._();
  static const homeIndex = 0;
  static const noticesIndex = 1;
  static const servicesIndex = 2;
  static const blogIndex = 3;
  static const moreIndex = 4;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // ignore: library_private_types_in_public_api
  static _HomeScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<_HomeScreenState>();

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = HomeNavigation.homeIndex;

  void setCurrentIndex(int index) => setState(() => _currentIndex = index);

  static const _tabs = [
    HomeTab(),
    NoticesScreen(),
    ServicesTab(),
    BlogScreen(),
    MoreTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: setCurrentIndex,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: AppAssetIcon('assets/icons/home_icon.png', size: 24), label: 'Home'),
          BottomNavigationBarItem(icon: AppAssetIcon('assets/icons/notice_icon.png', size: 24), label: 'Notices'),
          BottomNavigationBarItem(icon: AppAssetIcon('assets/icons/menu_dots_icon.png', size: 24), label: 'Services'),
          BottomNavigationBarItem(icon: AppAssetIcon('assets/icons/blog_icon.png', size: 24), label: 'Blog'),
          BottomNavigationBarItem(icon: AppAssetIcon('assets/icons/more_icon.png', size: 24), label: 'More'),
        ],
      ),
    );
  }
}
