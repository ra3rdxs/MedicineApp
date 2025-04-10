// Import shared_preferences package for persistent storage
import 'package:shared_preferences/shared_preferences.dart';
// Import the User model
import '../models/user.dart';

// AuthService class - Manages user authentication operations
// This service handles login, logout, and checking authentication status
class AuthService {
  // Keys used for storing authentication data in SharedPreferences
  static const String _usernameKey = 'username';
  static const String _isLoggedInKey = 'isLoggedIn';

  // Login method - Saves username and sets login status to true
  // This is a simple authentication system that only requires a username
  Future<void> login(String username) async {
    // Get instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Save the username
    await prefs.setString(_usernameKey, username);
    // Set login status to true
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Check if a user is currently logged in
  // Returns true if logged in, false otherwise
  Future<bool> isLoggedIn() async {
    // Get instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Get the login status, default to false if not found
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Get the current logged-in user
  // Returns a User object if logged in, null otherwise
  Future<User?> getCurrentUser() async {
    // Get instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Get the saved username
    final username = prefs.getString(_usernameKey);

    // If no username is found, return null
    if (username == null) {
      return null;
    }

    // Create and return a User object with the saved username
    return User(username: username);
  }

  // Logout method - Sets login status to false
  // Note: This doesn't remove the username, just marks the user as logged out
  Future<void> logout() async {
    // Get instance of SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    // Set login status to false
    await prefs.setBool(_isLoggedInKey, false);
  }
}
