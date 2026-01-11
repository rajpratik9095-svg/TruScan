import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'config/theme.dart';
import 'config/constants.dart';
import 'config/supabase_config.dart';
import 'controllers/auth_controller.dart';
import 'controllers/settings_controller.dart';
import 'controllers/scanner_controller.dart';
import 'controllers/diet_controller.dart';
import 'services/supabase_service.dart';
import 'services/connectivity_service.dart';
import 'services/ai_service.dart';
import 'translations/app_translations.dart';
import 'screens/welcome/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/home/home_tab.dart';
import 'screens/permission/permission_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize storage first
  await GetStorage.init();
  await Hive.initFlutter();
  
  // Initialize Supabase
  try {
    await SupabaseService.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    // Fetch AI API key from Supabase
    await AIService.fetchApiKeyFromSupabase();
  } catch (e) {
    print('Supabase init error: $e');
  }
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize all controllers ONCE in main before runApp
  _initializeControllers();
  
  runApp(const TrueScanApp());
}

/// Initialize all controllers once with permanent flag
void _initializeControllers() {
  Get.put(SettingsController(), permanent: true);
  Get.put(AuthController(), permanent: true);
  Get.put(ScannerController(), permanent: true);
  Get.put(DietController(), permanent: true);
  Get.put(ConnectivityService(), permanent: true);
  Get.put(HomeTabController(), permanent: true);
}

class TrueScanApp extends StatelessWidget {
  const TrueScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers already initialized in main()
    
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Localization
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      
      // Routes
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/welcome', page: () => const WelcomeScreen()),
      ],
      
      // Start with splash
      home: const SplashPage(),
    );
  }
}

// Simple Splash Page
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _goToNextScreen();
  }

  Future<void> _goToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Check auth state
    final authController = Get.find<AuthController>();
    final storage = GetStorage();
    
    // Check if permissions have been requested before
    final permissionsRequested = storage.read('permissions_requested') ?? false;
    
    if (authController.isLoggedIn.value) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else if (!permissionsRequested) {
      // First time user - show permission screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PermissionScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  size: 60,
                  color: Color(0xFF667eea),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'TrueScan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
