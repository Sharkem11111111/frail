import 'package:flutter/material.dart';
import 'userinfocard_screen.dart';
import 'profilefeaturecard_screen.dart';
import 'fitnessscoresection_screen.dart';
import 'caloriescreen_screen.dart';
import 'sleepscreen_screen.dart';
import 'equipmentsettingsscreen_screen.dart';
import 'gamesmenuscreen_screen.dart';
import 'notificationsettingsscreen_screen.dart';
import 'package:frail/providers/fitness_data_provider.dart';
import 'package:provider/provider.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset App Data'),
          content: const Text(
            'Choose your reset option:\n\n'
            '🔄 **Soft Reset**: Clear all data but keep app settings\n'
            '🗑️ **Hard Reset**: Complete wipe - like fresh install\n\n'
            'Both options will clear:\n'
            '• Workout history\n'
            '• Progress tracking\n'
            '• Nutrition data\n'
            '• Equipment settings\n'
            '• Notification preferences\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetAppData(context, isHardReset: true); // Always do a full wipe
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange,
              ),
              child: const Text('Soft Reset'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetAppData(context, isHardReset: true);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Hard Reset'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetAppData(BuildContext context, {required bool isHardReset}) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text('Resetting app data...'),
              ],
            ),
          );
        },
      );

      // Always perform a full wipe
      await context.read<FitnessDataProvider>().hardResetToFirstTimeUser();

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('App data reset successfully! You can now start fresh.'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
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

  void _showManualWipeInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Manual Wipe Instructions'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'If the app reset doesn\'t work, you can manually wipe all data:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  '📱 iPhone/iPad:\n'
                  '1. Go to Settings > General > iPhone Storage\n'
                  '2. Find "Frail" app\n'
                  '3. Tap "Offload App" or "Delete App"\n'
                  '4. Reinstall from App Store\n\n'
                  '🤖 Android:\n'
                  '1. Go to Settings > Apps > Frail\n'
                  '2. Tap "Storage & cache"\n'
                  '3. Tap "Clear Storage" and "Clear Cache"\n'
                  '4. Or uninstall and reinstall the app\n\n'
                  '💻 Alternative Method:\n'
                  '1. Delete the app completely\n'
                  '2. Restart your device\n'
                  '3. Reinstall the app fresh',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
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
            ProfileFeatureCard(
              title: 'Manual Wipe Instructions',
              subtitle: 'How to completely wipe app data',
              icon: Icons.help_outline,
              color: Colors.orange,
              onTap: () => _showManualWipeInstructions(context),
            ),
          ],
        ),
      ),
    );
  }
}
