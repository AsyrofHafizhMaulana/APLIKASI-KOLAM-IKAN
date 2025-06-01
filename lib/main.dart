import 'package:flutter/material.dart';
import 'screens/home_navigation.dart';
import 'services/mqtt_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        textTheme: TextTheme(
          titleMedium: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
        primaryColor: Colors.deepPurple,
      ),
      home: HomeNavigation(),
    );
  }
}
//  ---- Fx 1 
