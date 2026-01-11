import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../config/theme.dart';
import '../../services/supabase_service.dart';
import '../../controllers/auth_controller.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final storage = GetStorage();
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isEditMode = false;
  bool _hasData = false;
  
  // Controllers
  final TextEditingController ageController = TextEditingController(text: '25');
  final TextEditingController heightController = TextEditingController(text: '172');
  final TextEditingController weightController = TextEditingController(text: '68');
  final TextEditingController allergyInputController = TextEditingController();

  // Selected values
  String selectedGoal = 'weight_loss';
  String selectedDiet = 'vegetarian';
  String selectedActivity = 'moderate';
  String selectedGender = 'male';
  List<String> selectedAllergies = [];
  List<String> healthConditions = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    // Check if we have local data
    _hasData = storage.read('diet_goal') != null;
    
    // Load from local storage
    ageController.text = storage.read('diet_age') ?? '25';
    heightController.text = storage.read('diet_height') ?? '172';
    weightController.text = storage.read('diet_weight') ?? '68';
    selectedGoal = storage.read('diet_goal') ?? 'weight_loss';
    selectedDiet = storage.read('diet_type') ?? 'vegetarian';
    selectedActivity = storage.read('diet_activity') ?? 'moderate';
    selectedGender = storage.read('diet_gender') ?? 'male';
    selectedAllergies = List<String>.from(storage.read('diet_allergies') ?? []);
    healthConditions = List<String>.from(storage.read('diet_health') ?? []);
    
    // Load from Supabase
    final userId = SupabaseService.currentUser?.id;
    if (userId != null) {
      try {
        final response = await SupabaseService.client
            .from('diet_preferences')
            .select()
            .eq('user_id', userId)
            .maybeSingle();
        
        if (response != null) {
          _hasData = true;
          setState(() {
            ageController.text = response['age']?.toString() ?? '25';
            heightController.text = response['height']?.toString() ?? '172';
            weightController.text = response['weight']?.toString() ?? '68';
            selectedGoal = response['goal'] ?? 'weight_loss';
            selectedDiet = response['diet_type'] ?? 'vegetarian';
            selectedActivity = response['activity_level'] ?? 'moderate';
            selectedGender = response['gender'] ?? 'male';
            selectedAllergies = List<String>.from(response['allergies'] ?? []);
            healthConditions = List<String>.from(response['health_conditions'] ?? []);
          });
        }
      } catch (e) {
        print('Error loading diet preferences: $e');
      }
    }
    
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    allergyInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    // Check if guest user
    if (authController.isGuestUser) {
      return Scaffold(
        appBar: AppBar(
          title: Text('my_diet_health'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 24),
                Text(
                  'login_required'.tr,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  '${'login_to_access'.tr} ${'diet_settings'.tr}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    authController.isGuest.value = false;
                    Get.offAllNamed('/login');
                  },
                  icon: const Icon(Icons.login),
                  label: Text('login'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGradientStart,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'edit_diet_profile'.tr : 'my_diet_health'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_isEditMode)
            TextButton(
              onPressed: () => setState(() => _isEditMode = false),
              child: Text('cancel'.tr),
            )
          else if (_hasData)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditMode = true),
            ),
        ],
      ),
      body: _isEditMode || !_hasData ? _buildEditView() : _buildProfileView(),
    );
  }

  // ========== PROFILE VIEW ==========
  Widget _buildProfileView() {
    final goalData = _getGoalData(selectedGoal);
    final bmi = _calculateBMI();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Main Profile Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGradientStart.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Goal Icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(goalData['icon'] as IconData, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  goalData['title'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  goalData['subtitle'] as String,
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 20),
                
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildProfileStat('age'.tr, '${ageController.text} ${'years'.tr}'),
                    _buildProfileStat('height'.tr, '${heightController.text} cm'),
                    _buildProfileStat('weight'.tr, '${weightController.text} kg'),
                  ],
                ),
                const SizedBox(height: 16),
                
                // BMI
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monitor_weight, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'BMI: ${bmi.toStringAsFixed(1)} (${_getBMICategory(bmi)})',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Info Cards Grid
          Row(
            children: [
              Expanded(child: _buildInfoCard(
                '🍽️ ${'diet_type'.tr}',
                _getDietLabel(selectedDiet),
                Colors.green,
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoCard(
                '🏃 ${'activity_level'.tr}',
                _getActivityLabel(selectedActivity),
                Colors.blue,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildInfoCard(
                '👤 ${'gender'.tr}',
                selectedGender.capitalizeFirst ?? selectedGender,
                Colors.purple,
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildInfoCard(
                '❤️ ${'health_conditions'.tr}',
                healthConditions.isEmpty ? 'None' : healthConditions.length.toString() + ' conditions',
                Colors.red,
              )),
            ],
          ),
          const SizedBox(height: 20),

          // Allergies Card
          if (selectedAllergies.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'allergies'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedAllergies.map((allergy) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(allergy, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w500)),
                    )).toList(),
                  ),
                ],
              ),
            ),
          
          // Health Conditions Card
          if (healthConditions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medical_services, color: Colors.red),
                      const SizedBox(width: 8),
                      const Text(
                        'Health Conditions',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...healthConditions.map((condition) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Text(condition),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Edit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _isEditMode = true),
              icon: const Icon(Icons.edit),
              label: Text('edit_diet_profile'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGradientStart,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
          ),
        ],
      ),
    );
  }

  // ========== EDIT VIEW ==========
  Widget _buildEditView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set your preferences for personalized recommendations',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Basic Info
          _buildSectionCard(
            icon: Icons.person,
            title: 'basic_info'.tr,
            child: Column(
              children: [
                _buildInputField('age'.tr, ageController, 'years'.tr),
                const SizedBox(height: 14),
                _buildGenderButtons(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _buildInputField('height'.tr, heightController, 'cm')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildInputField('weight'.tr, weightController, 'kg')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Goal
          _buildSectionCard(
            icon: Icons.flag,
            title: 'main_goal'.tr,
            child: _buildGoalCards(),
          ),
          const SizedBox(height: 16),

          // Diet Type
          _buildSectionCard(
            icon: Icons.restaurant,
            title: 'diet_type'.tr,
            child: _buildDietPills(),
          ),
          const SizedBox(height: 16),

          // Activity
          _buildSectionCard(
            icon: Icons.directions_run,
            title: 'activity_level'.tr,
            child: _buildActivityTiles(),
          ),
          const SizedBox(height: 16),

          // Health
          _buildSectionCard(
            icon: Icons.medical_services,
            title: 'health_conditions'.tr,
            child: _buildHealthCheckboxes(),
          ),
          const SizedBox(height: 16),

          // Allergies
          _buildSectionCard(
            icon: Icons.warning_amber,
            title: 'allergies'.tr,
            child: _buildAllergyChips(),
          ),
          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSettings,
              icon: _isSaving 
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'loading'.tr : 'save_profile'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.primaryGradientStart.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: AppTheme.primaryGradientStart, size: 20),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, String suffix) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildGenderButtons() {
    return Row(
      children: ['male', 'female', 'other'].map((gender) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => selectedGender = gender),
          child: Container(
            margin: EdgeInsets.only(right: gender != 'other' ? 8 : 0),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selectedGender == gender ? AppTheme.primaryGradientStart.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: selectedGender == gender ? AppTheme.primaryGradientStart : Colors.transparent, width: 2),
            ),
            child: Center(
              child: Text(
                gender.capitalizeFirst ?? gender,
                style: TextStyle(color: selectedGender == gender ? AppTheme.primaryGradientStart : Colors.grey[700], fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildGoalCards() {
    final goals = [
      {'id': 'weight_loss', 'title': 'Weight Loss', 'icon': Icons.monitor_weight, 'color': Colors.orange},
      {'id': 'muscle_gain', 'title': 'Muscle Gain', 'icon': Icons.fitness_center, 'color': Colors.blue},
      {'id': 'healthy_living', 'title': 'Healthy', 'icon': Icons.favorite, 'color': Colors.pink},
      {'id': 'diabetes', 'title': 'Diabetes', 'icon': Icons.bloodtype, 'color': Colors.red},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.4,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: goals.map((goal) => GestureDetector(
        onTap: () => setState(() => selectedGoal = goal['id'] as String),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selectedGoal == goal['id'] ? (goal['color'] as Color).withOpacity(0.15) : Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selectedGoal == goal['id'] ? goal['color'] as Color : Colors.transparent, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(goal['icon'] as IconData, color: selectedGoal == goal['id'] ? goal['color'] as Color : Colors.grey, size: 28),
              const SizedBox(height: 6),
              Text(goal['title'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selectedGoal == goal['id'] ? goal['color'] as Color : null)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDietPills() {
    final diets = ['vegetarian', 'non-veg', 'vegan', 'jain', 'eggetarian'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: diets.map((diet) => GestureDetector(
        onTap: () => setState(() => selectedDiet = diet),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selectedDiet == diet ? AppTheme.success.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: selectedDiet == diet ? AppTheme.success : Colors.transparent, width: 2),
          ),
          child: Text(diet.capitalizeFirst ?? diet, style: TextStyle(color: selectedDiet == diet ? AppTheme.success : Colors.grey[700], fontWeight: FontWeight.w500)),
        ),
      )).toList(),
    );
  }

  Widget _buildActivityTiles() {
    final activities = [
      {'id': 'low', 'title': 'Sedentary', 'subtitle': 'Little exercise'},
      {'id': 'moderate', 'title': 'Moderate', 'subtitle': 'Light exercise'},
      {'id': 'high', 'title': 'Active', 'subtitle': 'Regular workout'},
    ];

    return Column(
      children: activities.map((a) => GestureDetector(
        onTap: () => setState(() => selectedActivity = a['id']!),
        child: Container(
          margin: EdgeInsets.only(bottom: a['id'] != 'high' ? 8 : 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selectedActivity == a['id'] ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selectedActivity == a['id'] ? Colors.blue : Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Text(a['title']!, style: TextStyle(fontWeight: FontWeight.w600, color: selectedActivity == a['id'] ? Colors.blue : null)),
              const Spacer(),
              Text(a['subtitle']!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              if (selectedActivity == a['id']) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.check_circle, color: Colors.blue, size: 18)),
            ],
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildHealthCheckboxes() {
    final conditions = ['Diabetes', 'High BP', 'Heart Disease', 'Thyroid'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: conditions.map((c) => FilterChip(
        label: Text(c),
        selected: healthConditions.contains(c),
        onSelected: (val) => setState(() => val ? healthConditions.add(c) : healthConditions.remove(c)),
        selectedColor: Colors.red.withOpacity(0.2),
        checkmarkColor: Colors.red,
      )).toList(),
    );
  }

  Widget _buildAllergyChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedAllergies.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selectedAllergies.map((a) => Chip(
              label: Text(a),
              deleteIcon: const Icon(Icons.close, size: 16),
              onDeleted: () => setState(() => selectedAllergies.remove(a)),
              backgroundColor: Colors.orange.withOpacity(0.15),
              deleteIconColor: Colors.orange,
            )).toList(),
          ),
        const SizedBox(height: 10),
        TextField(
          controller: allergyInputController,
          decoration: InputDecoration(
            hintText: 'Add allergy',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(icon: const Icon(Icons.add), onPressed: _addAllergy),
          ),
          onSubmitted: (_) => _addAllergy(),
        ),
      ],
    );
  }

  void _addAllergy() {
    final v = allergyInputController.text.trim();
    if (v.isNotEmpty && !selectedAllergies.contains(v)) {
      setState(() => selectedAllergies.add(v));
      allergyInputController.clear();
    }
  }

  // ========== HELPERS ==========
  Map<String, dynamic> _getGoalData(String goal) {
    final goals = {
      'weight_loss': {'title': 'Weight Loss', 'subtitle': 'Lose extra weight', 'icon': Icons.monitor_weight},
      'muscle_gain': {'title': 'Muscle Gain', 'subtitle': 'Build muscle mass', 'icon': Icons.fitness_center},
      'healthy_living': {'title': 'Healthy Living', 'subtitle': 'Maintain wellness', 'icon': Icons.favorite},
      'diabetes': {'title': 'Diabetes Focus', 'subtitle': 'Control sugar levels', 'icon': Icons.bloodtype},
    };
    return goals[goal] ?? goals['weight_loss']!;
  }

  String _getDietLabel(String diet) {
    final labels = {'vegetarian': '🥗 Vegetarian', 'non-veg': '🍗 Non-veg', 'vegan': '🌱 Vegan', 'jain': '🙏 Jain', 'eggetarian': '🥚 Eggetarian'};
    return labels[diet] ?? diet;
  }

  String _getActivityLabel(String activity) {
    final labels = {'low': 'Sedentary', 'moderate': 'Moderate', 'high': 'Active'};
    return labels[activity] ?? activity;
  }

  double _calculateBMI() {
    final h = double.tryParse(heightController.text) ?? 172;
    final w = double.tryParse(weightController.text) ?? 68;
    return w / ((h / 100) * (h / 100));
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    
    storage.write('diet_age', ageController.text);
    storage.write('diet_height', heightController.text);
    storage.write('diet_weight', weightController.text);
    storage.write('diet_goal', selectedGoal);
    storage.write('diet_type', selectedDiet);
    storage.write('diet_activity', selectedActivity);
    storage.write('diet_gender', selectedGender);
    storage.write('diet_allergies', selectedAllergies);
    storage.write('diet_health', healthConditions);

    final userId = SupabaseService.currentUser?.id;
    if (userId != null) {
      try {
        await SupabaseService.client.from('diet_preferences').upsert({
          'user_id': userId,
          'age': int.tryParse(ageController.text) ?? 25,
          'gender': selectedGender,
          'height': int.tryParse(heightController.text) ?? 172,
          'weight': int.tryParse(weightController.text) ?? 68,
          'goal': selectedGoal,
          'diet_type': selectedDiet,
          'activity_level': selectedActivity,
          'allergies': selectedAllergies,
          'health_conditions': healthConditions,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');
      } catch (e) {
        print('Error saving to Supabase: $e');
      }
    }

    setState(() {
      _isSaving = false;
      _hasData = true;
      _isEditMode = false;
    });
    
    Get.snackbar('Saved! ✅', 'Your diet profile has been updated.', backgroundColor: AppTheme.success, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM, margin: const EdgeInsets.all(16));
  }
}
