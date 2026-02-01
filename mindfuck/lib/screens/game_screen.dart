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

  List<String> cards = [];
  List<String> selected = [];

  int remaining = 6;
  Timer? timer;
  bool timerStarted = false;

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  // ================= DECK GENERATOR =================

  List<String> _generateDeck() {
    const suits = ['S', 'H', 'D', 'C'];
    const ranks = [
      'A',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'J',
      'Q',
      'K',
    ];

    List<String> d = [];

    for (var s in suits) {
      for (var r in ranks) {
        d.add("$r$s");
      }
    }

    d.shuffle();
    return d;
  }

  // ================= ENSURE DECK IN FIREBASE =================

  Future<void> _ensureDeckExists() async {
    final roomRef = ref.child('rooms').child(widget.roomCode);

    final snap = await roomRef.child('deck').get();

    if (!snap.exists) {
      print("Creating deck in Firebase");

      await roomRef.update({'deck': _generateDeck(), 'turnIndex': 0});
    } else {
      print("Deck already exists");
    }
  }

  // ================= LOAD PLAYER DATA =================

  Future<void> _loadGame() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final room = ref.child('rooms').child(widget.roomCode);

    // ✅ ensure deck exists first
    await _ensureDeckExists();

    final snap = await room.child('players').child(uid).get();
    final cardData = snap.child('cards').value;

    if (cardData != null) {
      if (cardData is List) {
        cards = List<String>.from(cardData);
      } else if (cardData is Map) {
        cards = cardData.values.map((e) => e.toString()).toList();
      }
    }

    print("Cards loaded: $cards");

    setState(() {});
  }

  // ================= SAVE CARD ORDER =================

  Future<void> _saveCardOrder() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final roomRef = ref.child('rooms').child(widget.roomCode);

    final remainingCards = cards.where((c) => !selected.contains(c)).toList();

    await roomRef.child('players').child(uid).child('cardOrder').set({
      "1": selected[0],
      "2": selected[1],
      "3": remainingCards[0],
      "4": remainingCards[1],
    });

    print("Card order saved");
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

      await _saveCardOrder();

      final uid = FirebaseAuth.instance.currentUser!.uid;

      await ref
          .child('rooms')
          .child(widget.roomCode)
          .child('players')
          .child(uid)
          .update({'ready': true});

      print("Player marked ready");
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
    final symbol = {'S': '♠', 'H': '♥', 'D': '♦', 'C': '♣'}[suit]!;

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
                symbol,
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
