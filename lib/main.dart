import 'package:flutter/material.dart';
import 'auth/screens/login_page.dart';
import 'auth/screens/signup_page.dart';
import 'auth/services/auth_service.dart';
import 'auth/screens/verification_page.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart'; // Import the profile screen
import 'screens/upload_item_screen.dart';
import 'screens/view_item_screen.dart';
import 'screens/profile_page.dart'; // Import the new profile page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'Found It',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const AuthenticationWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/verification': (context) => VerificationPage(
            email: ModalRoute.of(context)!.settings.arguments as String
        ),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(), // Register the profile screen route.  You can remove this if you are not using it.
        '/profile_page': (context) => const ProfilePage(), // Register the new profile page route
        '/upload_item': (context) => const UploadItemScreen(),
        '/view_item': (context) => ViewItemScreen(
            itemId: ModalRoute.of(context)!.settings.arguments as int
        ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    setState(() {
      _isAuthenticated = isLoggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _isAuthenticated ? const HomeScreen() : const LoginPage();
  }
}

