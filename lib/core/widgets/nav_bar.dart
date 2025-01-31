import 'package:curved_navigation_bar_with_label/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:origin_vault/core/theme/app_pallete.dart';
import 'package:origin_vault/screens/admin_level/presentation/pages/admin_dashboard.dart';
import 'package:origin_vault/screens/admin_level/presentation/pages/user_management_page.dart';

class UserPageWrapper extends StatefulWidget {
  final int userLevel;
  const UserPageWrapper({super.key, required this.userLevel});

  @override
  State<UserPageWrapper> createState() => _UserPageWrapperState();
}

class _UserPageWrapperState extends State<UserPageWrapper> {
  int _currentIndex = 0; //Tracks the selected tab index
  late List<Widget> _pages; //Dynamically sets pages based on userLevel

  @override
  void initState() {
    super.initState();
    _pages = _initializePages();
    return;
  }

  // Define pages based on user level
  List<Widget> _initializePages() {
    if (widget.userLevel == 1) {
      return [
        // Home Page (Admin Dashboard)
        const Usermanagement(),
        const Center(
            child: Text("System Page",
                style: TextStyle(color: Colors.white, fontSize: 20))),
        const DashboardScreen(),
        const Center(
            child: Text("Reports Page",
                style: TextStyle(color: Colors.white, fontSize: 20))),
        const Center(
            child: Text("Access Control Page",
                style: TextStyle(color: Colors.white, fontSize: 20))),
      ];
    } else {
      return [
        const DashboardScreen(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], //showing the current page
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        animationDuration: const Duration(milliseconds: 400),
        animationCurve: Curves.easeInOutBack,
        buttonLabelColor: AppPallete.textcolor1,
        height: 69.h,
        backgroundColor: AppPallete.backgroundColor,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: widget.userLevel == 1
            ? [
                // Admin Navbar
                CurvedNavigationBarItem(
                    icon: const Icon(Iconsax.people), label: 'Users'),
                CurvedNavigationBarItem(
                    icon: const Icon(Iconsax.monitor_mobbile), label: 'System'),
                CurvedNavigationBarItem(
                    icon: const Icon(Iconsax.house_2), label: 'Home'),
                CurvedNavigationBarItem(
                    icon: const Icon(Iconsax.status_up), label: 'Reports'),
                CurvedNavigationBarItem(
                    icon: const Icon(Iconsax.security_user),
                    label: 'Access\n Control'),
              ]
            : [
                // Employee Navbar
                CurvedNavigationBarItem(
                    icon: const Icon(Iconsax.user_add), label: 'Add'),
                CurvedNavigationBarItem(
                    icon: const Icon(Iconsax.eye), label: 'View'),
                CurvedNavigationBarItem(
                    icon: const Icon(Iconsax.home), label: 'Home'),
                CurvedNavigationBarItem(
                    icon: const Icon(Iconsax.scan), label: 'Scan QR'),
                CurvedNavigationBarItem(
                    icon: const Icon(Iconsax.profile_circle), label: 'User'),
              ],
      ),
    );
  }
}
