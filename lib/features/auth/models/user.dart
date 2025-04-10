// User model class - Represents a user in the application
// This is a simple model that only contains a username
class User {
  // The username of the user
  // This is marked as final because it shouldn't change after creation
  final String username;

  // Constructor for the User class that requires a username
  // Uses named parameters for better readability
  User({required this.username});

  // Converts the User object into a Map (used for saving data to SharedPreferences)
  // This method is essential for serialization when storing user data
  Map<String, dynamic> toJson() {
    return {
      'username': username, // Stores the username under the key 'username'
    };
  }

  // A factory constructor to create a User object from a JSON-style Map
  // This method is essential for deserialization when retrieving user data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'], // Retrieves the username from the JSON data
    );
  }
}
