import 'package:flutter/material.dart';
import '../auth/services/auth_service.dart';
import 'package:found_it_frontend/models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  User? _currentUser;
  String? _errorMessage;

  // Green and black theme colors
  final Color primaryGreen = const Color(0xFF2E7D32); // Dark green
  final Color darkGreen = const Color(0xFF1B5E20);    // Darker green for accents
  final Color accentGreen = const Color(0xFF4CAF50); // Light green for highlights
  final Color blackColor = Colors.black;
  final Color darkGrey = const Color(0xFF212121);    // Almost black
  final Color lightText = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _authService.getCurrentUser();
      setState(() {
        _currentUser = user as User?;
        _isLoading = false;
      });

      if (user == null) {
        setState(() {
          _errorMessage = 'Unable to load profile. Please login again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load profile: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGrey,
      appBar: AppBar(
        backgroundColor: blackColor,
        title: Text(
          'My Profile',
          style: TextStyle(color: lightText, fontWeight: FontWeight.bold),
        ),
        iconTheme: IconThemeData(color: lightText),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: accentGreen),
            onPressed: () async {
              try {
                await _authService.logout();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: primaryGreen,
        ),
      )
          : _errorMessage != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    if (_currentUser == null) {
      return Center(
        child: Text(
          'User profile not available',
          style: TextStyle(color: lightText),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Picture Container with green border
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryGreen, width: 4),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: darkGreen,
              backgroundImage: _currentUser!.profilePicture != null
                  ? NetworkImage(_currentUser!.profilePicture!)
                  : null,
              child: _currentUser!.profilePicture == null
                  ? Text(
                _getInitials(_currentUser!.name ?? _currentUser!.username),
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: lightText,
                ),
              )
                  : null,
            ),
          ),
          const SizedBox(height: 24),

          // User name (if available) or username
          Text(
            _currentUser!.name ?? _currentUser!.username,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: lightText,
            ),
          ),
          const SizedBox(height: 8),

          // Username with @ symbol
          Text(
            '@${_currentUser!.username}',
            style: TextStyle(
              fontSize: 18,
              color: accentGreen,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Email
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentUser!.email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
              if (_currentUser!.emailVerified)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.verified,
                    color: accentGreen,
                    size: 16,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32),

          // User details card
          Card(
            elevation: 8,
            color: blackColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: darkGreen, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Profile Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: lightText,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: darkGreen, thickness: 1),
                  if (_currentUser!.name != null)
                    _buildInfoRow('Name', _currentUser!.name!),
                  _buildInfoRow('Username', _currentUser!.username),
                  _buildInfoRow('Email', _currentUser!.email),
                  _buildInfoRow('Email Verified', _currentUser!.emailVerified ? 'Yes' : 'No'),
                  _buildInfoRow('Account Status', _currentUser!.enabled ? 'Active' : 'Inactive'),
                  _buildInfoRow('ID', _currentUser!.id),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Actions card
          Card(
            elevation: 8,
            color: blackColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: darkGreen, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings, color: primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Account Options',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: lightText,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: darkGreen, thickness: 1),
                  _buildActionTile(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Edit profile feature coming soon'),
                          backgroundColor: darkGreen,
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.image,
                    title: 'Change Profile Picture',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Change picture feature coming soon'),
                          backgroundColor: darkGreen,
                        ),
                      );
                    },
                  ),
                  if (!_currentUser!.emailVerified)
                    _buildActionTile(
                      icon: Icons.email,
                      title: 'Verify Email',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Email verification process will start'),
                            backgroundColor: darkGreen,
                          ),
                        );
                      },
                    ),
                  _buildActionTile(
                    icon: Icons.lock,
                    title: 'Security Settings',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Security settings feature coming soon'),
                          backgroundColor: darkGreen,
                        ),
                      );
                    },
                  ),
                  _buildActionTile(
                    icon: Icons.notifications,
                    title: 'Notification Preferences',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Notification preferences feature coming soon'),
                          backgroundColor: darkGreen,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[400],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: lightText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: accentGreen),
      title: Text(
        title,
        style: TextStyle(color: lightText),
      ),
      trailing: Icon(Icons.chevron_right, color: accentGreen),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else {
      return name.substring(0, 1).toUpperCase();
    }
  }
}