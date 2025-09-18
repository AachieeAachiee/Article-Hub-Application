class Validators {
  


static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    if (value.trim().length < 3) return 'Username must be at least 3 characters';
    return null;
  }

  
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone is required';
    final phoneRegex = RegExp(r'^\d{10,15}$');
    if (!phoneRegex.hasMatch(value.trim())) return 'Enter a valid phone number';
    return null;
  }

  static String? validatePosition(String? value) {
    if (value == null || value.trim().isEmpty) return 'Position is required';
    if (value.trim().length < 2) return 'Position must be at least 2 characters';
    return null;
  }

  static String? validateCountry(String? value) {
    if (value == null || value.trim().isEmpty) return 'Country is required';
    return null;
  }

  
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    final upperCase = RegExp(r'[A-Z]');
    final lowerCase = RegExp(r'[a-z]');
    final digit = RegExp(r'\d');
    final specialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
    if (!upperCase.hasMatch(value)) return 'Password must have at least one uppercase letter';
    if (!lowerCase.hasMatch(value)) return 'Password must have at least one lowercase letter';
    if (!digit.hasMatch(value)) return 'Password must have at least one number';
    if (!specialChar.hasMatch(value)) return 'Password must have at least one special character';
    return null;
  }
}
