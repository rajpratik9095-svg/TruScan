import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../config/theme.dart';
import '../../services/supabase_service.dart';
import '../../controllers/auth_controller.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final storage = GetStorage();
  bool _isLoading = true;
  List<Map<String, dynamic>> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    
    final userId = SupabaseService.currentUser?.id;
    if (userId != null) {
      try {
        final response = await SupabaseService.client
            .from('reminders')
            .select()
            .eq('user_id', userId)
            .order('created_at', ascending: false);
        
        setState(() {
          _reminders = List<Map<String, dynamic>>.from(response);
        });
      } catch (e) {
        print('Error loading reminders: $e');
      }
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('reminders'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReminderDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
              ? _buildEmptyState()
              : _buildRemindersList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderDialog(),
        icon: const Icon(Icons.add_alarm),
        label: Text('add_reminder'.tr),
        backgroundColor: AppTheme.primaryGradientStart,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.alarm_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'no_reminders'.tr,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'set_reminder_desc'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddReminderDialog(),
              icon: const Icon(Icons.add_alarm),
              label: Text('add_reminder'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGradientStart,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        return _buildReminderCard(reminder);
      },
    );
  }

  Widget _buildReminderCard(Map<String, dynamic> reminder) {
    final type = reminder['reminder_type'] ?? 'general';
    final isActive = reminder['is_active'] ?? true;
    
    IconData icon;
    Color color;
    switch (type) {
      case 'water':
        icon = Icons.water_drop;
        color = Colors.blue;
        break;
      case 'steps':
        icon = Icons.directions_walk;
        color = Colors.green;
        break;
      case 'meal':
        icon = Icons.restaurant;
        color = Colors.orange;
        break;
      default:
        icon = Icons.alarm;
        color = AppTheme.primaryGradientStart;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          reminder['title'] ?? 'Reminder',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reminder['message'] != null)
              Text(reminder['message'], maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  reminder['reminder_time'] ?? '09:00',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(width: 12),
                Icon(Icons.repeat, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  reminder['frequency'] ?? 'Daily',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Switch(
          value: isActive,
          onChanged: (val) => _toggleReminder(reminder['id'], val),
          activeColor: color,
        ),
      ),
    );
  }

  void _showAddReminderDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'water';
    String selectedFrequency = 'Daily';
    TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('add_reminder'.tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                ],
              ),
              const SizedBox(height: 20),
              
              // Reminder Type
              Text('reminder_type'.tr, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              StatefulBuilder(
                builder: (context, setStateLocal) => Wrap(
                  spacing: 10,
                  children: [
                    _buildTypeChip('water', '💧 ${'water'.tr}', selectedType, (v) => setStateLocal(() => selectedType = v)),
                    _buildTypeChip('steps', '🚶 ${'steps'.tr}', selectedType, (v) => setStateLocal(() => selectedType = v)),
                    _buildTypeChip('meal', '🍽️ ${'meal'.tr}', selectedType, (v) => setStateLocal(() => selectedType = v)),
                    _buildTypeChip('general', '⏰ ${'general'.tr}', selectedType, (v) => setStateLocal(() => selectedType = v)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'title'.tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              
              // Message
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: 'message'.tr,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              
              // Time & Frequency
              Row(
                children: [
                  Expanded(
                    child: StatefulBuilder(
                      builder: (context, setStateLocal) => GestureDetector(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) setStateLocal(() => selectedTime = time);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time),
                              const SizedBox(width: 10),
                              Text(selectedTime.format(context)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatefulBuilder(
                      builder: (context, setStateLocal) => DropdownButtonFormField<String>(
                        value: selectedFrequency,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: ['Daily', 'Weekly', 'Hourly'].map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                        onChanged: (v) => setStateLocal(() => selectedFrequency = v!),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _saveReminder(
                    titleController.text,
                    messageController.text,
                    selectedType,
                    selectedFrequency,
                    selectedTime,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGradientStart,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('save'.tr),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildTypeChip(String value, String label, String selected, Function(String) onSelect) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelect(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGradientStart.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGradientStart : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(label, style: TextStyle(
          color: isSelected ? AppTheme.primaryGradientStart : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        )),
      ),
    );
  }

  Future<void> _saveReminder(String title, String message, String type, String frequency, TimeOfDay time) async {
    if (title.isEmpty) {
      Get.snackbar('Error', 'Please enter a title', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    try {
      await SupabaseService.client.from('reminders').insert({
        'user_id': userId,
        'reminder_type': type,
        'title': title,
        'message': message,
        'frequency': frequency,
        'reminder_time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        'is_active': true,
      });

      Get.back();
      _loadReminders();
      Get.snackbar('✅ ${'success'.tr}', 'reminder_added'.tr, 
        backgroundColor: AppTheme.success, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _toggleReminder(String id, bool isActive) async {
    try {
      await SupabaseService.client
          .from('reminders')
          .update({'is_active': isActive})
          .eq('id', id);
      _loadReminders();
    } catch (e) {
      print('Error toggling reminder: $e');
    }
  }
}
