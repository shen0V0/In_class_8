import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:just_audio/just_audio.dart'; 
import 'dart:async'; 
import 'dart:math'; 

void main() => runApp(const HalloweenGame());

class HalloweenGame extends StatefulWidget {
  const HalloweenGame({super.key});

  @override
  _HalloweenGameState createState() => _HalloweenGameState();
}

class _HalloweenGameState extends State<HalloweenGame> with SingleTickerProviderStateMixin {
  final _backgroundPlayer = AudioPlayer();  
  final List<Offset> _positions = List.filled(5, const Offset(0, 0)); 
  final List<Offset> _directions = List.filled(5, const Offset(1, 1)); 
  final Random _random = Random();
  late AnimationController _controller;

  late int _correctIndex;
  List<bool> _isTrap = List.filled(5, false); 
  String _message = ""; 
  bool _showJumpScare = false; 

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
    _playBackgroundMusic(); 
    _randomizePositions();
    _correctIndex = _random.nextInt(5); 
    _randomizeTraps(); 

   
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), 
    )..repeat();

    _controller.addListener(() {
      _moveLanterns(); 
    });
  }

  Future<void> _playBackgroundMusic() async {
    await _backgroundPlayer.setAsset('assets/halloween_music.mp3');
    _backgroundPlayer.setLoopMode(LoopMode.one);  
    _backgroundPlayer.play(); 
  }

  void _randomizePositions() {
    for (int i = 0; i < _positions.length; i++) {
      _positions[i] = Offset(
        _random.nextDouble() * 300, 
        _random.nextDouble() * 600, 
      );

      
      double directionX = _random.nextBool() ? 1 : -1; 
      double directionY = _random.nextBool() ? 1 : -1; 
      _directions[i] = Offset(directionX, directionY);
    }
  }

  void _randomizeTraps() {
    for (int i = 0; i < _isTrap.length; i++) {
      _isTrap[i] = (i != _correctIndex); 
    }
  }

  void _moveLanterns() {
    for (int i = 0; i < _positions.length; i++) {
      _positions[i] = Offset(
        _positions[i].dx + _directions[i].dx * 0.75, 
        _positions[i].dy + _directions[i].dy * 0.75, 
      );

      if (_positions[i].dx <= 0 || _positions[i].dx >= 300) {
        _directions[i] = Offset(-_directions[i].dx, _directions[i].dy); 
      }
      if (_positions[i].dy <= 0 || _positions[i].dy >= 600) {
        _directions[i] = Offset(_directions[i].dx, -_directions[i].dy); 
      }

      _positions[i] = Offset(
        _positions[i].dx.clamp(0, 300),
        _positions[i].dy.clamp(0, 600),
      );
    }
    setState(() {}); 
  }

  void _handleTap(Offset tapPosition) {
    for (int i = 0; i < _positions.length; i++) {
     
      if ((tapPosition - _positions[i]).distance < 80) { 
        if (_isTrap[i]) {
          _playSound('jump_scare.mp3'); 
          setState(() {
            _message = "BOO! You hit a trap!";
            _showJumpScare = true; 
          });
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _showJumpScare = false; 
            });
          });
        } else if (i == _correctIndex) {
          _playSound('Bell1.ogg'); 
          setState(() {
            _message = "You Found It!";
          });
        }
        break; 
      }
    }
  }

  void _playSound(String soundFile) async {
    final player = AudioPlayer();  
    try {
      await player.setAsset('assets/$soundFile'); 
      await player.play();  
    } catch (e) {
      print("Error playing sound: $e");  
    }
  }

  @override
  void dispose() {
    _controller.dispose();  
    _backgroundPlayer.dispose();  
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
          onTapUp: (details) => _handleTap(details.localPosition),  
          child: Stack(
            children: [
              ...List.generate(lanternImages.length, (index) {
                return Positioned(
                  left: _positions[index].dx,
                  top: _positions[index].dy,
                  child: Image.asset(lanternImages[index], width: 50, height: 50),   
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
               if (_showJumpScare)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.8),  
                    child: Center(
                      child: Image.asset('assets/sc.jpg'),  
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
