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
      print("Inside _login");
      print(mounted);
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 10),
                  _buildInputFields(),
                  _buildForgotPassword(),
                  _buildSignupPrompt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo-foundit.png',
          height: 80, // Reduced from 100
          width: 80,  // Reduced from 100
        ),
        const Text(
          "Found It!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22, // Reduced from 26
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          "Enter your credentials to login",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11, // Reduced from 12
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildInputFields() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10), // Reduced padding
            hintText: "Email",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.white.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.email, color: Colors.green, size: 18),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 12),
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
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10), // Reduced padding
            hintText: "Password",
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Colors.white.withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.password, color: Colors.green, size: 18),
            suffixIcon: GestureDetector(
              onTap: _togglePasswordVisibility,
              child: Icon(
                _isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                color: Colors.green,
                size: 18,
              ),
            ),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          obscureText: _isPasswordHidden,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _isLoading ? null : _login,
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 10), // Reduced padding
            backgroundColor: Colors.green,
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : const Text(
            "Login",
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        )
      ],
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () {},
      child: const Text(
        "Forgot password?",
        style: TextStyle(color: Colors.green, fontSize: 11),
      ),
    );
  }

  Widget _buildSignupPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.white70, fontSize: 11),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: const Text(
            "Sign Up",
            style: TextStyle(color: Colors.green, fontSize: 11),
          ),
        )
      ],
    );
  }
}