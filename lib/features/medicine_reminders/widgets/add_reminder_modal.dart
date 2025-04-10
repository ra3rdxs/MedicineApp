import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder.dart';
import '../../../core/theme/app_theme.dart';

class AddReminderModal extends StatefulWidget {
  final MedicineReminder? reminder;

  const AddReminderModal({super.key, this.reminder});

  @override
  State<AddReminderModal> createState() => _AddReminderModalState();
}

class _AddReminderModalState extends State<AddReminderModal> {
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _notesController = TextEditingController();

  late TimeOfDay _selectedTime;
  late DateTime _selectedDate;
  late String _reminderId;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();

    // If we have an existing reminder, populate the form with its data
    if (widget.reminder != null) {
      _isEditing = true;
      _reminderId = widget.reminder!.id;
      _medicineNameController.text = widget.reminder!.medicineName;
      _dosageController.text = widget.reminder!.dosage;
      _notesController.text = widget.reminder!.notes;
      _selectedTime = widget.reminder!.time;
      _selectedDate = widget.reminder!.date;
    } else {
      _reminderId = DateTime.now().millisecondsSinceEpoch.toString();
      _selectedTime = TimeOfDay.now();
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    _dosageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  void _saveReminder() {
    if (_formKey.currentState!.validate()) {
      final reminder = MedicineReminder(
        id: _reminderId,
        medicineName: _medicineNameController.text.trim(),
        time: _selectedTime,
        date: _selectedDate,
        dosage: _dosageController.text.trim(),
        notes: _notesController.text.trim(),
      );

      Navigator.of(context).pop(reminder);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: keyboardSpace,
        top: 16,
        left: 24,
        right: 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.medication_rounded,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _isEditing ? 'Edit Medicine Reminder' : 'Add Medicine Reminder',
                      style: AppTheme.subheadingStyle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Form fields
              TextFormField(
                controller: _medicineNameController,
                decoration: AppTheme.inputDecoration('Medicine Name', Icons.medication_rounded),
                style: AppTheme.bodyStyle,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: AppTheme.inputDecoration('Date', Icons.calendar_today_rounded),
                        child: Text(
                          DateFormat.yMMMd().format(_selectedDate),
                          style: AppTheme.bodyStyle,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectTime,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: AppTheme.inputDecoration('Time', Icons.access_time_rounded),
                        child: Text(
                          _formatTime(_selectedTime),
                          style: AppTheme.bodyStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _dosageController,
                decoration: AppTheme.inputDecoration(
                  'Dosage (optional)',
                  Icons.medical_information_rounded,
                ).copyWith(
                  hintText: 'e.g. 1 pill, 5ml, etc.',
                  hintStyle: TextStyle(color: AppTheme.textLightColor),
                ),
                style: AppTheme.bodyStyle,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notesController,
                decoration: AppTheme.inputDecoration('Notes (optional)', Icons.note_rounded),
                style: AppTheme.bodyStyle,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: AppTheme.secondaryButtonStyle,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saveReminder,
                      style: AppTheme.primaryButtonStyle,
                      child: Text(_isEditing ? 'Update Reminder' : 'Save Reminder'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }
}
