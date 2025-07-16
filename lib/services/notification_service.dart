import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  NotificationService();

  // final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int workoutReminder1Id = 1;
  static const int workoutReminder2Id = 2;
  static const int workoutReminder3Id = 3;
  static const int muscleRecoveryBaseId = 100;

  Future<void> initialize() async {
    // Initialize timezone
    // tz.initializeTimeZones();

    // Initialize notifications
    // const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    // const iosSettings = DarwinInitializationSettings(
    //   requestAlertPermission: true,
    //   requestBadgePermission: true,
    //   requestSoundPermission: true,
    // );

    // const initSettings = InitializationSettings(
    //   android: androidSettings,
    //   iOS: iosSettings,
    // );

    // await _notifications.initialize(
    //   initSettings,
    //   onDidReceiveNotificationResponse: _onNotificationTapped,
    // );

    // Request permissions
    // final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
    //     AndroidFlutterLocalNotificationsPlugin>();
    // if (androidPlugin != null) {
    //   // Note: requestPermission() is not available in this version
    //   // Permissions are handled automatically by the plugin
    // }
  }

  void _onNotificationTapped(dynamic response) {
    // Handle notification tap - could navigate to specific screens
    debugPrint('Notification tapped: $response');
  }

  // Schedule daily workout reminders (3 times per day)
  Future<void> scheduleWorkoutReminders() async {
    // Cancel existing workout reminders
    // await _notifications.cancel(workoutReminder1Id);
    // await _notifications.cancel(workoutReminder2Id);
    // await _notifications.cancel(workoutReminder3Id);

    // final now = DateTime.now();
    // final today = DateTime(now.year, now.month, now.day);

    // // Morning reminder (8:00 AM)
    // final morningTime = today.add(const Duration(hours: 8));
    // if (morningTime.isAfter(now)) {
    //   await _scheduleWorkoutReminder(
    //     workoutReminder1Id,
    //     morningTime,
    //     'Morning Workout Reminder',
    //     'Time to start your day strong! 💪',
    //   );
    // }

    // // Afternoon reminder (2:00 PM)
    // final afternoonTime = today.add(const Duration(hours: 14));
    // if (afternoonTime.isAfter(now)) {
    //   await _scheduleWorkoutReminder(
    //     workoutReminder2Id,
    //     afternoonTime,
    //     'Afternoon Workout Reminder',
    //     'Perfect time for a workout break! 🏋️',
    //   );
    // }

    // // Evening reminder (7:00 PM)
    // final eveningTime = today.add(const Duration(hours: 19));
    // if (eveningTime.isAfter(now)) {
    //   await _scheduleWorkoutReminder(
    //     workoutReminder3Id,
    //     eveningTime,
    //     'Evening Workout Reminder',
    //     'End your day with a great workout! 🔥',
    //   );
    // }

    // // Schedule for tomorrow if all today's times have passed
    // if (eveningTime.isBefore(now)) {
    //   final tomorrow = today.add(const Duration(days: 1));
      
    //   await _scheduleWorkoutReminder(
    //     workoutReminder1Id,
    //     tomorrow.add(const Duration(hours: 8)),
    //     'Morning Workout Reminder',
    //     'Time to start your day strong! 💪',
    //   );
      
    //   await _scheduleWorkoutReminder(
    //     workoutReminder2Id,
    //     tomorrow.add(const Duration(hours: 14)),
    //     'Afternoon Workout Reminder',
    //     'Perfect time for a workout break! 🏋️',
    //   );
      
    //   await _scheduleWorkoutReminder(
    //     workoutReminder3Id,
    //     tomorrow.add(const Duration(hours: 19)),
    //     'Evening Workout Reminder',
    //     'End your day with a great workout! 🔥',
    //   );
    // }
  }

  Future<void> _scheduleWorkoutReminder(
    int id,
    DateTime scheduledTime,
    String title,
    String body,
  ) async {
    // await _notifications.zonedSchedule(
    //   id,
    //   title,
    //   body,
    //   tz.TZDateTime.from(scheduledTime, tz.local),
    //   const NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'workout_reminders',
    //       'Workout Reminders',
    //       channelDescription: 'Daily workout reminders',
    //       importance: Importance.high,
    //       priority: Priority.high,
    //       icon: '@mipmap/ic_launcher',
    //     ),
    //     iOS: DarwinNotificationDetails(
    //       presentAlert: true,
    //       presentBadge: true,
    //       presentSound: true,
    //     ),
    //   ),
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   matchDateTimeComponents: DateTimeComponents.time,
    // );
  }

  // Schedule muscle recovery notification (48 hours after workout)
  Future<void> scheduleMuscleRecoveryNotification(String muscleGroup, DateTime workoutTime) async {
    // final recoveryTime = workoutTime.add(const Duration(hours: 48));
    // final notificationId = muscleRecoveryBaseId + muscleGroup.hashCode;

    // // Cancel existing notification for this muscle group
    // await _notifications.cancel(notificationId);

    // // Only schedule if recovery time is in the future
    // if (recoveryTime.isAfter(DateTime.now())) {
    //   await _notifications.zonedSchedule(
    //     notificationId,
    //     'Muscle Recovery Complete! 💪',
    //     'Your $muscleGroup is ready for another workout!',
    //     tz.TZDateTime.from(recoveryTime, tz.local),
    //     const NotificationDetails(
    //       android: AndroidNotificationDetails(
    //         'muscle_recovery',
    //         'Muscle Recovery',
    //         channelDescription: 'Muscle recovery notifications',
    //         importance: Importance.high,
    //         priority: Priority.high,
    //         icon: '@mipmap/ic_launcher',
    //       ),
    //       iOS: DarwinNotificationDetails(
    //         presentAlert: true,
    //         presentBadge: true,
    //         presentSound: true,
    //       ),
    //     ),
    //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   );
    // }
  }

  // Schedule recovery notifications for all worked muscles
  Future<void> scheduleRecoveryNotificationsForWorkout(List<dynamic> exercises) async {
    // final now = DateTime.now();
    // final workedMuscles = <String>{};

    // for (final exercise in exercises) {
    //   workedMuscles.addAll(exercise.muscleGroups);
    // }

    // for (final muscle in workedMuscles) {
    //   await scheduleMuscleRecoveryNotification(muscle, now);
    // }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    // await _notifications.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    // await _notifications.cancel(id);
  }

  // Get pending notifications
  Future<List<dynamic>> getPendingNotifications() async {
    // return await _notifications.pendingNotificationRequests();
    return [];
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    // final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
    //     AndroidFlutterLocalNotificationsPlugin>();
    // if (androidPlugin != null) {
    //   return await androidPlugin.areNotificationsEnabled() ?? false;
    // }
    return true; // Assume enabled for iOS
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    // final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
    //     AndroidFlutterLocalNotificationsPlugin>();
    // if (androidPlugin != null) {
    //   // Note: requestPermission() is not available in this version
    //   // Permissions are handled automatically by the plugin
    //   return await androidPlugin.areNotificationsEnabled() ?? false;
    // }
    return true; // Assume granted for iOS
  }
} 