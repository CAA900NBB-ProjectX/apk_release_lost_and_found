import 'package:flutter/material.dart';
import '../services/auth_service.dart';

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
    return Scaffold(
      backgroundColor: Colors.black, // Set background to black
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildSignupForm(),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSignupForm() {
    return [
      const Text(
        "Sign up",
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Changed to white for visibility on black
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      if (_errorMessage != null)
        Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _usernameController,
        hintText: "Username",
        icon: Icons.person,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter username';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      _buildTextField(
        controller: _emailController,
        hintText: "Email",
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
      const SizedBox(height: 20),
      _buildTextField(
        controller: _passwordController,
        hintText: "Password",
        icon: Icons.password,
        isPassword: true,
        isPasswordHidden: _isPasswordHidden,
        onTogglePassword: () {
          setState(() {
            _isPasswordHidden = !_isPasswordHidden;
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
      const SizedBox(height: 20),
      _buildTextField(
        controller: _confirmPasswordController,
        hintText: "Confirm Password",
        icon: Icons.password,
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
      const SizedBox(height: 30),
      ElevatedButton(
        onPressed: _isLoading ? null : _signup,
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.green, // Changed to green from purple
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          "Sign up",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Already have an account?",
            style: TextStyle(color: Colors.white70), // Changed to white70 for visibility
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text(
              "Login",
              style: TextStyle(color: Colors.green), // Changed to green from purple
            ),
          ),
        ],
      ),
    ];
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool? isPasswordHidden,
    VoidCallback? onTogglePassword,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? (isPasswordHidden ?? true) : false,
      style: TextStyle(color: Colors.white), // Added white text color for input
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey), // Changed hint text color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        fillColor: Colors.white.withOpacity(0.1), // Changed to white with opacity instead of purple
        filled: true,
        prefixIcon: Icon(icon, color: Colors.green), // Changed icon color to green
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordHidden ?? true
                ? Icons.visibility
                : Icons.visibility_off,
            color: Colors.green, // Changed icon color to green
          ),
          onPressed: onTogglePassword,
        )
            : null,
      ),
      validator: validator,
    );
  }
}