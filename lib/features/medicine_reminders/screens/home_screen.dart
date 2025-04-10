import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../services/reminder_service.dart';
import '../../auth/services/auth_service.dart';
import '../widgets/add_reminder_modal.dart';
import '../widgets/reminder_card.dart';
import '../widgets/empty_state.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ReminderService _reminderService = ReminderService();
  final AuthService _authService = AuthService();
  List<MedicineReminder> _reminders = [];
  String _username = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkNotificationPermissions();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _reminderService.init();
      final reminders = await _reminderService.getReminders();
      final user = await _authService.getCurrentUser();

      setState(() {
        _reminders = reminders;
        _username = user?.username ?? 'User';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _checkNotificationPermissions() async {
    final hasPermission = await _reminderService.notificationService
        .checkAndRequestPermissions(context);
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Notification permission is required for medicine reminders',
            ),
          ),
        );
      }
    }
  }

  Future<void> _addReminder() async {
    final result = await showModalBottomSheet<MedicineReminder>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const AddReminderModal(),
    );

    if (result != null) {
      try {
        await _reminderService.addReminder(result);
        await _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding reminder: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _deleteReminder(MedicineReminder reminder) async {
    try {
      await _reminderService.deleteReminder(reminder.id);
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Reminder deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting reminder: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _editReminder(MedicineReminder reminder) async {
    final result = await showModalBottomSheet<MedicineReminder>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AddReminderModal(reminder: reminder),
    );

    if (result != null) {
      try {
        await _reminderService.updateReminder(result);
        await _loadData();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Reminder updated')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating reminder: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _testNotification(MedicineReminder reminder) async {
    try {
      final hasPermission = await _reminderService.notificationService
          .checkAndRequestPermissions(context);

      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot send notification: Permission denied'),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sending test notification...')),
      );

      final notificationService = _reminderService.notificationService;
      await notificationService.initialize();

      final testId = DateTime.now().millisecondsSinceEpoch % 10000;

      await notificationService.showImmediateNotification(
        id: testId,
        title: 'TEST: ${reminder.medicineName}',
        body: 'This is a test notification. Dosage: ${reminder.dosage}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification sent! Check your notifications.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending test notification: ${e.toString()}'),
        ),
      );
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final reminderDate = DateTime(date.year, date.month, date.day);

    if (reminderDate == today) {
      return 'Today';
    } else if (reminderDate == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine Reminders'),
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $_username',
                          style: AppTheme.headingStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage your medicine reminders',
                          style: AppTheme.captionStyle,
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: _reminders.isEmpty
                        ? EmptyReminderState(onAddReminder: _addReminder)
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(top: 8, bottom: 80),
                            itemCount: _reminders.length,
                            itemBuilder: (context, index) {
                              final reminder = _reminders[index];
                              return Dismissible(
                                key: Key(reminder.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 24.0),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: const Icon(
                                    Icons.delete_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                onDismissed: (_) => _deleteReminder(reminder),
                                child: ReminderCard(
                                  reminder: reminder,
                                  onEdit: () => _editReminder(reminder),
                                  onDelete: () => _deleteReminder(reminder),
                                  onTest: () => _testNotification(reminder),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addReminder,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Reminder'),
        elevation: 4,
      ),
    );
  }
}
