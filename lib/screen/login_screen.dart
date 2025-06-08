import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:petverse_front_flutter/screen/pincode_screen.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _emailFormatErrorText;
  bool _isLoading = false;
  bool _showPasswordInput = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _verifyEmail() async { // Renamed for consistency
    logger.d('[BEGIN] _verifyEmail');

    final String enteredEmail = _emailController.text.trim();
    if (!_isEmailValid(enteredEmail)) return;

    _setLoading(true);

    bool emailExists = false;
    String errorMessage = '';

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      emailExists = await authProvider.validateEmail(enteredEmail);
    } catch (e) {
      logger.e('Error validating email: $e');
      errorMessage = e.toString();
    }

    _setLoading(false);

    if (!mounted) {
      logger.d('Widget unmounted after API call, stopping further operations.');
      return;
    }

    if (emailExists) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PinCodeScreen(email: enteredEmail)),
      );
      logger.d('Email verified. Navigated to PinCodeScreen with: $enteredEmail');
    } else {
      setState(() {
        _emailFormatErrorText = 'This email is not found in the system.'; // More user-friendly text
      });
      logger.d('Email not found in system.');
    }

    if (errorMessage.isNotEmpty) {
      _showSnackBar('An error occurred during email verification: $errorMessage'); // More descriptive
    }
  }

  void _doLoginWithPassword() async {
    logger.d('[BEGIN] _doLoginWithPassword');

    final String enteredEmail = _emailController.text.trim();
    final String enteredPassword = _passwordController.text;

    if (!_isEmailValid(enteredEmail, forLogin: true)) return;
    if (!_formKey.currentState!.validate()) return; // Re-validate password field

    _setLoading(true);

    String errorMessage = '';
    bool loginSuccess = false;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      loginSuccess = await authProvider.login(enteredEmail, enteredPassword);
    } catch (e) {
      logger.e('Error during password login: $e');
      errorMessage = e.toString();
    }

    _setLoading(false);

    if (!mounted) {
      logger.d('Widget unmounted after password login API call.');
      return;
    }

    if (loginSuccess) {
      /*Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );*/
    } else {
      _showSnackBar(errorMessage.isNotEmpty ? errorMessage : 'Login failed. Please check your credentials.'); // Improved message
    }
  }

  bool _isEmailValid(String email, {bool forLogin = false}) {
    if (email.isEmpty) {
      setState(() {
        _emailFormatErrorText = 'Please enter your email or username.';
      });
      return false;
    }

    if (!EmailValidator.validate(email)) {
      logger.d('Email format invalid${forLogin ? ' for password login' : ''}.');
      setState(() {
        _emailFormatErrorText = 'Please enter a valid email format.';
      });
      return false;
    }

    setState(() {
      _emailFormatErrorText = null; // Clear the error if valid
    });

    return true;
  }

  void _setLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400, // Consistent error color
      ),
    );
  }

  Widget _buildSocialIconButton({
    required String iconPath,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        // Add a subtle border for iOS-like flat design when background is white
        border: Border.all(
          color: Colors.grey.shade300, // Light grey border
          width: 0.8,
        ),
      ),
      child: IconButton(
        icon: Image.asset(
          iconPath,
          height: 28,
          width: 28,
        ),
        onPressed: _isLoading ? null : onPressed,
        tooltip: 'Sign in with ${iconPath.split('/').last.split('.').first.replaceAll('-', ' ').toTitleCase()}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure white background for iOS feel
      body: SafeArea( // Use SafeArea to avoid notch/dynamic island
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // Consistent horizontal padding
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80), // More space from top for iOS feel

                // Logo/App Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pets,
                      color: Colors.blue.shade700, // A strong blue for branding
                      size: 40,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PetVerse', // Capitalized for app title
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60), // Increased spacing

                // "Sign In" text
                Align(
                  alignment: Alignment.centerLeft, // Align left
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.black87, // Dark text
                      fontSize: 30, // Larger for prominence
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Email or Username input
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // No explicit label above the input in iOS, hint text is enough
                      // or use a placeholder in Material if you really need it
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100, // Very light grey background for input field
                          hintText: 'Email or Username', // Use hint text as label
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10), // More rounded corners
                            borderSide: BorderSide.none, // No default border
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.blue, width: 1.5), // Blue border on focus
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.red, width: 1.5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.red, width: 2.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // More vertical padding
                          errorStyle: const TextStyle(color: Colors.red, fontSize: 12.0),
                          errorText: _emailFormatErrorText,
                        ),
                        onChanged: (value) {
                          if (_emailFormatErrorText != null) {
                            setState(() {
                              _emailFormatErrorText = null;
                            });
                          }
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        enabled: !_isLoading,
                      ),
                      if (_showPasswordInput) ...[
                        const SizedBox(height: 16), // Slightly less spacing for grouped fields
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade100, // Light grey background
                            hintText: 'Password', // Use hint text as label
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.red, width: 1.5),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.red, width: 2.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            errorStyle: const TextStyle(color: Colors.red, fontSize: 12.0),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password.';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters.';
                            }
                            return null;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          enabled: !_isLoading,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Sign in button
                SizedBox(
                  width: double.infinity,
                  height: 54, // Taller button
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () {
                      if (_showPasswordInput) {
                        _doLoginWithPassword();
                      } else {
                        _verifyEmail(); // Call the renamed method
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // Standard iOS blue for primary button
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // More rounded corners for button
                      ),
                      elevation: 0, // Flat design, no shadow
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      (_showPasswordInput ? 'Sign In' : 'Sign In with Account'), // Simplified button text
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600, // Slightly bolder
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign In with Other Options (Toggle mode)
                TextButton(
                  onPressed: _isLoading ? null : () {
                    setState(() {
                      _showPasswordInput = !_showPasswordInput;
                      _emailController.clear();
                      _passwordController.clear();
                      _emailFormatErrorText = null;
                      _formKey.currentState?.reset();
                    });
                    logger.d('Toggle login mode. Now show password: $_showPasswordInput');
                  },
                  child: Text(
                    _showPasswordInput ? 'Sign In with PIN' : 'Sign In with Password',
                    style: TextStyle(
                      color: _isLoading ? Colors.blue.shade300 : Colors.blue, // iOS blue
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // --- Social Login Section ---
                const SizedBox(height: 30),
                // Instead of a full divider, use a lighter text label
                Text(
                  'Or sign in with',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSocialIconButton(
                      iconPath: 'assets/images/google-logo.png', // Ensure this path is correct
                      backgroundColor: Colors.white,
                      onPressed: () {
                        logger.d('Google Sign-in clicked!');
                        _showSnackBar('Google Sign-in clicked!');
                        // TODO: Implement Google Sign-in logic
                      },
                    ),
                    _buildSocialIconButton(
                      iconPath: 'assets/images/facebook-logo.png', // Ensure this path is correct
                      backgroundColor: Colors.white, // White background for uniformity
                      onPressed: () {
                        logger.d('Facebook Sign-in clicked!');
                        _showSnackBar('Facebook Sign-in clicked!');
                        // TODO: Implement Facebook Sign-in logic
                      },
                    ),
                    _buildSocialIconButton(
                      iconPath: 'assets/images/apple-logo.png', // Ensure this path is correct
                      backgroundColor: Colors.white,
                      onPressed: () {
                        logger.d('Apple Sign-in clicked!');
                        _showSnackBar('Apple Sign-in clicked!');
                        // TODO: Implement Apple Sign-in logic
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40), // Spacing at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper extension for String to convert to Title Case (optional, for tooltip)
extension StringCasingExtension on String {
  String toCapitalized() => length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String toTitleCase() => replaceAll(RegExp(' +'), ' ').split(' ').map((str) => str.toCapitalized()).join(' ');
}