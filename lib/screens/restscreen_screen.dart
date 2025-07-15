import 'package:flutter/material.dart';
import 'dart:async';
import '../games/chess_puzzle.dart';

class RestScreen extends StatefulWidget {
  final int duration;
  final String exerciseName;

  const RestScreen({
    super.key,
    required this.duration,
    required this.exerciseName,
  });

  @override
  State<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends State<RestScreen> with TickerProviderStateMixin {
  late ValueNotifier<int> timeRemainingNotifier;
  late ValueNotifier<String> selectedGameNotifier;
  Timer? restTimer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    timeRemainingNotifier = ValueNotifier<int>(widget.duration);
    selectedGameNotifier = ValueNotifier<String>('none');
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.duration),
    );
    
    _startRestTimer();
    _animationController.forward();
  }

  void _startRestTimer() {
    restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      timeRemainingNotifier.value--;
      
      if (timeRemainingNotifier.value <= 0) {
        timer.cancel();
        _finishRest();
      }
    });
  }

  void _finishRest() {
    restTimer?.cancel();
    Navigator.pop(context);
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: timeRemainingNotifier,
      builder: (context, timeRemaining, child) {
        final progress = (widget.duration - timeRemaining) / widget.duration;
        
        return ValueListenableBuilder<String>(
          valueListenable: selectedGameNotifier,
          builder: (context, selectedGame, child) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Rest Time'),
                backgroundColor: Colors.orange,
                automaticallyImplyLeading: false, // Remove back button
              ),
              body: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                                         colors: [
                       Colors.orange.withValues(alpha: 0.8),
                       Colors.orange.withValues(alpha: 0.4),
                     ],
                  ),
                ),
                child: selectedGame == 'none' 
                  ? _buildGameSelection(timeRemaining)
                    : selectedGame == 'chess'
                      ? _buildChessPuzzleGame(timeRemaining)
                      : _buildDefaultRest(timeRemaining, progress),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGameSelection(int timeRemaining) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Timer Display
          RepaintBoundary(
            child: Text(
              _formatTime(timeRemaining),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Rest Time - Choose Activity',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Game Selection Cards
          Row(
            children: [
              Expanded(
                child: _buildGameCard(
                  '♛',
                  'Chess Puzzles',
                  'Solve tactics!',
                  () => selectedGameNotifier.value = 'chess',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Just Rest Option
          SizedBox(
            width: double.infinity,
            child: _buildGameCard(
              '😌',
              'Just Rest',
              'Relax and breathe',
              () => selectedGameNotifier.value = 'rest',
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Skip Rest Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _finishRest,
              icon: const Icon(Icons.skip_next),
              label: const Text('Skip Rest'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                side: const BorderSide(color: Colors.white, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard(String emoji, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: RepaintBoundary(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
                         color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
                         border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultRest(int timeRemaining, double progress) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Rest Icon
          const Icon(
            Icons.hourglass_bottom,
            size: 120,
            color: Colors.white,
          ),
          
          const SizedBox(height: 32),
          
          // Rest Title
          const Text(
            'Rest Time',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Exercise Name
          Text(
            'After: ${widget.exerciseName}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          // Timer Display
          Text(
            _formatTime(timeRemaining),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Progress Bar
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white.withValues(alpha: 0.3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Back to Games Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => selectedGameNotifier.value = 'none',
              icon: const Icon(Icons.games),
              label: const Text('Play Games'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Skip Rest Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _finishRest,
              icon: const Icon(Icons.skip_next),
              label: const Text('Skip Rest'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                side: const BorderSide(color: Colors.white, width: 1),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Motivational Text
          Text(
            timeRemaining > 30 
              ? 'Take deep breaths and hydrate 💪'
              : timeRemaining > 10
                ? 'Get ready for the next set! 🔥'
                : 'Almost ready... 3, 2, 1! 🚀',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChessPuzzleGame(int timeRemaining) {
    return ChessPuzzleGame(
      timeRemaining: timeRemaining,
      onFinishRest: _finishRest,
    );
  }

  @override
  void dispose() {
    restTimer?.cancel();
    _animationController.dispose();
    timeRemainingNotifier.dispose();
    selectedGameNotifier.dispose();
    super.dispose();
  }
}
