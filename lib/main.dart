import 'package:flutter/material.dart';

import 'data/fitness_data_manager.dart';
import 'services/notification_service.dart';

// Screen imports
import 'screens/workoutscreen_screen.dart';
import 'screens/historyscreen_screen.dart';
import 'screens/progressscreen_screen.dart';
import 'screens/profilescreen_screen.dart';
import 'screens/aitrainerchatscreen_screen.dart';

// PERFORMANCE OPTIMIZATIONS APPLIED:
// 1. Split components into separate files to reduce main.dart size
// 2. Chess: RepaintBoundary, optimized GridView, minimal cache
// 3. Rest: Loading states, mounted checks, reduced setState frequency
// 4. General: Performance imports, better memory management

void main() async {
  // Performance optimizations
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  runApp(const FrailApp());
}

class FrailApp extends StatelessWidget {
  const FrailApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frail - Strength Training',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Modern indigo
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final FitnessDataManager _dataManager = FitnessDataManager();
  
  final List<Widget> _screens = [
    const WorkoutScreen(),
    const HistoryScreen(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    await _dataManager.loadUserData();
    setState(() {}); // Refresh UI after loading data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AiTrainerChatScreen()),
          );
        },
        icon: const Icon(Icons.smart_toy),
        label: const Text('AI Trainer'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
