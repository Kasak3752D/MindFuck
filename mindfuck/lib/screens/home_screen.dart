import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'room_code_screen.dart';

void main() {
  runApp(const MaterialApp(home: HomeScreen()));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // RANDOM ROOM CODE GENERATOR
  String generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();

    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rand.nextInt(chars.length))),
    );
  }

  // JOIN TEAM
  void _showJoinRoomDialog(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(20),
            decoration: _dialogDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogTitle('ENTER PRIVATE CODE'),
                const SizedBox(height: 25),

                // SAME UI – controller added
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: TextField(
                    controller: codeController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: "Enter private code here...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                _buildDialogButton("Join Room", () async {
                  final code = codeController.text.trim().toUpperCase();

                  if (code.isEmpty) {
                    _showError(context, "Incorrect Room Code Entered");
                    return;
                  }

                  final ref = FirebaseDatabase.instance
                      .ref()
                      .child('rooms')
                      .child(code);

                  final snapshot = await ref.get();

                  if (!snapshot.exists) {
                    _showError(context, "Incorrect Room Code Entered");
                    return;
                  }

                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RoomCodeScreen(roomCode: code, isHost: false),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // CREATE TEAM
  void _showCreateTeamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            padding: const EdgeInsets.all(25),
            decoration: _dialogDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogTitle('CREATE NEW TEAM'),
                const SizedBox(height: 20),
                const Text(
                  "Enter game duration in minutes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 15),
                _buildDashedInput("e.g. 15", true),
                const SizedBox(height: 35),

                _buildDialogButton("Generate team code", () async {
                  final code = generateRoomCode();

                  await FirebaseDatabase.instance
                      .ref()
                      .child('rooms')
                      .child(code)
                      .set({'status': 'waiting'});

                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RoomCodeScreen(roomCode: code, isHost: true),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // UI HELPERS (UNCHANGED)
  BoxDecoration _dialogDecoration() {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF003399), Color(0xFF001133)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.yellow, width: 3),
    );
  }

  Widget _dialogTitle(String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.yellow,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildDashedInput(String hint, bool isNumeric) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumeric
            ? [FilteringTextInputFormatter.digitsOnly]
            : [],
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0066FF),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.yellow, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.6),
              blurRadius: 12,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(title: const Text("Error"), content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset(
                'lib/assets/images/mindfuck.jpeg',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 10),
            Image.asset(
              'lib/assets/images/image2.jpeg',
              width: 400,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 70),
            GameButton(
              width: width * 0.85,
              icon: Icons.group_add,
              text: "CREATE TEAM",
              backgroundColor: Colors.white,
              iconColor: Colors.blue,
              textColor: Colors.blue,
              onTap: () => _showCreateTeamDialog(context),
            ),
            const SizedBox(height: 24),
            GameButton(
              width: width * 0.85,
              icon: Icons.sync,
              text: "JOIN TEAM",
              backgroundColor: const Color(0xFFE8F5E9),
              iconColor: Colors.green,
              textColor: Colors.green,
              onTap: () => _showJoinRoomDialog(context),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
