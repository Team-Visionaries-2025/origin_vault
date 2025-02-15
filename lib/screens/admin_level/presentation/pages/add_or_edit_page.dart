import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class AddEditUserScreen extends StatefulWidget {
  const AddEditUserScreen({super.key});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController walletIdController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  String? selectedUserRole;
  String? selectedPermission;
  bool isActive = true;

  List<String> userRoles = ['Admin', 'Editor', 'Viewer'];
  List<String> permissions = ['Read', 'Write', 'Execute'];

  /// **🔹 Function to Clear All Fields**
  void _clearForm() {
    setState(() {
      userIdController.clear();
      userNameController.clear();
      userEmailController.clear();
      walletIdController.clear();
      remarksController.clear();
      selectedUserRole = null;
      selectedPermission = null;
      isActive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.cyan),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Add/Edit User",
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.notification, color: Colors.cyan),
            onPressed: () {
              // Handle notification tap
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add/Edit User',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 16.h),
                _buildInputField('User ID', userIdController),
                _buildInputField('User Name', userNameController),
                _buildDropdownField('User Role', userRoles, (String? value) {
                  setState(() {
                    selectedUserRole = value;
                  });
                }),
                _buildInputField('User Mail', userEmailController),
                _buildInputField('Wallet ID', walletIdController),
                _buildDropdownField('Permissions', permissions,
                    (String? value) {
                  setState(() {
                    selectedPermission = value;
                  });
                }),
                _buildStatusToggle(),
                SizedBox(height: 24.h),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Smaller Input Field
  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14.sp)),
        SizedBox(height: 4.h),
        Container(
          height: 38.h, // **Reduced Height**
          decoration: BoxDecoration(
            color: Colors.grey[850], // **Matches Dropdown**
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  /// 🔹 Smaller Dropdown Field
  Widget _buildDropdownField(
      String label, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14.sp)),
        SizedBox(height: 4.h),
        Container(
          height: 38.h, // **Reduced Height**
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: Colors.grey[850], // **Matches Text Fields**
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              isExpanded: true,
              value: items.contains(selectedUserRole) ? selectedUserRole : null,
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(height: 10.h),
      ],
    );
  }

  /// 🔹 Status Toggle with ACTIVE & INACTIVE Labels
  Widget _buildStatusToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Status',
            style: TextStyle(color: Colors.grey[400], fontSize: 14.sp)),
        Row(
          children: [
            Text("ACTIVE",
                style: TextStyle(
                    color: isActive ? Colors.cyan : Colors.grey,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold)),
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
            Text("INACTIVE",
                style: TextStyle(
                    color: !isActive ? Colors.red : Colors.grey,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  /// 🔹 Simple Action Buttons
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton('Clear', Iconsax.refresh, Colors.grey, _clearForm),
        _buildActionButton('Delete', Iconsax.trash, Colors.red, () {}),
        _buildActionButton('Save', Iconsax.save_2, Colors.green, () {}),
      ],
    );
  }

  /// 🔹 Individual Action Button with Custom Functionality
  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}
