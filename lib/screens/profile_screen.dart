import 'package:flutter/material.dart';
import '../widgets/profile_card.dart'; // import widget card-nya

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profil")),
      body: ListView(
        children: [
          ProfileCard(
            name: "Asyrof Hafizh Maulana",
            subtitle: "Design UI / UX",
            imageUrl:
                "https://raw.githubusercontent.com/Nugraa21/HIMATEK/refs/heads/main/HTML/s2/zio.jpg",
            gradientColor: Colors.deepPurpleAccent,
            icon: Icons.code,
          ),
          ProfileCard(
            name: "Joyce Priscila Dawa",
            subtitle: "Programer App",
            imageUrl:
                "https://raw.githubusercontent.com/Nugraa21/HIMATEK/refs/heads/main/HTML/s2/joice.jpg",
            gradientColor: Colors.pinkAccent,
            icon: Icons.movie,
          ),
          ProfileCard(
            name: "Wilibrodus Daniel Sogen",
            subtitle: "----",
            imageUrl:
                "https://raw.githubusercontent.com/Nugraa21/HIMATEK/refs/heads/main/HTML/s2/danil.jpg",
            gradientColor: Colors.greenAccent,
            icon: Icons.movie,
          ),
        ],
      ),
    );
  }
}
//  ---- Fx 1 
