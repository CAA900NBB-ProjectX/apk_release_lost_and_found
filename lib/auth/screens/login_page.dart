import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordHidden = true;

  // Define a consistent color palette
  final Color _primaryGreen = const Color(0xFF4CAF50);      // Brighter primary green
  final Color _darkGreen = const Color(0xFF2E7D32);         // Dark green for accents
  final Color _lightGreen = const Color(0xFFA5D6A7);        // Light green for text
  final Color _backgroundDark = const Color(0xFF121212);    // Dark background
  final Color _cardDark = const Color(0xFF1E1E1E);          // Slightly lighter for input fields
  final Color _errorRed = const Color(0xFFE57373);          // Softer red for errors

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (result.containsKey('success') && result['success']) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            _errorMessage = result.containsKey('message')
                ? result['message']
                : 'Login failed. Please try again.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordHidden = !_isPasswordHidden;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: _backgroundDark,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: isDesktop ? 450 : screenWidth * 0.9,
              margin: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildInputFields(),
                    _buildForgotPassword(),
                    const SizedBox(height: 16),
                    _buildSignupPrompt(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
      Image.asset(
      'assets/images/logo-foundit.png', // Path to your image in the assets folder
      width: 120, // Adjust width as needed
      height: 120, // Adjust height as needed
    ),
        const SizedBox(height: 8),
        Text(
          "FoundIt!",
          style: TextStyle(
            fontFamily: 'Helvetica',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: _primaryGreen, // Using your existing color variable
          ),
        ),

        const SizedBox(height: 8),
        Text(
          "Enter your credentials to login",
          style: TextStyle(
            fontFamily: 'Helvetica',
            color: _lightGreen, // Light green text for better readability
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontFamily: 'Helvetica',
                color: _errorRed, // Softer red for error messages
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Email Address",
            style: TextStyle(
              fontFamily: 'Helvetica',
              color: _lightGreen, // Light green for better contrast
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextFormField(
          controller: _emailController,
          style: const TextStyle(
            fontFamily: 'Helvetica',
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: "Enter your email address...",
            hintStyle: TextStyle(
              fontFamily: 'Helvetica',
              color: _lightGreen.withOpacity(0.5), // Dimmed light green for hint
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _darkGreen.withOpacity(0.3), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryGreen, width: 2),
            ),
            fillColor: _cardDark,
            filled: true,
            prefixIcon: Icon(Icons.email, color: _primaryGreen),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            "Password",
            style: TextStyle(
              fontFamily: 'Helvetica',
              color: _lightGreen, // Light green for better contrast
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextFormField(
          controller: _passwordController,
          style: const TextStyle(
            fontFamily: 'Helvetica',
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: "Enter your password...",
            hintStyle: TextStyle(
              fontFamily: 'Helvetica',
              color: _lightGreen.withOpacity(0.5), // Dimmed light green for hint
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _darkGreen.withOpacity(0.3), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryGreen, width: 2),
            ),
            fillColor: _cardDark,
            filled: true,
            prefixIcon: Icon(Icons.lock, color: _primaryGreen),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            suffixIcon: GestureDetector(
              onTap: _togglePasswordVisibility,
              child: Icon(
                _isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                color: _primaryGreen,
              ),
            ),
          ),
          obscureText: _isPasswordHidden,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: _primaryGreen, // Brighter green for the button
            disabledBackgroundColor: _primaryGreen.withOpacity(0.6),
            elevation: 4,
            shadowColor: _primaryGreen.withOpacity(0.4),
          ),
          child: _isLoading
              ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          )
              : const Text(
            "LogIn",
            style: TextStyle(
              fontFamily: 'Helvetica',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // Forgot password action
        },
        style: TextButton.styleFrom(
          foregroundColor: _primaryGreen,
        ),
        child: Text(
          "Forgot password?",
          style: TextStyle(
            fontFamily: 'Helvetica',
            color: _primaryGreen, // Primary green for interactive elements
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSignupPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: TextStyle(
            fontFamily: 'Helvetica',
            color: _lightGreen, // Light green text
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          style: TextButton.styleFrom(
            foregroundColor: _primaryGreen,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            "Sign Up",
            style: TextStyle(
              fontFamily: 'Helvetica',
              color: _primaryGreen, // Primary green for interactive elements
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}