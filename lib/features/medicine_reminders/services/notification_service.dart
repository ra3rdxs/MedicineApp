import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'dart:convert';
import '../models/reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static NotificationService? _instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  
  // Timer for checking reminders
  Timer? _reminderCheckTimer;
  
  // Constants
  static const String _remindersKey = 'medicine_reminders';

  // Singleton pattern
  factory NotificationService() {
    _instance ??= NotificationService._internal();
    return _instance!;
  }

  NotificationService._internal();

  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone
    tz_data.initializeTimeZones();
    
    // Configure notification settings to handle exact timing
    await _configureLocalTimeZone();
    
    // Register background handlers for notifications
    await _registerBackgroundHandlers();
    
    // Start the timer to check for reminders that match current time
    _startReminderCheckTimer();

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medicine_reminder_channel',
      'Medicine Reminders',
      description: 'Notifications for medicine reminders',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      showBadge: true,
    );

    // Create the notification channel on Android
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Initialize notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification clicked: ${response.payload}');
      },
    );

    // Request permission on iOS
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Note: Android 13+ permissions are requested in the AndroidManifest.xml

    _isInitialized = true;
    print('Notification service initialized successfully');
  }
  
  // Configure local time zone for accurate scheduling
  Future<void> _configureLocalTimeZone() async {
    try {
      // Get the local timezone
      final String timeZoneName = tz.local.name;
      // Set the default timezone
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print('Local timezone configured: $timeZoneName');
    } catch (e) {
      print('Error configuring local timezone: $e');
      // Fallback to UTC if there's an error
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }
  
  // Register background handlers for notifications
  Future<void> _registerBackgroundHandlers() async {
    try {
      // Set up background message handler for Android
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
                
        // Enable exact alarms permission for Android
        await androidImplementation?.requestExactAlarmsPermission();
        
        // Configure notification to be shown when app is in background
        await androidImplementation?.requestNotificationsPermission();
      }
      
      // Configure iOS background notification handling
      if (Platform.isIOS) {
        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: true,
            );
      }
      
      print('Background notification handlers registered');
    } catch (e) {
      print('Error registering background handlers: $e');
    }
  }
  
  // Create a TZDateTime for scheduling notifications at exact times
  tz.TZDateTime _createScheduledDate(int year, int month, int day, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, year, month, day, hour, minute);
    
    // If the scheduled date is before now, schedule it for the next day
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }

  // Start a timer that checks for reminders matching the current time
  void _startReminderCheckTimer() {
    // Cancel any existing timer
    _reminderCheckTimer?.cancel();
    
    // Check immediately on startup
    _checkForDueReminders();
    
    // Set up a timer to check every minute
    _reminderCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkForDueReminders();
    });
    
    print('Reminder check timer started');
  }
  
  // Check if any reminders match the current time and trigger notifications
  Future<void> _checkForDueReminders() async {
    try {
      final now = DateTime.now();
      final currentHour = now.hour;
      final currentMinute = now.minute;
      
      print('Checking for due reminders at $currentHour:$currentMinute');
      
      // Get all reminders from SharedPreferences
      final reminders = await _getReminders();
      
      // Check each reminder
      for (final reminder in reminders) {
        // Check if the reminder time matches the current time
        if (reminder.time.hour == currentHour && reminder.time.minute == currentMinute) {
          // Check if the reminder is for today or a future date
          final reminderDate = DateTime(
            reminder.date.year,
            reminder.date.month,
            reminder.date.day,
          );
          
          final today = DateTime(
            now.year,
            now.month,
            now.day,
          );
          
          // Only trigger notification if the reminder is for today or in the future
          if (reminderDate.compareTo(today) >= 0) {
            print('Found due reminder: ${reminder.medicineName} at ${reminder.time.hour}:${reminder.time.minute}');
            
            // Show notification
            await showImmediateNotification(
              id: reminder.id.hashCode,
              title: 'Medicine Reminder',
              body: 'Time to take ${reminder.medicineName}${reminder.dosage.isNotEmpty ? ' - ${reminder.dosage}' : ''}',
            );
          }
        }
      }
    } catch (e) {
      print('Error checking for due reminders: $e');
    }
  }
  
  // Get all reminders from SharedPreferences
  Future<List<MedicineReminder>> _getReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? reminderJson = prefs.getString(_remindersKey);
      
      if (reminderJson == null) {
        return [];
      }
      
      List<dynamic> decodedList = json.decode(reminderJson);
      return decodedList.map((item) => MedicineReminder.fromJson(item)).toList();
    } catch (e) {
      print('Error getting reminders: $e');
      return [];
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Ensure the service is initialized
    if (!_isInitialized) {
      await initialize();
    }

    // Print debug information
    print('Attempting to schedule notification:');
    print('ID: $id');
    print('Title: $title');
    print('Body: $body');
    print('Scheduled for: ${scheduledDate.toString()}');

    if (scheduledDate.isBefore(DateTime.now())) {
      // If the scheduled date is in the past, just show the notification immediately
      await showImmediateNotification(id: id, title: title, body: body);
      return;
    }

    try {
      // Create a TZDateTime that exactly matches the scheduled time
      final tz.TZDateTime scheduledTZDateTime = _createScheduledDate(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        scheduledDate.hour,
        scheduledDate.minute,
      );
      
      // Schedule the notification with exact timing
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDateTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_reminder_channel',
            'Medicine Reminders',
            channelDescription: 'Notifications for medicine reminders',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'Medicine Reminder',
            visibility: NotificationVisibility.public,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
            // Ensure notification is delivered exactly on time
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            badgeNumber: 1,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'medicine_reminder_$id',
      );
      print('Notification scheduled successfully for $scheduledDate');
    } catch (e) {
      print('Error scheduling notification: $e');
      // If scheduling fails, attempt to show immediately as a fallback
      await showImmediateNotification(id: id, title: title, body: body);
    }
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // Ensure the service is initialized
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'medicine_reminder_channel',
            'Medicine Reminders',
            channelDescription: 'Notifications for medicine reminders',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'Medicine Reminder',
            visibility: NotificationVisibility.public,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.alarm,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            sound: 'default',
            badgeNumber: 1,
          ),
        ),
        payload: 'medicine_reminder_$id',
      );
      print('Immediate notification sent successfully');
    } catch (e) {
      print('Error showing immediate notification: $e');
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    print('Notification with ID $id canceled');
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    print('All notifications canceled');
  }
  
  // Dispose method to clean up resources
  void dispose() {
    _reminderCheckTimer?.cancel();
    print('Notification service disposed');
  }

  Future<bool> requestPermission() async {
    // Ensure the service is initialized
    if (!_isInitialized) {
      await initialize();
    }

    // For iOS
    if (Platform.isIOS) {
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    // For Android
    else if (Platform.isAndroid) {
      // Android 13+ (API level 33) requires explicit permission request
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      return grantedNotificationPermission ?? false;
    }

    return false;
  }

  // Check if notifications are permitted
  Future<bool> areNotificationsPermitted() async {
    if (Platform.isIOS) {
      // iOS permission check - we'll need to check directly
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: false, badge: false, sound: false);

      // If null or false, permissions are not granted
      return result ?? false;
    } else if (Platform.isAndroid) {
      // Android permission check
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      final bool? areEnabled =
          await androidImplementation?.areNotificationsEnabled();
      return areEnabled ?? false;
    }
    return false;
  }

  // This method checks if permissions are granted and requests them if they aren't
  Future<bool> checkAndRequestPermissions(BuildContext context) async {
    final bool hasPermission = await areNotificationsPermitted();

    if (!hasPermission) {
      // Show dialog explaining why we need permissions
      final bool shouldRequest =
          await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Notification Permission'),
                  content: const Text(
                    'To receive medicine reminders, you need to allow notifications. Would you like to enable notifications?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No, thanks'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Yes, enable'),
                    ),
                  ],
                ),
          ) ??
          false;

      if (shouldRequest) {
        return await requestPermission();
      }
      return false;
    }

    return true;
  }
}
