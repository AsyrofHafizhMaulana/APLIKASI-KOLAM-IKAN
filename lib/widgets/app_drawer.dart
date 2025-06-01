import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black87,
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CircleAvatar(radius: 30, backgroundImage: AssetImage('assets/profile.png')),
                SizedBox(height: 10),
                Text('Asyrof Hafizh', style: TextStyle(color: Colors.white, fontSize: 18)),
                Text('flutter_maps Project', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: Colors.white),
            title: Text('Dashboard', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.white),
            title: Text('Tentang Aplikasi', style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
