import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // For background music and sound effects
import 'dart:math'; // For random movement

void main() => runApp(HalloweenGame());

class HalloweenGame extends StatefulWidget {
  const HalloweenGame({super.key});

  @override
  _HalloweenGameState createState() => _HalloweenGameState();
}

class _HalloweenGameState extends State<HalloweenGame> with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer; // Marked as 'late' to avoid initialization error
  final List<Offset> _positions = List.filled(5, const Offset(0, 0)); // Positions of jack-o'-lanterns
  int _correctIndex = 0;
  bool _gameOver = false;
  final Random _random = Random();
  late AnimationController _controller;
  List<String> lanternImages = [
    'assets/p1.png',
    'assets/p2.png',
    'assets/p3.png',
    'assets/p4.png',
    'assets/p5.png'
  ]; // Different images for the jack-o'-lanterns

  @override
  void initState() {
    super.initState();
    _startBackgroundMusic();
    _randomizePositions();
    _correctIndex = _random.nextInt(5); // Randomly select the correct jack-o'-lantern

    // Initialize AnimationController for random movement
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Increased duration for slower movement
    )..repeat();

    // Listen to the animation and update the positions
    _controller.addListener(() {
      _moveLanterns();
    });
  }

  void _startBackgroundMusic() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setSource(AssetSource('assets/halloween_music.mp3')); // Background music file
    _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop the music
    _audioPlayer.setVolume(0.5); // Optional: set volume (0.0 to 1.0)
    _audioPlayer.resume(); // Start playing the music
  }

  void _randomizePositions() {
    // Randomize initial positions of the jack-o'-lanterns
    setState(() {
      for (int i = 0; i < _positions.length; i++) {
        _positions[i] = Offset(_random.nextDouble() * 300, _random.nextDouble() * 500);
      }
    });
  }

  void _moveLanterns() {
    // Randomly move the lanterns within the screen bounds
    setState(() {
      for (int i = 0; i < _positions.length; i++) {
        double dx = _positions[i].dx + (_random.nextDouble() - 0.5) * 10; // Slower movement
        double dy = _positions[i].dy + (_random.nextDouble() - 0.5) * 10; // Slower movement

        // Ensure the positions are within screen bounds (adjust these values as needed)
        if (dx < 0) dx = 0;
        if (dy < 0) dy = 0;
        if (dx > 300) dx = 300; // Screen width limit
        if (dy > 500) dy = 500; // Screen height limit

        _positions[i] = Offset(dx, dy);
      }
    });
  }

  void _handleTap(int index) {
    if (_gameOver) return;

    if (index == _correctIndex) {
      // Correct lantern clicked
      setState(() {
        _gameOver = true;
      });
      _showWinMessage();
    } else {
      _showWrongTapFeedback();
    }
  }

  void _showWinMessage() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("You Found It!"),
        content: const Text("Congratulations, you clicked the correct Jack-o'-lantern!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restartGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _showWrongTapFeedback() {
    // Provide feedback for wrong taps
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Try Again! That's not the right Jack-o'-lantern."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _restartGame() {
    setState(() {
      _gameOver = false;
      _randomizePositions();
      _correctIndex = _random.nextInt(5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Halloween Game')),
        body: Stack(
          children: List.generate(5, (index) {
            return Positioned(
              left: _positions[index].dx,
              top: _positions[index].dy,
              child: GestureDetector(
                onTap: () => _handleTap(index),
                child: Image.asset(lanternImages[index], width: 100, height: 100), // Use different lantern images
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose(); // Dispose the animation controller
    super.dispose();
  }
}
