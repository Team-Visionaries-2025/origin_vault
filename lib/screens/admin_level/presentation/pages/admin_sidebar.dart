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
          const SizedBox(height: 50),
          const Text(
            'Origin Vault',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.orange,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text('ADMIN', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Iconsax.element_equal),
            title: const Text('Dashboard', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.setting_2),
            title: const Text('Settings', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Iconsax.logout),
            title: const Text('Logout', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Loginpage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
