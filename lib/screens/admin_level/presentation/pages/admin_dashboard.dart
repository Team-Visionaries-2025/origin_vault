import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:origin_vault/core/theme/app_pallete.dart';
import 'package:origin_vault/screens/admin_level/presentation/pages/admin_sidebar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // ✅ FIX: Global Key to Control Drawer

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // ✅ Assign Global Key
      backgroundColor: Colors.black, // ✅ Entire App Background Black
      drawer: const Drawer(
        child: SideMenu(), // ✅ Sidebar (Works Now!)
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top navigation bar
            _buildTopNavBar(),

            // Main content area
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(),
                    SizedBox(height: 20.h),
                    _buildStatsSection(),
                    SizedBox(height: 20.h),
                    _buildRecentActivities(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Top Navigation Bar (Candle Icon opens Sidebar)
  Widget _buildTopNavBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Colors.black, // ✅ Black Navbar
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Iconsax.candle_2,
                color: Colors.white), // ✅ White Icon for Visibility
            onPressed: () {
              _scaffoldKey.currentState
                  ?.openDrawer(); // ✅ FIX: Opens Sidebar Now!
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.notification, color: Colors.white),
            onPressed: () {
              // Handle notification tap
            },
          ),
        ],
      ),
    );
  }

  /// 🔹 Welcome Section (Greeting)
  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello Admin',
          style: TextStyle(color: Colors.white, fontSize: 24.sp),
        ),
        Text(
          'Welcome Back!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// 🔹 Statistics Section (User Count, System Status)
  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildDataBox(
            'User Count',
            '120', // Replace with dynamic data
            '+11.75%',
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: _buildDataBox(
            'System Status',
            'ACTIVE',
            'Up-time Rate: 99.9%',
          ),
        ),
      ],
    );
  }

  /// 🔹 Single Data Box
  Widget _buildDataBox(String title, String value, String subValue) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[900], // ✅ Dark Grey Background
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 20.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subValue,
            style: TextStyle(color: Colors.greenAccent, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  /// 🔹 Recent Activities Section
  Widget _buildRecentActivities() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[900], // ✅ Dark Grey Background
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activities',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildActivityCard(
                  'Login',
                  'Admin accessed system',
                  '2025-01-31 10:30 AM',
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildActivityCard(
                  'Report Generated',
                  'Sales Report accessed',
                  '2025-01-31 11:00 AM',
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Align(
            alignment: Alignment.bottomRight,
            child: TextButton(
              onPressed: () {
                // Handle 'View All' action
              },
              child: Text(
                'View All',
                style: TextStyle(color: Colors.blueAccent, fontSize: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Single Activity Card
  Widget _buildActivityCard(String title, String description, String date) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.black, // ✅ Black Background for Activity Card
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(color: Colors.white, fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            date,
            style: TextStyle(color: Colors.greenAccent, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
