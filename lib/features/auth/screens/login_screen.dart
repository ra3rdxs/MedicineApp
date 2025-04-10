// Import Flutter's material package for UI components
import 'package:flutter/material.dart';
// Import the authentication service to handle login functionality
import '../services/auth_service.dart';

// LoginScreen widget - Handles user authentication
// This is a stateful widget as it needs to manage form input and loading states
class LoginScreen extends StatefulWidget {
  // Callback function that will be executed when login is successful
  // This allows the parent widget to respond to successful login events
  final Function onLogin;

  // Constructor that initializes the LoginScreen widget
  // The onLogin callback is required to handle successful login
  const LoginScreen({super.key, required this.onLogin});

  @override
  // Create the mutable state for this widget
  State<LoginScreen> createState() => _LoginScreenState();
}

// The private state class for the LoginScreen widget
class _LoginScreenState extends State<LoginScreen> {
  // Controller for the username text field to access and manage its value
  final TextEditingController _usernameController = TextEditingController();
  // Instance of AuthService to handle login operations
  final AuthService _authService = AuthService();
  // Flag to track if a login operation is in progress
  bool _isLoading = false;
  // Variable to store error messages if login fails
  String? _errorMessage;

  @override
  // Clean up resources when the widget is removed from the widget tree
  void dispose() {
    // Dispose the text controller to prevent memory leaks
    _usernameController.dispose();
    super.dispose();
  }

  // Method to handle the login process
  Future<void> _login() async {
    // Validate that the username field is not empty
    if (_usernameController.text.trim().isEmpty) {
      // Update state to show an error message
      setState(() {
        _errorMessage = 'Please Enter your Name: ';
      });
      return;
    }

    // Update state to show loading indicator and clear any previous errors
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Attempt to log in using the AuthService
      await _authService.login(_usernameController.text.trim());
      // Call the onLogin callback to notify parent widget of successful login
      widget.onLogin();
    } catch (e) {
      // Update state to show error message if login fails
      setState(() {
        _errorMessage = 'Error logging in: ${e.toString()}';
      });
    } finally {
      // Update state to hide loading indicator regardless of success or failure
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  // Build the UI for the login screen
  Widget build(BuildContext context) {
    return Scaffold(
      // Main body of the screen
      body: SafeArea(
        // Add padding around all content
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          // Column to arrange widgets vertically
          child: Column(
            // Center the column contents vertically
            mainAxisAlignment: MainAxisAlignment.center,
            // Stretch children horizontally to fill available width
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App logo icon
              const Icon(
                Icons.medication_rounded,
                size: 80,
                color: Colors.blue,
              ),
              // Vertical spacing
              const SizedBox(height: 24),
              // App title
              const Text(
                'MediRemind',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              // Small vertical spacing
              const SizedBox(height: 8),
              // App subtitle/description
              const Text(
                'Your personal medicine reminder',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              // Larger vertical spacing before the form
              const SizedBox(height: 48),
              // Username input field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  hintText: 'Enter your name',
                  // Rounded border for the input field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // Person icon at the start of the input field
                  prefixIcon: const Icon(Icons.person),
                  // Display error message if validation fails
                  errorText: _errorMessage,
                ),
                // Configure keyboard action button
                textInputAction: TextInputAction.done,
                // Handle submission when user presses the done button on keyboard
                onSubmitted: (_) => _login(),
              ),
              // Vertical spacing
              const SizedBox(height: 24),
              // Login button
              ElevatedButton(
                // Disable button when loading, otherwise call login method
                onPressed: _isLoading ? null : _login,
                // Button styling
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                // Show loading indicator or button text based on loading state
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                          'Get Started',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
