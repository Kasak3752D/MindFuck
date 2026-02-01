import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'main_game_screen.dart';

class GameScreen extends StatefulWidget {
  final String roomCode;
  const GameScreen({super.key, required this.roomCode});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final ref = FirebaseDatabase.instance.ref();

  List<String> cards = []; // 4 cards assigned to player
  List<String> selected = []; // cards picked by player (max 2)

  int remaining = 6;
  Timer? timer;
  bool timerStarted = false;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  // ================= LOAD PLAYER CARDS =================

  Future<void> _loadGame() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final room = ref.child('rooms').child(widget.roomCode);

    final snap = await room.child('players').child(uid).get();
    final cardData = snap.child('cards').value;

    if (cardData != null) {
      cards = List<String>.from(cardData as List);
    }

    setState(() {});
  }

  // ================= SAVE CARD ORDER (🔥 MAIN LOGIC) =================

  Future<void> _saveCardOrder() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final roomRef = ref.child('rooms').child(widget.roomCode);

    // remaining cards (not picked)
    final remainingCards = cards.where((c) => !selected.contains(c)).toList();

    await roomRef.child('players').child(uid).child('cardOrder').set({
      "1": selected[0], // first picked
      "2": selected[1], // second picked
      "3": remainingCards[0], // random remaining
      "4": remainingCards[1], // random remaining
    });
  }

  // ================= TIMER =================

  void _startTimer() {
    if (timerStarted) return;
    timerStarted = true;

    remaining = 6;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remaining == 0) {
        t.cancel();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainGameScreen(roomCode: widget.roomCode),
          ),
        );
      } else {
        setState(() => remaining--);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  // ================= CARD PICK =================

  void _pick(String card) async {
    if (selected.contains(card) || selected.length == 2) return;

    setState(() => selected.add(card));

    if (selected.length == 2) {
      _startTimer();

      // 🔥 SAVE ORDERED CARDS
      await _saveCardOrder();

      final uid = FirebaseAuth.instance.currentUser!.uid;
      await ref
          .child('rooms')
          .child(widget.roomCode)
          .child('players')
          .child(uid)
          .update({'ready': true});
    }
  }

  // ================= CARD UI =================

  Widget _card(String card) {
    final isSelected = selected.contains(card);

    return GestureDetector(
      onTap: () => _pick(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 160,
        width: 110,
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white, width: 2),
          color: Colors.white,
        ),
        child: isSelected ? _cardFront(card) : _cardBack(),
      ),
    );
  }

  Widget _cardBack() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset('lib/assets/images/card_back.jpeg', fit: BoxFit.cover),
    );
  }

  Widget _cardFront(String card) {
    final rank = card.substring(0, card.length - 1);
    final suit = card.substring(card.length - 1);

    final isRed = suit == 'H' || suit == 'D';
    final suitSymbol = {'S': '♠', 'H': '♥', 'D': '♦', 'C': '♣'}[suit]!;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              rank,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isRed ? Colors.red : Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                suitSymbol,
                style: TextStyle(
                  fontSize: 60,
                  color: isRed ? Colors.red : Colors.black,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              rank,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isRed ? Colors.red : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mindfuck"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              timerStarted ? "$remaining s" : "6 s",
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(top: screenHeight * 0.18, bottom: 40),
        children: [
          const Center(
            child: Text(
              "Pick any two cards",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: cards.take(2).map(_card).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: cards.skip(2).map(_card).toList(),
          ),
        ],
      ),
    );
  }
}
