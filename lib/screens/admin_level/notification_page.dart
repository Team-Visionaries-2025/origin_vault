import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<bool> _selectedNotifications =
      List.generate(6, (index) => false); // Checkbox state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // ✅ Dark Theme Background
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.white, size: 24),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionButtons(), // ✅ Action buttons section
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  return _buildNotificationTile(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Action Buttons Section (Mark Read, Snooze, Delete)
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionButton(
            "Mark All Read", Colors.lightBlue, Iconsax.tick_circle, () {
          setState(() {
            _selectedNotifications =
                List.generate(_selectedNotifications.length, (index) => true);
          });
        }),
        _buildActionButton("Snooze", Colors.amber, Iconsax.timer, () {
          // Implement Snooze Functionality
        }),
        _buildActionButton("Delete", Colors.red, Iconsax.trash, () {
          setState(() {
            _selectedNotifications =
                List.generate(_selectedNotifications.length, (index) => false);
          });
        }),
      ],
    );
  }

  /// 🔹 Individual Action Button
  Widget _buildActionButton(
      String text, Color color, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black, size: 18),
      label: Text(text,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  /// 🔹 Notification Tile
  Widget _buildNotificationTile(int index) {
    final notification = _notifications[index];

    final String title = notification["title"] ?? "Unknown";
    final String subtitle = notification["subtitle"] ?? "No details";
    final String type = notification["type"] ?? "Info";

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[900], // Darker Background for Cards
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _buildNotificationIcon(type), // ✅ Dynamic Icon Based on Type
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ],
          ),
          Transform.scale(
            scale: 1.2, // ✅ Bigger Checkbox for Better UX
            child: Checkbox(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.r)),
              value: _selectedNotifications[index],
              onChanged: (bool? value) {
                setState(() {
                  _selectedNotifications[index] = value!;
                });
              },
              activeColor: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Notification Icon Based on Type
  Widget _buildNotificationIcon(String type) {
    Color iconColor;
    IconData iconData;

    switch (type) {
      case "Success":
        iconColor = Colors.greenAccent;
        iconData = Iconsax.check;
        break;
      case "Error":
        iconColor = Colors.redAccent;
        iconData = Iconsax.warning_2;
        break;
      case "Warning":
        iconColor = Colors.amber;
        iconData = Iconsax.warning_2;
        break;
      default:
        iconColor = Colors.blueAccent;
        iconData = Iconsax.info_circle;
    }

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.r),
        border: Border(left: BorderSide(color: iconColor, width: 4.w)),
      ),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }
}

/// 🔹 Sample Notification Data
final List<Map<String, String>> _notifications = [
  {"title": "Success", "subtitle": "Message received", "type": "Success"},
  {"title": "Error", "subtitle": "Login failed", "type": "Error"},
  {"title": "Warning", "subtitle": "Low storage warning", "type": "Warning"},
  {"title": "Information", "subtitle": "App update available", "type": "Info"},
  {"title": "Error", "subtitle": "Payment declined", "type": "Error"},
  {"title": "Information", "subtitle": "New feature added", "type": "Info"},
];
