import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:origin_vault/core/theme/app_pallete.dart';

class AddEditUserScreen extends StatefulWidget {
  const AddEditUserScreen({super.key});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  bool isActive = true;

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
      color: AppPallete.backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.cyan),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.cyan),
            onPressed: () {
              // Handle notification action
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      height: 40.h,
      decoration: BoxDecoration(
        color: AppPallete.secondarybackgroundColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppPallete.iconColor, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white, fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: 'User Name',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          Icon(Icons.more_vert, color: Colors.cyan, size: 20.sp),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, {bool isDropdown = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppPallete.textcolor1, fontSize: 14.sp),
        ),
        SizedBox(height: 4.h),
        Container(
          height: 40.h,
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppPallete.secondarybackgroundColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: isDropdown
              ? DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: AppPallete.secondarybackgroundColor,
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                    items: ['Option 1', 'Option 2'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (_) {},
                  ),
                )
              : TextField(
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 60.h,
        width: 60.w,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: AppPallete.secondarybackgroundColor,
          elevation: 0,
          shape: CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.house_2, size: 24, color: AppPallete.iconColor),
              SizedBox(height: 2),
              Text('Home',
                  style:
                      TextStyle(color: AppPallete.iconColor, fontSize: 10.sp)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        notchMargin: 8.0,
        shape: CircularNotchedRectangle(),
        color: AppPallete.secondarybackgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(Iconsax.people, "Users"),
            _buildNavItem(Iconsax.monitor_mobbile, "System"),
            _buildNavItem(Iconsax.status_up, "Reports"),
            _buildNavItem(Iconsax.document_text, "Audits"),
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
                      'Add/Edit User',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    _buildSearchBar(),
                    _buildInputField('User ID'),
                    _buildInputField('User Name'),
                    _buildInputField('User Role', isDropdown: true),
                    _buildInputField('User Mail'),
                    _buildInputField('Wallet ID'),
                    _buildInputField('Permissions', isDropdown: true),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status',
                            style: TextStyle(
                                color: AppPallete.textcolor1, fontSize: 14.sp)),
                        Switch(
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              isActive = value;
                            });
                          },
                          activeColor: Colors.cyan,
                          inactiveThumbColor: Colors.grey,
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(
                            'Clear Form', Icons.refresh, Colors.grey),
                        _buildActionButton('Delete', Icons.delete, Colors.red),
                        _buildActionButton('Save', Icons.save, Colors.green),
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

  Widget _buildNavItem(IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppPallete.iconColor, size: 20.sp),
          SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: AppPallete.iconColor, fontSize: 10.sp)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.white, size: 18.sp),
      label: Text(label, style: TextStyle(fontSize: 12.sp)),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}
