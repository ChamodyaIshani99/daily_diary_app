import 'package:flutter/material.dart';
import '../core/services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSavedTime();
  }

  Future<void> _loadSavedTime() async {
    final savedTime = await NotificationService.getSavedNotificationTime();
    setState(() {
      _selectedTime = savedTime;
    });
  }

  // Time Picker Dialog එක පෙන්වීම
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });

      // අලුත් Time එකට Schedule කිරීම
      await NotificationService.scheduleDailyNotification(
        hour: picked.hour,
        minute: picked.minute,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Reminder set for ${_selectedTime.format(context)}',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.deepPurple.shade100,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications_active, color: Colors.deepPurple),
              title: const Text('Daily Reminder Time'),
              subtitle: Text('Set time: ${_selectedTime.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: _pickTime,
            ),
          ),
        ],
      ),
    );
  }
}