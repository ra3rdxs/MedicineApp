// Import Flutter's material package for UI components
import 'package:flutter/material.dart';
// Import app theme for consistent styling
import '../../../core/theme/app_theme.dart';
// Import the reminder model
import '../models/reminder.dart';
// Import intl package for date and time formatting
import 'package:intl/intl.dart';

// ReminderCard widget - Displays a single medicine reminder in a card format
// This stateless widget shows reminder details and provides options to edit, delete, or test the reminder
class ReminderCard extends StatelessWidget {
  // The reminder data to display
  final MedicineReminder reminder;
  // Callback function when the edit action is triggered
  final VoidCallback onEdit;
  // Callback function when the delete action is triggered
  final VoidCallback onDelete;
  // Callback function when the test notification action is triggered
  final VoidCallback onTest;

  // Constructor that initializes the ReminderCard widget
  // All parameters are required to properly display and interact with the reminder
  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onEdit,
    required this.onDelete,
    required this.onTest,
  });

  // Helper method to format TimeOfDay to a human-readable string (e.g., "8:30 AM")
  // Uses the intl package's DateFormat for consistent formatting
  String _formatTime(TimeOfDay time) {
    // Create a DateTime object with the current date and the reminder's time
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    // Format the time using the locale-aware time formatter
    return DateFormat.jm().format(dt);
  }

  // Helper method to format DateTime to a human-readable string
  // Returns "Today", "Tomorrow", or the formatted date (e.g., "Jan 15, 2023")
  String _formatDate(DateTime date) {
    // Get the current date for comparison
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    // Strip time component from the reminder date for comparison
    final reminderDate = DateTime(date.year, date.month, date.day);

    // Return appropriate string based on date comparison
    if (reminderDate == today) {
      return 'Today';
    } else if (reminderDate == tomorrow) {
      return 'Tomorrow';
    } else {
      // Format the date using the locale-aware date formatter
      return DateFormat.yMMMd().format(date);
    }
  }

  @override
  // Build the UI for the reminder card
  Widget build(BuildContext context) {
    return Container(
      // Add margin around the card
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // Apply card decoration with a border
      decoration: AppTheme.cardDecoration.copyWith(
        border: Border.all(color: AppTheme.dividerColor, width: 1),
      ),
      // Clip the card contents to the rounded corners
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        // Material widget for ink effects (ripple on tap)
        child: Material(
          color: Colors.transparent,
          // InkWell for tap feedback and handling edit action
          child: InkWell(
            onTap: onEdit,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colored header section with medicine name and menu
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  // Apply gradient background to the header
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: Row(
                    children: [
                      // Medicine icon
                      const Icon(
                        Icons.medication_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      // Medicine name with overflow handling
                      Expanded(
                        child: Text(
                          reminder.medicineName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Popup menu for actions (edit, delete, test)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        // Handle menu item selection
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit();
                          } else if (value == 'delete') {
                            onDelete();
                          } else if (value == 'test') {
                            onTest();
                          }
                        },
                        // Build menu items
                        itemBuilder: (context) => [
                          // Edit option
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          // Delete option (with warning color)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: AppTheme.accentColor,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: AppTheme.accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Test notification option
                          const PopupMenuItem(
                            value: 'test',
                            child: Row(
                              children: [
                                Icon(Icons.notifications),
                                SizedBox(width: 8),
                                Text('Test'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Card content section with reminder details
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row with time and date chips
                      Row(
                        children: [
                          // Time chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            // Light background with rounded corners
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLightColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Clock icon
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                // Formatted time text
                                Text(
                                  _formatTime(reminder.time),
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Date chip
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            // Light background with rounded corners
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryLightColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Calendar icon
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: AppTheme.secondaryColor,
                                ),
                                const SizedBox(width: 4),
                                // Formatted date text
                                Text(
                                  _formatDate(reminder.date),
                                  style: TextStyle(
                                    color: AppTheme.secondaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Conditionally show dosage if available
                      if (reminder.dosage.isNotEmpty) ...[  
                        const SizedBox(height: 12),
                        // Dosage information row
                        Row(
                          children: [
                            // Pill icon
                            Icon(
                              Icons.local_hospital_rounded,
                              size: 16,
                              color: AppTheme.textSecondaryColor,
                            ),
                            const SizedBox(width: 8),
                            // Dosage label
                            Text(
                              'Dosage:',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Dosage value
                            Expanded(
                              child: Text(
                                reminder.dosage,
                                style: TextStyle(
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Conditionally show notes if available
                      if (reminder.notes.isNotEmpty) ...[  
                        const SizedBox(height: 12),
                        // Notes information row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Notes icon
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.notes_rounded,
                                size: 16,
                                color: AppTheme.textSecondaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Notes label
                            Text(
                              'Notes:',
                              style: TextStyle(
                                color: AppTheme.textSecondaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Notes value with expanded width
                            Expanded(
                              child: Text(
                                reminder.notes,
                                style: TextStyle(
                                  color: AppTheme.textPrimaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}