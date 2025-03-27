import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';
import '../config/api_config.dart';
import '../models/profile.dart';

class ProfileService {
  Future<String?> getToken() async {

    final storage = const FlutterSecureStorage();

    if (UniversalPlatform.isWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwt_token');
    } else {
      return await storage.read(key: 'jwt_token');
    }
  }


  Future<Profile> fetchUserProfile() async {
    final token = await getToken();
    if (token == null) throw Exception('No authentication token');

    Map<String, String> _headers = ApiConfig.headers;

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int userId = decodedToken['user']['id'];
    print('User ID: $userId');

    final String userUrl = '${ApiConfig.userByIdUrl}?userId=$userId';

    try {
      final response = await http.get(
        Uri.parse(userUrl),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);
        if (profileData == null) {
          throw Exception('Profile data is null');
        }
        return Profile.fromJson(profileData);
      } else {
        print('Failed to load profile: ${response.statusCode}');
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      print('Error fetching profile: $e');
      rethrow;
    }
  }
}