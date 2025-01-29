import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:origin_vault/core/theme/app_pallete.dart';
import 'package:origin_vault/core/widgets/qr_scanner.dart';
import 'package:origin_vault/screens/admin_level/presentation/pages/admin_sidebar.dart';
import 'package:origin_vault/screens/producer_level/presentation/pages/add_product_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Consumerdashboard extends StatefulWidget {
  const Consumerdashboard({super.key});

  @override
  State<Consumerdashboard> createState() => _ConsumerdashboardState();
}

class _ConsumerdashboardState extends State<Consumerdashboard> {
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
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching user count: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildScannerButton(
      IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPallete.secondarybackgroundColor,
          padding: EdgeInsets.symmetric(vertical: 20.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.cyan, size: 40.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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
      height: 150.h,
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
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppPallete.iconColor, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(color: AppPallete.iconColor, fontSize: 10.sp),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
        height: 60.h,
        width: 60.w,
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
              SizedBox(height: 2.h),
              Text(
                'Home',
                style: TextStyle(
                  color: AppPallete.iconColor,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 6.0,
        shape: const CircularNotchedRectangle(),
        color: AppPallete.secondarybackgroundColor,
        child: SizedBox(
          height: 70.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Iconsax.scanner, "Scan Product", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProductPage()),
                );
              }),
              _buildBottomNavItem(Iconsax.like_tag, "Feedback", () {
                print("Feedback button tapped");
              }),
              SizedBox(width: 60.w), // Space for the floating action button
              _buildBottomNavItem(Iconsax.scanning, "Scan History", () {
                print("Scan History button tapped");
              }),
              _buildBottomNavItem(Iconsax.setting_2, "Settings", () {
                print("Settings button tapped");
              }),
            ],
          ),
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
                      'Hello Consumer',
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
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        _buildScannerButton(
                          Iconsax
                              .scanner, // You might need to replace this with a more appropriate QR code icon
                          'QR\nScanner',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const QrScannerPage();
                                },
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 16.w),
                        _buildScannerButton(
                          Iconsax
                              .barcode, // You might need to replace this with a more appropriate barcode icon
                          'Barcode\nScanner',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const QrScannerPage();
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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
