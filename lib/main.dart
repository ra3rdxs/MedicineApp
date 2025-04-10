// Import Flutter's material package for UI components
import 'package:flutter/material.dart';
// Import screens for navigation
import 'features/auth/screens/login_screen.dart';
import 'features/medicine_reminders/screens/home_screen.dart';
// Import services for business logic
import 'features/auth/services/auth_service.dart';
import 'features/medicine_reminders/services/notification_service.dart';
// Import app theme for consistent styling
import 'core/theme/app_theme.dart';

// Main entry point of the application
// This is an async function because we need to initialize services before running the app
void main() async {
  // Ensure Flutter binding is initialized before using platform channels
  // This is required when doing any async operations before runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service to handle medicine reminders
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Launch the application by creating an instance of MyApp
  runApp(const MyApp());
}

// MyApp widget - The root widget of the application
// This is a stateful widget because it needs to manage authentication state
class MyApp extends StatefulWidget {
  // Constructor with key parameter for widget identification
  const MyApp({super.key});

  @override
  // Create the mutable state for this widget
  State<MyApp> createState() => _MyAppState();
}

// The private state class for the MyApp widget
class _MyAppState extends State<MyApp> {
  // Instance of AuthService to handle authentication operations
  final AuthService _authService = AuthService();
  // Flag to track if user is logged in
  bool _isLoggedIn = false;
  // Flag to track if initial authentication check is in progress
  bool _isLoading = true;

  @override
  // Initialize state when widget is first created
  void initState() {
    super.initState();
    // Check if user is already logged in
    _checkLoginStatus();
  }

  // Method to check if user is logged in using AuthService
  Future<void> _checkLoginStatus() async {
    // Get login status from AuthService
    final isLoggedIn = await _authService.isLoggedIn();
    // Update state with login status and set loading to false
    setState(() {
      _isLoggedIn = isLoggedIn;
      _isLoading = false;
    });
  }

  // Callback method for LoginScreen to notify when login is successful
  void _onLogin() {
    // Update state to reflect successful login
    setState(() {
      _isLoggedIn = true;
    });
  }

  @override
  // Build the UI for the application
  Widget build(BuildContext context) {
    return MaterialApp(
      // App title displayed in task switchers
      title: 'MediRemind',
      // Apply the app theme from AppTheme
      theme: AppTheme.getTheme(),
      // Determine which screen to show based on loading and login state
      home:
          _isLoading
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : _isLoggedIn
              ? const HomeScreen()  // Show HomeScreen if logged in
              : LoginScreen(onLogin: _onLogin),  // Show LoginScreen if not logged in
    );
  }
}
