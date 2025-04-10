// Import Flutter's material package for UI components
import 'package:flutter/material.dart';
// Import the app theme for consistent styling
import '../../../core/theme/app_theme.dart';

// EmptyReminderState widget - Displays when no medicine reminders exist
// This stateless widget shows a friendly message and a button to add a new reminder
class EmptyReminderState extends StatelessWidget {
  // Callback function that will be executed when the add button is pressed
  final VoidCallback onAddReminder;

  // Constructor that initializes the EmptyReminderState widget
  // The onAddReminder callback is required to handle the add button press
  const EmptyReminderState({
    super.key,
    required this.onAddReminder,
  });

  @override
  Widget build(BuildContext context) {
    // Center widget aligns all children in the center of the available space
    return Center(
      child: Column(
        // Center the column contents vertically
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular container for the notification icon
          Container(
            padding: const EdgeInsets.all(24),
            // Create a circular container with a light primary color background
            decoration: BoxDecoration(
              color: AppTheme.primaryLightColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            // Notification icon
            child: Icon(
              Icons.notifications_none_rounded,
              size: 80,
              color: AppTheme.primaryColor,
            ),
          ),
          // Vertical spacing
          const SizedBox(height: 24),
          // Main message text
          Text(
            'No medicine reminders yet',
            style: AppTheme.subheadingStyle,
            textAlign: TextAlign.center,
          ),
          // Small vertical spacing
          const SizedBox(height: 8),
          // Subtitle message with horizontal padding
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Add your first medicine reminder to get started',
              style: AppTheme.captionStyle,
              textAlign: TextAlign.center,
            ),
          ),
          // Larger vertical spacing before the button
          const SizedBox(height: 32),
          // Button to add a new reminder
          ElevatedButton.icon(
            onPressed: onAddReminder,
            // Button styling
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Add icon
            icon: const Icon(Icons.add),
            // Button text
            label: const Text('Add Reminder'),
          ),
        ],
      ),
    );
  }
}