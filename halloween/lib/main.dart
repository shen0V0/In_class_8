import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; 
import 'dart:math'; 

void main() => runApp(HalloweenGame());

class HalloweenGame extends StatefulWidget {
  const HalloweenGame({super.key});

  @override
  _HalloweenGameState createState() => _HalloweenGameState();
}

class _HalloweenGameState extends State<HalloweenGame> with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer; 
  final List<Offset> _positions = List.filled(5, const Offset(0, 0)); 
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
  ]; 

  @override
  void initState() {
    super.initState();
    _startBackgroundMusic();
    _randomizePositions();
    _correctIndex = _random.nextInt(5); 

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), 
    )..repeat();

    _controller.addListener(() {
      _moveLanterns();
    });
  }

  void _startBackgroundMusic() async {
    _audioPlayer = AudioPlayer();
    await _audioPlayer.setSource(AssetSource('assets/halloween_music.mp3')); 
    _audioPlayer.setReleaseMode(ReleaseMode.loop); 
    _audioPlayer.setVolume(0.5); 
    _audioPlayer.resume(); 
  }

  void _randomizePositions() {
    setState(() {
      for (int i = 0; i < _positions.length; i++) {
        _positions[i] = Offset(_random.nextDouble() * 300, _random.nextDouble() * 500);
      }
    });
  }

  void _moveLanterns() {
    
    setState(() {
      for (int i = 0; i < _positions.length; i++) {
        double dx = _positions[i].dx + (_random.nextDouble() - 0.5) * 10;
        double dy = _positions[i].dy + (_random.nextDouble() - 0.5) * 10; 

        if (dx < 0) dx = 0;
        if (dy < 0) dy = 0;
        if (dx > 300) dx = 300; 
        if (dy > 500) dy = 500; 

        _positions[i] = Offset(dx, dy);
      }
    });
  }

  void _handleTap(int index) {
    if (_gameOver) return;

    if (index == _correctIndex) {
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
                child: Image.asset(lanternImages[index], width: 100, height: 100),  
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
    _controller.dispose(); 
    super.dispose();
  }
}
