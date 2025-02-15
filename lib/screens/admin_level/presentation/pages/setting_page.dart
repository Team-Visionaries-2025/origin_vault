import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:origin_vault/core/theme/app_pallete.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String selectedNotification = 'Important Only';
  bool is2FAEnabled = true;

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(10.w, 40.h, 10.w, 10.h),
      color: AppPallete.backgroundColor,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.cyan),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 20.w),
          Text(
            'Settings',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildListItem(IconData icon, String title, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon, color: Colors.cyan),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: trailing,
      onTap: () {
        // Handle item tap
      },
    );
  }

  Widget _buildRadioListTile(String title, String value) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      groupValue: selectedNotification,
      onChanged: (String? newValue) {
        setState(() {
          selectedNotification = newValue!;
        });
      },
      activeColor: Colors.cyan,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
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
              const Icon(Iconsax.setting_2, size: 24, color: Colors.cyan),
              SizedBox(height: 5.h),
              Text('Settings',
                  style: TextStyle(color: Colors.cyan, fontSize: 12.sp)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8.0,
        shape: const CircularNotchedRectangle(),
        color: AppPallete.secondarybackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Iconsax.people, "Users"),
            _buildNavItem(Iconsax.monitor_mobbile, "System"),
            SizedBox(width: 80.w), // Space for FAB
            _buildNavItem(Iconsax.status_up, "Reports"),
            _buildNavItem(Iconsax.document_text, "Audits"),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Account'),
                    _buildListItem(Iconsax.user_edit, 'Edit profile'),
                    _buildListItem(Iconsax.notification, 'Notifications'),
                    _buildRadioListTile('All', 'All'),
                    _buildRadioListTile('Important Only', 'Important Only'),
                    _buildRadioListTile('Warnings', 'Warnings'),
                    _buildListItem(
                      Iconsax.security_user,
                      'Privacy',
                      trailing: Switch(
                        value: is2FAEnabled,
                        onChanged: (value) {
                          setState(() {
                            is2FAEnabled = value;
                          });
                        },
                        activeColor: Colors.cyan,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    _buildSectionTitle('Actions'),
                    _buildListItem(Iconsax.info_circle, 'Report a problem'),
                    _buildListItem(Iconsax.logout, 'Log out'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppPallete.iconColor),
          SizedBox(height: 3.h),
          Text(label, style: const TextStyle(color: AppPallete.iconColor)),
        ],
      ),
    );
  }
}
