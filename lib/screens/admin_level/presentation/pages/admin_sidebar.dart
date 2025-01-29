// File: sidebar.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:origin_vault/core/common/common_pages/loginpage.dart';
import 'package:origin_vault/screens/admin_level/presentation/pages/admin_dashboard.dart';
import 'package:origin_vault/screens/admin_level/presentation/pages/setting_page.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.black,
      child: Column(
        children: [
          SizedBox(height: 50),
          Text(
            'Origin Vault',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          SizedBox(height: 20),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.orange,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text('ADMIN', style: TextStyle(color: Colors.white)),
          SizedBox(height: 30),
          ListTile(
            leading: Icon(Iconsax.element_equal),
            title: Text('Dashboard', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Iconsax.setting_2),
            title: Text('Settings', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Iconsax.logout),
            title: Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Loginpage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
