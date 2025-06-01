import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String imageUrl;
  final Color gradientColor;
  final IconData icon;

  const ProfileCard({
    Key? key,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.gradientColor,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [gradientColor.withOpacity(0.6), Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(height: 16),
            Text(
              name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white70, size: 18),
                SizedBox(width: 6),
                Text(subtitle, style: TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
