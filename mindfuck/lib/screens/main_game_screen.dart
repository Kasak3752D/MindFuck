import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MainGameScreen extends StatefulWidget {
  final String roomCode;
  const MainGameScreen({super.key, required this.roomCode});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseReference ref = FirebaseDatabase.instance.ref();
  final String? myUid = FirebaseAuth.instance.currentUser?.uid;

  // Game State
  int gameTimer = 0;
  bool isChoosingPower = false;
  bool isSwapping = false;
  bool isAnimatingSwap = false;
  Offset targetSwapOffset = Offset.zero;

  final List<double> edgeAngles = [0, 60, 120, 180, 240, 300];
  List<String> usernames = [];
  List<String> deck = [];
  String? drawnCard;
  int currentTurnIndex = 0;
  bool isMyTurn = false;
  bool showDrawnCard = false;
  Map<String, dynamic> playersData = {};

  @override
  void initState() {
    super.initState();
    _loadGameData();
  }

  void _loadGameData() {
    final roomRef = ref.child('rooms').child(widget.roomCode);
    roomRef.onValue.listen((event) {
      if (event.snapshot.value == null) return;
      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final playersMap = Map<String, dynamic>.from(data['players']);
      final fetchedUsernames = playersMap.values
          .map((p) => p['name'].toString())
          .toList();

      if (mounted) {
        setState(() {
          playersData = playersMap;
          gameTimer = data['gameDuration'] ?? 0;
          currentTurnIndex = data['turnIndex'] ?? 0;
          usernames = fetchedUsernames;
          deck = List<String>.from(data['deck'] ?? []);

          if (myUid != null && playersMap.containsKey(myUid)) {
            isMyTurn =
                fetchedUsernames[currentTurnIndex] == playersMap[myUid]['name'];
          }
        });
      }
    });
  }

  Future<void> _drawFromDeck() async {
    if (deck.isEmpty) return;
    List<String> newDeck = List.from(deck);
    String card = newDeck.removeLast();
    await ref.child('rooms').child(widget.roomCode).update({'deck': newDeck});
    setState(() {
      drawnCard = card;
      showDrawnCard = true;
    });
  }

  void _handleAction(String action) {
    if (drawnCard == null) return;
    String rankStr = drawnCard!.substring(0, drawnCard!.length - 1);
    int rankValue = _getRankValue(rankStr);

    if (action == "Throw") {
      if (rankValue >= 7) {
        setState(() => isChoosingPower = true);
      } else {
        _finishTurn();
      }
    } else if (action == "Swap") {
      setState(() {
        isSwapping = true;
        showDrawnCard = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tap one of your cards to swap!")),
      );
    }
  }

  int _getRankValue(String rank) {
    if (rank == 'A') return 1;
    if (rank == 'J') return 11;
    if (rank == 'Q') return 12;
    if (rank == 'K') return 13;
    return int.tryParse(rank) ?? 0;
  }

  Future<void> _performSwap(int cardIndex, double angle, double radius) async {
    if (myUid == null || drawnCard == null) return;

    // Calculate Animation Target
    final double edgeRad = angle * pi / 180;
    final Offset normal = Offset(cos(edgeRad + pi / 2), sin(edgeRad + pi / 2));

    setState(() {
      isAnimatingSwap = true;
      targetSwapOffset = normal * (radius + 45);
    });

    await Future.delayed(const Duration(milliseconds: 600));

    // Firebase Update
    List<dynamic> currentHand = List.from(playersData[myUid]['hand'] ?? []);
    currentHand[cardIndex] = drawnCard;
    await ref
        .child('rooms')
        .child(widget.roomCode)
        .child('players')
        .child(myUid!)
        .update({'hand': currentHand});

    setState(() => isAnimatingSwap = false);
    _finishTurn();
  }

  Future<void> _finishTurn() async {
    setState(() {
      showDrawnCard = false;
      drawnCard = null;
      isChoosingPower = false;
      isSwapping = false;
    });
    int nextTurn = (currentTurnIndex + 1) % usernames.length;
    await ref.child('rooms').child(widget.roomCode).update({
      'turnIndex': nextTurn,
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double hexSize = screen.width * 0.58;
    final double hexRadius = hexSize / 2.15;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Mindfuck", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                "$gameTimer s",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(hexSize, hexSize),
                  painter: HexagonPainter(),
                ),
                for (int i = 0; i < usernames.length; i++)
                  _playerOnEdge(
                    hexRadius: hexRadius,
                    edgeAngleDeg: edgeAngles[i],
                    username: usernames[i],
                    isActive: i == currentTurnIndex,
                    isMe:
                        (myUid != null &&
                        playersData[myUid]?['name'] == usernames[i]),
                  ),
                _deckWidget(),
                // SWAP ANIMATION LAYER
                if (isAnimatingSwap && drawnCard != null)
                  TweenAnimationBuilder<Offset>(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    tween: Tween<Offset>(
                      begin: Offset.zero,
                      end: targetSwapOffset,
                    ),
                    builder: (context, offset, child) => Transform.translate(
                      offset: offset,
                      child: _smallCardVisual(drawnCard!, isFaceUp: true),
                    ),
                  ),
              ],
            ),
          ),
          if (showDrawnCard && drawnCard != null) _drawnCardOverlay(),
        ],
      ),
    );
  }

  Widget _deckWidget() {
    return GestureDetector(
      onTap: () {
        if (isMyTurn && deck.isNotEmpty && !showDrawnCard && !isSwapping)
          _drawFromDeck();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        height: 80,
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          image: const DecorationImage(
            image: AssetImage('lib/assets/images/card_back.jpeg'),
            fit: BoxFit.cover,
          ),
          boxShadow: isMyTurn
              ? [
                  const BoxShadow(
                    color: Colors.white,
                    blurRadius: 25,
                    spreadRadius: 4,
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  Widget _drawnCardOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _cardFront(drawnCard!),
          const SizedBox(height: 30),
          if (!isChoosingPower)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ovalButton("Throw", () => _handleAction("Throw")),
                const SizedBox(width: 20),
                _ovalButton("Swap", () => _handleAction("Swap")),
              ],
            )
          else
            Column(
              children: [
                const Text(
                  "Use card power?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ovalButton("Yes", () => _finishTurn()),
                    const SizedBox(width: 20),
                    _ovalButton("No, Throw", () => _finishTurn()),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _playerOnEdge({
    required double hexRadius,
    required double edgeAngleDeg,
    required String username,
    required bool isActive,
    required bool isMe,
  }) {
    final double edgeRad = edgeAngleDeg * pi / 180;
    final Offset normal = Offset(cos(edgeRad + pi / 2), sin(edgeRad + pi / 2));
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: normal * (hexRadius + 45),
          child: Transform.rotate(
            angle: edgeRad,
            child: _smallCardGrid(isMe, edgeAngleDeg, hexRadius),
          ),
        ),
        Transform.translate(
          offset: normal * (hexRadius - 35),
          child: Transform.rotate(
            angle: edgeRad,
            child: Text(
              username,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _smallCardGrid(bool isMe, double angle, double radius) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _smallCard(0, isMe, angle, radius),
            const SizedBox(width: 4),
            _smallCard(1, isMe, angle, radius),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _smallCard(2, isMe, angle, radius),
            const SizedBox(width: 4),
            _smallCard(3, isMe, angle, radius),
          ],
        ),
      ],
    );
  }

  Widget _smallCard(int index, bool isMe, double angle, double radius) {
    bool highlight = isSwapping && isMe;
    return GestureDetector(
      onTap: () => highlight ? _performSwap(index, angle, radius) : null,
      child: Container(
        height: 42,
        width: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: highlight ? Border.all(color: Colors.yellow, width: 2) : null,
          image: const DecorationImage(
            image: AssetImage('lib/assets/images/card_back.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _smallCardVisual(String card, {bool isFaceUp = false}) {
    return Container(
      height: 42,
      width: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: isFaceUp
          ? Center(
              child: Text(
                card[0],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _ovalButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _cardFront(String card) {
    final rank = card.substring(0, card.length - 1);
    final suit = card.substring(card.length - 1);
    final symbol = {'S': '♠', 'H': '♥', 'D': '♦', 'C': '♣'}[suit] ?? '?';
    final isRed = suit == 'H' || suit == 'D';
    return Container(
      height: 280,
      width: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              rank,
              style: TextStyle(
                fontSize: 30,
                color: isRed ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            symbol,
            style: TextStyle(
              fontSize: 90,
              color: isRed ? Colors.red : Colors.black,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              rank,
              style: TextStyle(
                fontSize: 30,
                color: isRed ? Colors.red : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(0xFF8B0000)
      ..style = PaintingStyle.fill;
    final border = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    final path = Path();
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2.15;
    for (int i = 0; i < 6; i++) {
      final angle = (60 * i) * pi / 180;
      final x = cx + r * cos(angle);
      final y = cy + r * sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(_) => false;
}
