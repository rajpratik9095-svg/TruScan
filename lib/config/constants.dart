class AppConstants {
  // App Info
  static const String appName = 'TrueScan';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String storageKeyUser = 'user';
  static const String storageKeyToken = 'token';
  static const String storageKeyLanguage = 'language';
  static const String storageKeyTheme = 'theme';
  static const String storageKeyRememberMe = 'rememberMe';
  static const String storageKeyScannedProducts = 'scannedProducts';
  static const String storageKeyDietEntries = 'dietEntries';
  
  // Default Values
  static const String defaultLanguage = 'en_US';
  static const bool defaultDarkMode = false;
  
  // API Endpoints (if needed in future)
  static const String baseUrl = 'https://api.truescan.com';
  
  // Limits
  static const int maxScanHistory = 50;
  static const int maxDietEntriesPerDay = 20;
}
