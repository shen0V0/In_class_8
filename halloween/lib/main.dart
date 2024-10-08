import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import for localization
import 'package:just_audio/just_audio.dart'; // Just Audio package
import 'dart:async'; // For using Timer
import 'dart:math'; // For random movement

void main() => runApp(const HalloweenGame());

class HalloweenGame extends StatefulWidget {
  const HalloweenGame({super.key});

  @override
  _HalloweenGameState createState() => _HalloweenGameState();
}

class _HalloweenGameState extends State<HalloweenGame> with SingleTickerProviderStateMixin {
  final _backgroundPlayer = AudioPlayer(); // Just Audio background player
  final List<Offset> _positions = List.filled(5, const Offset(0, 0)); // Positions of jack-o'-lanterns
  final List<Offset> _directions = List.filled(5, const Offset(1, 1)); // Movement directions for lanterns
  final Random _random = Random();
  late AnimationController _controller;

  late int _correctIndex;
  List<bool> _isTrap = List.filled(5, false); // To track which lanterns are traps
  String _message = ""; // Message to display for player feedback
  bool _showJumpScare = false; // Variable to control jump scare image visibility

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
    _playBackgroundMusic(); // Start background music
    _randomizePositions();
    _correctIndex = _random.nextInt(5); // Randomly select the correct lantern index
    _randomizeTraps(); // Randomize which lanterns are traps

    // Initialize AnimationController for random movement
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // Increased duration for slower movement
    )..repeat();

    // Listen to the animation and update the positions
    _controller.addListener(() {
      _moveLanterns(); // Call to update lantern positions
    });
  }

  Future<void> _playBackgroundMusic() async {
    await _backgroundPlayer.setAsset('assets/halloween_music.mp3');
    _backgroundPlayer.setLoopMode(LoopMode.one); // Loop the background music
    _backgroundPlayer.play(); // Start playing the background music
  }

  void _randomizePositions() {
    for (int i = 0; i < _positions.length; i++) {
      _positions[i] = Offset(
        _random.nextDouble() * 300, // Random x position
        _random.nextDouble() * 600, // Random y position
      );

      // Randomize direction: either left or right and up or down
      double directionX = _random.nextBool() ? 1 : -1; // 1 for right, -1 for left
      double directionY = _random.nextBool() ? 1 : -1; // 1 for down, -1 for up
      _directions[i] = Offset(directionX, directionY);
    }
  }

  void _randomizeTraps() {
    // Set all lanterns as traps except the correct one
    for (int i = 0; i < _isTrap.length; i++) {
      _isTrap[i] = (i != _correctIndex); // Set to true for all but the correct index
    }
  }

  void _moveLanterns() {
    for (int i = 0; i < _positions.length; i++) {
      // Move lanterns in their respective direction
      _positions[i] = Offset(
        _positions[i].dx + _directions[i].dx * 0.75, // Move 2 pixels in the x direction
        _positions[i].dy + _directions[i].dy * 0.75, // Move 2 pixels in the y direction
      );

      // Check for boundary collisions
      if (_positions[i].dx <= 0 || _positions[i].dx >= 300) {
        _directions[i] = Offset(-_directions[i].dx, _directions[i].dy); // Reverse x direction
      }
      if (_positions[i].dy <= 0 || _positions[i].dy >= 600) {
        _directions[i] = Offset(_directions[i].dx, -_directions[i].dy); // Reverse y direction
      }

      // Keep lanterns within the screen bounds
      _positions[i] = Offset(
        _positions[i].dx.clamp(0, 300),
        _positions[i].dy.clamp(0, 600),
      );
    }
    setState(() {}); // Trigger a rebuild with new positions
  }

  void _handleTap(Offset tapPosition) {
    for (int i = 0; i < _positions.length; i++) {
      // Check if the tap is within the bounds of the lantern
      if ((tapPosition - _positions[i]).distance < 80) { // Assuming lanterns are 50x50 in size
        if (_isTrap[i]) {
          _playSound('jump_scare.mp3'); // Play jump scare sound
          setState(() {
            _message = "BOO! You hit a trap!";
            _showJumpScare = true; // Show the jump scare image
          });
          // Hide jump scare image after 1 second
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _showJumpScare = false; // Hide the jump scare image
            });
          });
        } else if (i == _correctIndex) {
          _playSound('Bell1.ogg'); // Play festive sound
          setState(() {
            _message = "You Found It!";
          });
        }
        break; // Exit the loop after handling a tap
      }
    }
  }

  void _playSound(String soundFile) async {
    final player = AudioPlayer(); // Create a new AudioPlayer instance
    try {
      await player.setAsset('assets/$soundFile'); // Load the asset
      await player.play(); // Play the sound
    } catch (e) {
      print("Error playing sound: $e"); // Log any errors
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the AnimationController
    _backgroundPlayer.dispose(); // Dispose the background player
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTapUp: (details) => _handleTap(details.localPosition), // Handle taps
          child: Stack(
            children: [
              ...List.generate(lanternImages.length, (index) {
                return Positioned(
                  left: _positions[index].dx,
                  top: _positions[index].dy,
                  child: Image.asset(lanternImages[index], width: 50, height: 50), // Assuming lanterns are 50x50
                );
              }),
              Positioned(
                bottom: 20,
                left: 20,
                child: Text(
                  _message,
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              // Show the jump scare image when a trap is hit
              if (_showJumpScare)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.8), // Optional overlay color
                    child: Center(
                      child: Image.asset('assets/sc.jpg'), // Jump scare image
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
