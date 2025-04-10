// Import Flutter's material package to use TimeOfDay class
import 'package:flutter/material.dart';

// MedicineReminder class - Data model that represents a single medicine reminder
// This class stores all information related to a medicine reminder including
// identification, medicine details, scheduling information, and additional notes
class MedicineReminder {
  // Unique identifier for each reminder
  final String id;
  // Name of the medicine to be taken
  final String medicineName;
  // Time of day when the medicine should be taken
  final TimeOfDay time;
  // Date when the medicine should be taken
  final DateTime date;
  // Dosage information (e.g., "1 pill", "5ml", etc.)
  final String dosage;
  // Additional notes or instructions about the medicine
  final String notes;

  // Constructor that initializes a MedicineReminder object
  // id, medicineName, time, and date are required parameters
  // dosage and notes are optional with empty string defaults
  MedicineReminder({
    required this.id,
    required this.medicineName,
    required this.time,
    required this.date,
    this.dosage = '',
    this.notes = '',
  });

  // Converts the MedicineReminder object to a JSON map
  // This is used when storing the reminder data in shared preferences
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineName': medicineName,
      // Convert TimeOfDay to string format "hour:minute"
      'time': '${time.hour}:${time.minute}',
      // Convert DateTime to ISO 8601 string format
      'date': date.toIso8601String(),
      'dosage': dosage,
      'notes': notes,
    };
  }

  // Factory constructor that creates a MedicineReminder from a JSON map
  // This is used when retrieving reminder data from shared preferences
  factory MedicineReminder.fromJson(Map<String, dynamic> json) {
    // Parse the time string into hour and minute components
    final timeParts = (json['time'] as String).split(':');
    return MedicineReminder(
      id: json['id'],
      medicineName: json['medicineName'],
      // Reconstruct TimeOfDay object from hour and minute
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      // Parse ISO 8601 string back to DateTime
      date: DateTime.parse(json['date']),
      // Use null-aware operators to handle missing values
      dosage: json['dosage'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}
