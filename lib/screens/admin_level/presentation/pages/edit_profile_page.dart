import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:origin_vault/core/theme/app_pallete.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Melissa Peters');
  final TextEditingController _emailController =
      TextEditingController(text: 'melpeters@gmail.com');
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  String _dateOfBirth = '23/05/1995';
  String _country = 'Nigeria';

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
            'Edit Profile',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50.r,
          backgroundColor: Colors.orange,
          child: Icon(Icons.person, size: 60.sp, color: Colors.white),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: CircleAvatar(
            radius: 15.r,
            backgroundColor: Colors.cyan,
            child: Icon(Icons.camera_alt, size: 15.sp, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPassword = false, bool isDropdown = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white, fontSize: 16.sp)),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppPallete.secondarybackgroundColor,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: isDropdown
              ? DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: label == 'Date of Birth' ? _dateOfBirth : _country,
                    dropdownColor: AppPallete.secondarybackgroundColor,
                    style: const TextStyle(color: Colors.white),
                    onChanged: (String? newValue) {
                      setState(() {
                        if (label == 'Date of Birth') {
                          _dateOfBirth = newValue!;
                        } else {
                          _country = newValue!;
                        }
                      });
                    },
                    items: <String>['23/05/1995', 'Nigeria']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                )
              : TextField(
                  controller: controller,
                  obscureText: isPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: isPassword
                        ? const Icon(Icons.visibility_off, color: Colors.grey)
                        : null,
                  ),
                ),
        ),
        SizedBox(height: 16.h),
      ],
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
                  children: [
                    _buildProfilePicture(),
                    SizedBox(height: 24.h),
                    _buildTextField('Name', _nameController),
                    _buildTextField('Email', _emailController),
                    _buildTextField(
                        'Current Password', _currentPasswordController,
                        isPassword: true),
                    _buildTextField('New Password', _newPasswordController,
                        isPassword: true),
                    _buildTextField('Date of Birth',
                        TextEditingController(text: _dateOfBirth),
                        isDropdown: true),
                    _buildTextField(
                        'Country/Region', TextEditingController(text: _country),
                        isDropdown: true),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        // Handle save changes
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: const Text('Save changes'),
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
      padding: EdgeInsets.symmetric(vertical: 8.h),
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
