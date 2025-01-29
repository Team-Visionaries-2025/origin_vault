import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:origin_vault/core/theme/app_pallete.dart';
import 'package:origin_vault/screens/admin_level/presentation/pages/admin_sidebar.dart';
import 'package:origin_vault/screens/producer_level/presentation/pages/add_product_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Producerdashboard extends StatefulWidget {
  const Producerdashboard({super.key});

  @override
  State<Producerdashboard> createState() => _ProducerdashboardState();
}

class _ProducerdashboardState extends State<Producerdashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final supabase =
      SupabaseClient(dotenv.env['SUPABASE_URL']!, dotenv.env['SUPABASE_KEY']!);
  int _userCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserCount();
  }

  Future<void> _fetchUserCount() async {
    try {
      final response = await supabase.from('user_table').select();

      setState(() {
        _userCount = response.length;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 40.h, 10.w, 0),
      color: AppPallete.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Iconsax.candle_2, color: Colors.cyan),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.notification, color: Colors.cyan),
            onPressed: () {
              // Handle notification action
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataBox(String title, String value, String subValue) {
    return Container(
      height: 150.h, // Add this line to set a fixed height
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppPallete.secondarybackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: AppPallete.textcolor1, fontSize: 20.sp),
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
            style: TextStyle(color: Colors.cyan, fontSize: 14.sp),
          ),
          // Remove the SizedBox and Container for the chart/graph
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
      child: InkWell(
        onTap: () {
          print("$label button tapped");
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppPallete.iconColor, size: 24.sp),
            SizedBox(height: 3.h),
            Text(label,
                style: TextStyle(color: AppPallete.iconColor, fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppPallete.backgroundColor,
      drawer: SideMenu(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        height: 80.h,
        width: 80.w,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppPallete.secondarybackgroundColor,
          elevation: 0,
          shape: const CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.house_2,
                size: 24.sp,
                color: AppPallete.iconColor,
              ),
              SizedBox(height: 5.h),
              Text(
                'Home',
                style: TextStyle(
                  color: AppPallete.iconColor,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8.0,
        shape: const CircularNotchedRectangle(),
        color: AppPallete.secondarybackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddProductPage()),
                  );
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.box, color: AppPallete.iconColor),
                    SizedBox(height: 3),
                    Text("Products",
                        style: TextStyle(color: AppPallete.iconColor)),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(right: 20.0, top: 8.0, bottom: 1.0),
              child: InkWell(
                onTap: () {
                  // Handle tap on "System" button
                  print("System button tapped");
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.message_notif, color: AppPallete.iconColor),
                    SizedBox(height: 3),
                    Text("Message",
                        style: TextStyle(color: AppPallete.iconColor)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 8.0, bottom: 1.0),
              child: InkWell(
                onTap: () {
                  // Handle tap on "Reports" button
                  print("Reports button tapped");
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.d_cube_scan, color: AppPallete.iconColor),
                    SizedBox(height: 3),
                    Text("Suply Chain",
                        style: TextStyle(color: AppPallete.iconColor)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0, top: 8.0),
              child: InkWell(
                onTap: () {
                  // Handle tap on "Audits" button
                  print("Audits button tapped");
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.setting_2, color: AppPallete.iconColor),
                    SizedBox(height: 3),
                    Text("Settings",
                        style: TextStyle(color: AppPallete.iconColor)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello Producer',
                      style: TextStyle(color: Colors.white, fontSize: 24.sp),
                    ),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
