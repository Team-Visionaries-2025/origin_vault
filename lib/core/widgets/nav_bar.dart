import 'package:curved_navigation_bar_with_label/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:origin_vault/core/theme/app_pallete.dart';
import 'package:origin_vault/screens/admin_level/presentation/pages/admin_dashboard.dart';
import 'package:origin_vault/screens/admin_level/presentation/pages/user_management_page.dart';
import 'package:origin_vault/screens/producer_level/presentation/pages/producer_dashboard.dart';
import 'package:origin_vault/screens/producer_level/presentation/pages/product_page.dart';
import 'package:origin_vault/screens/retailer_level/presentation/pages/retailer_dashboard.dart';

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
    switch (widget.userLevel) {
      case 1:
        return [
          // Home Page (Admin Dashboard)
          const Usermanagement(),
          const Center(
            child: Text(
              "System Page",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const DashboardScreen(),
          const Center(
            child: Text(
              "Reports Page",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const Center(
            child: Text(
              "Access Control Page",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ];

      case 2:
        return [
          // producer level pages
          const ProductPage(),
          const Center(
            child: Text(
              "Message Page",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const Producerdashboard(),
          const Center(
            child: Text(
              "Supply chain Page",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const Center(
            child: Text(
              "Settings Page",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ];

      case 3:
        return [
          // Retailer level pages
          const RetailerDashboard(),
          const Center(
            child: Text(
              "Inventory Page",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const Center(
            child: Text(
              "Scan Product Page",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const Center(
            child: Text(
              "Consumer Insights Page",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const Center(
            child: Text(
              "Settings Page",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ];

      case 4:
        return [
          // Consumer level pages
          const Center(
            child: Text(
              "SCan Product Page",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const Center(
            child: Text(
              "Feedback Page",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const Center(
            child: Text(
              "Home Page",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const Center(
            child: Text(
              "Scan History Page",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const Center(
            child: Text(
              "Settings Page",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ];
      default:
        return [
          const DashboardScreen(),
        ];
    }
  }

  // Define navigation items based on user level
  List<CurvedNavigationBarItem> _initializeNavItems() {
    switch (widget.userLevel) {
      case 1:
        return [
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
        ];
      case 2:
        return [
          // Producer Navbar
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.box), label: ' Product'),
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.message), label: 'Messages'),
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.home), label: 'Dashboard'),
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.truck), label: 'Supply chain'),
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.setting), label: 'Settings'),
        ];
      case 3:
        return [
          // Retailer Navbar
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.chart_2), label: 'Summary'),
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.box), label: 'Inventory'),
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.scan), label: 'Scan Product'),
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.eye), label: 'Insights'),
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.setting), label: 'Settings'),
        ];
      case 4:
        return [
          // Consumer Navbar
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.scan), label: 'Scan'),
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.message), label: 'Feedback'),
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.home), label: 'Home'),
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.clock), label: 'History'),
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.setting), label: 'Settings'),
        ];

      default:
        return [
          // Default Navbar
          CurvedNavigationBarItem(
              icon: const Icon(Iconsax.house_2), label: 'Home'),
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
        items: _initializeNavItems(),
      ),
    );
  }
}
