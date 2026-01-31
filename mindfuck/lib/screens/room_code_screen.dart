import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class RoomCodeScreen extends StatefulWidget {
  final String roomCode;
  final bool isHost;

  const RoomCodeScreen({
    super.key,
    required this.roomCode,
    required this.isHost,
  });

  @override
  State<RoomCodeScreen> createState() => _RoomCodeScreenState();
}

class _RoomCodeScreenState extends State<RoomCodeScreen> {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  String username = "Loading...";
  String initial = "?";

  /// Only OTHER players (host excluded)
  List<String> otherPlayers = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  // ================= LOGIC ONLY =================
  Future<void> _init() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Fetch username
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final name = doc['name'] ?? "User";

    setState(() {
      username = name;
      initial = name.toString().isNotEmpty
          ? name.toString()[0].toUpperCase()
          : "?";
    });

    // Add user to room (RTDB)
    await dbRef
        .child('rooms')
        .child(widget.roomCode)
        .child('players')
        .child(uid)
        .set({'name': name, 'isHost': widget.isHost});

    // Listen for players
    dbRef.child('rooms').child(widget.roomCode).child('players').onValue.listen(
      (event) {
        final data = event.snapshot.value;
        if (data == null) return;

        final map = Map<String, dynamic>.from(data as Map);

        setState(() {
          otherPlayers = map.values
              .where((p) => p['name'] != username) // ❌ remove host
              .map((p) => p['name'].toString())
              .toList();
        });
      },
    );
  }
  // =================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: Colors.red[900]),
        child: Stack(
          children: [
            Container(color: Colors.black.withOpacity(0.4)),

            Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ONLINE MULTIPLAYER',
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 25),

                    _buildRoomCodeBox(),

                    const SizedBox(height: 30),

                    // HOST (UNCHANGED)
                    _buildHostAvatar(initial, username),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        "VS",
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 36,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),

                    // PLAYER SLOTS (DESIGN UNCHANGED)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            if (index < otherPlayers.length) {
                              final name = otherPlayers[index];
                              return _buildHostAvatar(
                                name[0].toUpperCase(),
                                name,
                              );
                            }
                            return _buildAddSlot();
                          }),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(2, (index) {
                            final i = index + 3;
                            if (i < otherPlayers.length) {
                              final name = otherPlayers[i];
                              return _buildHostAvatar(
                                name[0].toUpperCase(),
                                name,
                              );
                            }
                            return _buildAddSlot();
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: const BorderSide(color: Colors.white, width: 2),
                      ),
                      onPressed: () async {
                        if (!widget.isHost) {
                          _showError(context, "Only Host Can Start The Game");
                          return;
                        }

                        final ref = FirebaseDatabase.instance
                            .ref()
                            .child('rooms')
                            .child(widget.roomCode);

                        final snapshot = await ref.child('players').get();
                        final playersMap = Map<String, dynamic>.from(
                          snapshot.value as Map,
                        );

                        if (playersMap.length < 3 || playersMap.length > 6) {
                          _showError(
                            context,
                            "Players must be between 3 and 6",
                          );
                          return;
                        }

                        // create deck
                        final deck = _createDeck();
                        deck.shuffle();

                        int index = 0;

                        for (final entry in playersMap.entries) {
                          final cards = deck.sublist(index, index + 4);
                          index += 4;

                          await ref.child('players').child(entry.key).update({
                            'cards': cards,
                            'picked': [],
                            'ready': false,
                          });
                        }

                        await ref.update({
                          'status': 'picking',
                          'revealUntil':
                              DateTime.now().millisecondsSinceEpoch + 10000,
                        });
                      },
                      child: const Text(
                        "START GAME",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 50,
              left: 20,
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[900],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.yellow, width: 2),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.yellow,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI BELOW IS 100% UNCHANGED =================

  Widget _buildRoomCodeBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Room Code : ",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              Text(
                widget.roomCode,
                style: const TextStyle(
                  color: Colors.yellow,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Share this room code with friends and ask them to join",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildHostAvatar(String initial, String name) {
    return Column(
      children: [
        Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            color: Colors.blue[700],
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAddSlot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      height: 75,
      width: 75,
      decoration: BoxDecoration(
        color: Colors.red[800],
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
      ),
      child: Icon(
        Icons.person_add,
        color: Colors.white.withOpacity(0.5),
        size: 35,
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
}

List<String> _createDeck() {
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

  final deck = <String>[];

  for (final s in suits) {
    for (final r in ranks) {
      deck.add('$r$s');
    }
  }
  return deck;
}
