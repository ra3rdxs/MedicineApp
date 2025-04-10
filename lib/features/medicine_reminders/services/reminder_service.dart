// Import necessary packages for JSON handling, data persistence, and notifications
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';
import 'notification_service.dart';

// ReminderService class - Manages all operations related to medicine reminders
// This service handles CRUD operations for reminders and coordinates with the notification service
class ReminderService {
  // Key used to store reminders in SharedPreferences
  static const String _remindersKey = 'medicine_reminders';
  // Instance of NotificationService to handle reminder notifications
  // Made accessible from outside for direct access when needed
  final NotificationService notificationService = NotificationService();

  // Initialize notification service
  // This method must be called before using notification features
  Future<void> init() async {
    await notificationService.initialize();
  }

  // Retrieves all saved reminders from SharedPreferences
  // Returns an empty list if no reminders are found
  Future<List<MedicineReminder>> getReminders() async {
    // Get instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Retrieve the JSON string using the reminders key
    final String? reminderJson = prefs.getString(_remindersKey);

    // If no data exists, return an empty list
    if (reminderJson == null) {
      return [];
    }

    // Decode the JSON string into a list of dynamic objects
    List<dynamic> decodedList = jsonDecode(reminderJson);
    // Convert each item in the list to a MedicineReminder object and return as a list
    return decodedList.map((item) => MedicineReminder.fromJson(item)).toList();
  }

  // Adds a new reminder to storage and schedules a notification
  Future<void> addReminder(MedicineReminder reminder) async {
    // Get current list of reminders
    final reminders = await getReminders();
    // Add the new reminder to the list
    reminders.add(reminder);
    // Save the updated list
    await _saveReminders(reminders);

    // Create a DateTime object for the notification by combining date and time
    final DateTime notificationTime = DateTime(
      reminder.date.year,
      reminder.date.month,
      reminder.date.day,
      reminder.time.hour,
      reminder.time.minute,
    );

    // Only schedule notification if the time is in the future
    if (notificationTime.isAfter(DateTime.now())) {
      await notificationService.scheduleNotification(
        // Use hashCode of ID to ensure unique notification ID
        id: reminder.id.hashCode,
        title: 'Medicine Reminder',
        // Include dosage in notification body if available
        body:
            'Time to take ${reminder.medicineName}${reminder.dosage.isNotEmpty ? ' - ${reminder.dosage}' : ''}',
        scheduledDate: notificationTime,
      );
    } else {
      // Log if notification time is in the past (won't be scheduled)
      print('Notification time is in the past: $notificationTime');
    }
  }

  // Updates an existing reminder and reschedules its notification
  Future<void> updateReminder(MedicineReminder updatedReminder) async {
    // Get current list of reminders
    final reminders = await getReminders();
    // Find the index of the reminder to update
    final index = reminders.indexWhere((r) => r.id == updatedReminder.id);

    // Only proceed if the reminder exists
    if (index != -1) {
      // Replace the old reminder with the updated one
      reminders[index] = updatedReminder;
      // Save the updated list
      await _saveReminders(reminders);

      // Cancel the previous notification for this reminder
      await notificationService.cancelNotification(updatedReminder.id.hashCode);

      // Create a DateTime object for the new notification time
      final DateTime notificationTime = DateTime(
        updatedReminder.date.year,
        updatedReminder.date.month,
        updatedReminder.date.day,
        updatedReminder.time.hour,
        updatedReminder.time.minute,
      );

      // Only schedule notification if the time is in the future
      if (notificationTime.isAfter(DateTime.now())) {
        await notificationService.scheduleNotification(
          id: updatedReminder.id.hashCode,
          title: 'Medicine Reminder',
          body:
              'Time to take ${updatedReminder.medicineName}${updatedReminder.dosage.isNotEmpty ? ' - ${updatedReminder.dosage}' : ''}',
          scheduledDate: notificationTime,
        );
      } else {
        // Log if notification time is in the past
        print('Updated notification time is in the past: $notificationTime');
      }
    }
  }

  // Deletes a reminder and cancels its notification
  Future<void> deleteReminder(String id) async {
    // Get current list of reminders
    final reminders = await getReminders();
    // Remove the reminder with the matching ID
    reminders.removeWhere((reminder) => reminder.id == id);
    // Save the updated list
    await _saveReminders(reminders);

    // Cancel the notification for this reminder
    await notificationService.cancelNotification(id.hashCode);
  }

  // Private method to save reminders to SharedPreferences
  Future<void> _saveReminders(List<MedicineReminder> reminders) async {
    // Get instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Convert each reminder to JSON and collect in a list
    final List<Map<String, dynamic>> reminderList =
        reminders.map((reminder) => reminder.toJson()).toList();
    // Encode the list to a JSON string
    final String encodedList = jsonEncode(reminderList);
    // Save the JSON string to SharedPreferences
    await prefs.setString(_remindersKey, encodedList);
  }
}
