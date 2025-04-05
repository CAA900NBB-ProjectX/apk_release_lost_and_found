import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../../helpers/password_strength.dart';

class PasswordStrengthChecker {
  static CustomPassStrength? calculate({required String text}) {
    return CustomPassStrength.calculate(text: text);
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  CustomPassStrength? _passwordStrength;

  // Define a consistent color palette matching the login page
  final Color _primaryGreen = const Color(0xFF4CAF50);      // Brighter primary green
  final Color _darkGreen = const Color(0xFF2E7D32);         // Dark green for accents
  final Color _lightGreen = const Color(0xFFA5D6A7);        // Light green for text
  final Color _backgroundDark = const Color(0xFF121212);    // Dark background to match login page
  final Color _cardDark = const Color(0xFF1E1E1E);          // Slightly lighter for input fields
  final Color _errorRed = const Color(0xFFE57373);          // Softer red for errors

  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.register(
        _emailController.text,
        _passwordController.text,
        _usernameController.text,
      );

      if (mounted) {
        if (result['success']) {
          Navigator.pushReplacementNamed(
            context,
            '/verification',
            arguments: _emailController.text,
          );
        } else {
          setState(() {
            _errorMessage = result['message'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (e.toString().contains('User is already registered')) {
            _errorMessage = 'User is already registered';
          } else {
            _errorMessage = 'Connection error. Please try again.';
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildSignupForm(isDesktop),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSignupForm(bool isDesktop) {
    return [
      Text(
        "Create Account",
        style: TextStyle(
          fontSize: isDesktop ? 28 : 24,
          fontWeight: FontWeight.bold,
          color: _primaryGreen,
          fontFamily: 'Helvetica',
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 8),
      Text(
        "Sign up to get started",
        style: TextStyle(
          fontSize: isDesktop ? 16 : 14,
          color: _lightGreen,
          fontFamily: 'Helvetica',
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 24),
      if (_errorMessage != null)
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _errorRed.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _errorMessage!,
            style: TextStyle(
              color: _errorRed,
              fontFamily: 'Helvetica',
            ),
            textAlign: TextAlign.center,
          ),
        ),
      if (_errorMessage != null) const SizedBox(height: 16),
      _buildInputLabel("Username"),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _usernameController,
        hintText: "Enter your username",
        icon: Icons.person,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter username';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildInputLabel("Email"),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _emailController,
        hintText: "Enter your email",
        icon: Icons.email,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter email';
          }
          if (!value.contains('@')) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
      const SizedBox(height: 16),
      _buildInputLabel("Password"),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _passwordController,
        hintText: "Enter your password",
        icon: Icons.lock,
        isPassword: true,
        isPasswordHidden: _isPasswordHidden,
        onTogglePassword: () {
          setState(() {
            _isPasswordHidden = !_isPasswordHidden;
          });
        },
        onChanged: (text) {
          setState(() {
            _passwordStrength = PasswordStrengthChecker.calculate(text: text);
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
      if (_passwordStrength != null) ...[
        const SizedBox(height: 8),
        _buildPasswordStrengthIndicator(),
      ],
      const SizedBox(height: 16),
      _buildInputLabel("Confirm Password"),
      const SizedBox(height: 8),
      _buildTextField(
        controller: _confirmPasswordController,
        hintText: "Confirm your password",
        icon: Icons.lock,
        isPassword: true,
        isPasswordHidden: _isConfirmPasswordHidden,
        onTogglePassword: () {
          setState(() {
            _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please confirm password';
          }
          if (value != _passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
      ),
      const SizedBox(height: 24),
      SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _signup,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: _primaryGreen.withOpacity(0.4),
          ),
          child: _isLoading
              ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          )
              : Text(
            "Sign Up",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Helvetica',
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account?",
            style: TextStyle(
              color: _lightGreen,
              fontFamily: 'Helvetica',
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            style: TextButton.styleFrom(
              foregroundColor: _primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(
              "Login",
              style: TextStyle(
                color: _primaryGreen,
                fontWeight: FontWeight.bold,
                fontFamily: 'Helvetica',
              ),
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildPasswordStrengthIndicator() {
    // Map the password strength status to our theme's colors
    Color getStrengthColor() {
      if (_passwordStrength == null) return Colors.transparent;

      // Determine what color to use based on strength
      if (_passwordStrength!.widthPerc < 0.3) {
        return Colors.red[400]!;
      } else if (_passwordStrength!.widthPerc < 0.7) {
        return Colors.amber[400]!;
      } else {
        return _primaryGreen;
      }
    }

    // Replace the original status widget with our themed version
    Widget getStatusWidget() {
      if (_passwordStrength == null) return const SizedBox();

      String statusText = '';
      if (_passwordStrength!.widthPerc < 0.3) {
        statusText = 'Weak';
      } else if (_passwordStrength!.widthPerc < 0.7) {
        statusText = 'Medium';
      } else {
        statusText = 'Strong';
      }

      return Text(
        statusText,
        style: TextStyle(
          color: getStrengthColor(),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password Strength",
          style: TextStyle(
            color: _lightGreen,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        // Strength Bar
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _cardDark,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _passwordStrength?.widthPerc ?? 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: getStrengthColor(),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        getStatusWidget(),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          color: _lightGreen,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          fontFamily: 'Helvetica',
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool? isPasswordHidden,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? (isPasswordHidden ?? true) : false,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'Helvetica',
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: _lightGreen.withOpacity(0.5),
          fontFamily: 'Helvetica',
        ),
        errorStyle: TextStyle(
          color: _errorRed,
          fontFamily: 'Helvetica',
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
        prefixIcon: Icon(
          icon,
          color: _primaryGreen,
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordHidden ?? true
                ? Icons.visibility
                : Icons.visibility_off,
            color: _primaryGreen,
          ),
          onPressed: onTogglePassword,
        )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}