import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 TITLE IMAGE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset(
                'lib/assets/images/mindfuck.jpeg',
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 10),
            Image.asset(
              'lib/assets/images/image2.jpeg', // <-- change to your exact image name
              width: 400, // adjust if needed
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 70),

            // 🔹 CREATE TEAM BUTTON
            GameButton(
              width: width * 0.85,
              icon: Icons.group_add,
              text: "CREATE TEAM",
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              iconColor: Colors.blue,
              textColor: Colors.blue,
              onTap: () {
                print("Create Team");
              },
            ),

            const SizedBox(height: 24),

            // 🔹 JOIN TEAM BUTTON
            GameButton(
              width: width * 0.85,
              icon: Icons.sync,
              text: "JOIN TEAM",
              backgroundColor: Color(0xFFE8F5E9),
              iconColor: Colors.green,
              textColor: Colors.green,
              onTap: () {
                print("Join Team");
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GameButton extends StatelessWidget {
  final double width;
  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const GameButton({
    super.key,
    required this.width,
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
