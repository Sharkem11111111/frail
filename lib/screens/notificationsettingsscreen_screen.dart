import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _workoutRemindersEnabled = true;
  bool _muscleRecoveryEnabled = true;
  bool _notificationsEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = await _notificationService.areNotificationsEnabled();
    setState(() {
      _workoutRemindersEnabled = prefs.getBool('workout_reminders_enabled') ?? true;
      _muscleRecoveryEnabled = prefs.getBool('muscle_recovery_enabled') ?? true;
      _notificationsEnabled = notificationsEnabled;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('workout_reminders_enabled', _workoutRemindersEnabled);
    await prefs.setBool('muscle_recovery_enabled', _muscleRecoveryEnabled);
  }

  Future<void> _requestNotificationPermissions() async {
    final granted = await _notificationService.requestPermissions();
    if (granted) {
      setState(() {
        _notificationsEnabled = true;
      });
      
      if (_workoutRemindersEnabled) {
        await _notificationService.scheduleWorkoutReminders();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permissions granted!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permissions denied. Please enable in settings.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _toggleWorkoutReminders(bool value) async {
    setState(() {
      _workoutRemindersEnabled = value;
    });
    
    await _saveSettings();
    
    if (value && _notificationsEnabled) {
      await _notificationService.scheduleWorkoutReminders();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout reminders enabled!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (!value) {
      await _notificationService.cancelNotification(NotificationService.workoutReminder1Id);
      await _notificationService.cancelNotification(NotificationService.workoutReminder2Id);
      await _notificationService.cancelNotification(NotificationService.workoutReminder3Id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Workout reminders disabled.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _toggleMuscleRecovery(bool value) async {
    setState(() {
      _muscleRecoveryEnabled = value;
    });
    
    await _saveSettings();
    
    if (!value) {
      // Cancel all muscle recovery notifications
      final pendingNotifications = await _notificationService.getPendingNotifications();
      for (final notification in pendingNotifications) {
        if (notification.id >= NotificationService.muscleRecoveryBaseId) {
          await _notificationService.cancelNotification(notification.id);
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Muscle recovery notifications disabled.'),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Muscle recovery notifications enabled!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                          color: _notificationsEnabled ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notification Status',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                _notificationsEnabled 
                                  ? 'Notifications are enabled'
                                  : 'Notifications are disabled',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (!_notificationsEnabled) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _requestNotificationPermissions,
                          icon: const Icon(Icons.notifications),
                          label: const Text('Enable Notifications'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Workout Reminders Section
            Text(
              'Workout Reminders',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.fitness_center, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Daily Workout Reminders',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Get reminded 3 times daily to workout',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _workoutRemindersEnabled && _notificationsEnabled,
                          onChanged: _notificationsEnabled ? _toggleWorkoutReminders : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reminder Times:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          _buildReminderTime('🌅 Morning', '8:00 AM'),
                          _buildReminderTime('☀️ Afternoon', '2:00 PM'),
                          _buildReminderTime('🌙 Evening', '7:00 PM'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Muscle Recovery Section
            Text(
              'Muscle Recovery',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Muscle Recovery Alerts',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Get notified when muscles are ready for another workout',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _muscleRecoveryEnabled && _notificationsEnabled,
                          onChanged: _notificationsEnabled ? _toggleMuscleRecovery : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recovery Timeline:',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          _buildRecoveryInfo('⏰ Recovery Time', '48 hours after workout'),
                          _buildRecoveryInfo('💪 Muscle Groups', 'All worked muscles tracked'),
                          _buildRecoveryInfo('🔔 Smart Alerts', 'Only when muscles are ready'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Information Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange),
                        const SizedBox(width: 12),
                        Text(
                          'How It Works',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoItem(
                      'Workout Reminders',
                      'You\'ll receive 3 daily reminders at 8 AM, 2 PM, and 7 PM to help you stay consistent with your fitness routine.',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      'Muscle Recovery',
                      'After completing a workout, the app tracks which muscle groups you worked and notifies you 48 hours later when they\'re ready for another workout.',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      'Smart Scheduling',
                      'Notifications are automatically scheduled and managed based on your workout activity and preferences.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTime(String label, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryInfo(String label, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            info,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
} 