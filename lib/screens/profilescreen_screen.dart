import 'package:flutter/material.dart';
import 'userinfocard_screen.dart';
import 'profilefeaturecard_screen.dart';
import 'fitnessscoresection_screen.dart';
import 'caloriescreen_screen.dart';
import 'sleepscreen_screen.dart';
import 'equipmentsettingsscreen_screen.dart';
import 'gamesmenuscreen_screen.dart';
import 'notificationsettingsscreen_screen.dart';
import '../data/fitness_data_manager.dart';



class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset App Data'),
          content: const Text(
            'This will clear all your data including:\n'
            '• Workout history\n'
            '• Progress tracking\n'
            '• Nutrition data\n'
            '• Equipment settings\n'
            '• Notification preferences\n\n'
            'This action cannot be undone. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetAppData(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetAppData(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Resetting app data...'),
              ],
            ),
          );
        },
      );

      // Reset the data
      await FitnessDataManager().resetToFirstTimeUser();

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('App data reset successfully! You can now start fresh.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Wait a moment for the snackbar to show, then navigate
      await Future.delayed(const Duration(milliseconds: 500));

      // Navigate back to main screen and clear all routes
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();
      
      // Show error message with more details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resetting app data: $e\nPlease try again or restart the app.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      
      print('Reset error details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Section
            // User Information Section
            UserInfoCard(),
            const SizedBox(height: 24),
            
            // Fitness Readiness & Performance Section
            const FitnessScoreSection(),
            const SizedBox(height: 24),
            
            // Features Section
            Text(
              'Health Tracking',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // Feature Cards
            ProfileFeatureCard(
              title: 'Calorie Tracking',
              subtitle: 'Track your daily nutrition',
              icon: Icons.restaurant,
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CalorieScreen()),
              ),
            ),
            const SizedBox(height: 12),
            ProfileFeatureCard(
              title: 'Sleep Tracking',
              subtitle: 'Monitor your rest and recovery',
              icon: Icons.bedtime,
              color: Colors.indigo,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SleepScreen()),
              ),
            ),
            const SizedBox(height: 24),
            
            // Settings Section
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ProfileFeatureCard(
              title: 'Equipment Settings',
              subtitle: 'Manage your available workout gear',
              icon: Icons.fitness_center,
              color: Colors.indigo,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EquipmentSettingsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            ProfileFeatureCard(
              title: 'Games',
              subtitle: 'Practice chess puzzles and mini-games',
              icon: Icons.games,
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GamesMenuScreen()),
              ),
            ),
            const SizedBox(height: 12),
            ProfileFeatureCard(
              title: 'Notification Settings',
              subtitle: 'Manage workout reminders and recovery alerts',
              icon: Icons.notifications,
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            ProfileFeatureCard(
              title: 'App Settings',
              subtitle: 'Preferences and other settings',
              icon: Icons.settings,
              color: Colors.grey,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings coming soon!')),
                );
              },
            ),
            const SizedBox(height: 12),
            ProfileFeatureCard(
              title: 'Reset App Data',
              subtitle: 'Clear all data and start fresh',
              icon: Icons.refresh,
              color: Colors.red,
              onTap: () => _showResetDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
