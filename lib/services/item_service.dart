import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_platform/universal_platform.dart';
import '../models/item.dart';
import '../config/api_config.dart';

class ItemService {
  final storage = const FlutterSecureStorage();
  Map<String, String> get _headers => ApiConfig.headers;

  // IMPORTANT! This method id DEPRECATED
  String? _getToken() {
    if (kIsWeb) {
      // Use SharedPreferences for web instead of localStorage
      return const FlutterSecureStorage().read(key: 'jwt_token') as String?;
    } else {
      // Mobile implementation
      return const FlutterSecureStorage().read(key: 'jwt_token') as String?;
    }
  }

  //Final Method For Tokens
  Future<String?> getToken() async {
    if (UniversalPlatform.isWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwt_token');
    } else {
      return await storage.read(key: 'jwt_token');
    }
  }

  // Get image by ID - kept for backward compatibility
  Future<List<int>?> getItemImage(int imageId) async {
    print('Warning: getItemImage is deprecated. Images are now stored as base64 in the item.');

    try {
      final headers = _getHeaders();
      final url = '${ApiConfig.getImageUrl}/$imageId';

      print('Getting image from URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      _logResponse('Get Image', response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      } else {
        print('Failed to get image: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting image: $e');
      return null;
    }
  }

  // Get headers with auth token
  Map<String, String> _getHeaders() {
    final token = getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    return headers;
  }

  // Log response for debugging
  void _logResponse(String operation, http.Response response) {
    print('$operation Response status: ${response.statusCode}');

    // Print first 200 chars of body to avoid huge logs
    final preview = response.body.length > 200
        ? '${response.body.substring(0, 200)}...'
        : response.body;
    print('$operation Response preview: $preview');

    // Check for HTML response
    if (response.body.trim().startsWith('<!DOCTYPE') ||
        response.body.trim().startsWith('<html')) {
      print('WARNING: Received HTML response instead of expected JSON');
    }
  }

  // Get all items
  Future<List<Item>?> getAllItems() async {
    final token = await getToken();

    if (token == null) return null;

    try {
      final url = ApiConfig.getAllItemsUrl;
      print('Fetching all items with URL: $url');

      final response = await http.get(
        Uri.parse(ApiConfig.getAllItemsUrl),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token'
        },
      );

      _logResponse('Get All Items', response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final List<dynamic> itemsJson = jsonDecode(response.body);
          return itemsJson.map((json) => Item.fromJson(json)).toList();
        } catch (e) {
          print('JSON parsing error: $e');
          return [];
        }
      } else {
        print('Failed to load items: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error getting all items: $e');
      return [];
    }
  }

  // Create a new item with images as base64
  // Future<Item?> createItem(Item item, {List<Uint8List>? imageBytes, List<String>? imageNames}) async {
  //   //REMOVE THIS TODO:
  //   final token = await getToken();
  //
  //   if (token == null) return null;
  //
  //   try {
  //     final headers = _getHeaders();
  //
  //     // If images were provided separately, convert them to base64 and add to the item
  //     if (imageBytes != null && imageBytes.isNotEmpty) {
  //       final List<ItemImage> images = [];
  //
  //       for (int i = 0; i < imageBytes.length; i++) {
  //         final String base64Image = base64Encode(imageBytes[i]);
  //         final String imageName = i < imageNames!.length ? imageNames[i] : 'image_${i+1}.jpg';
  //
  //         images.add(ItemImage(
  //           description: 'Image of ${item.itemName}',
  //           image: '$base64Image',
  //           locationFound: item.locationFound,
  //           dateTime: DateTime.now().toIso8601String().substring(11, 19), // HH:MM:SS
  //           status: item.status,
  //         ));
  //       }
  //
  //       // Create a new item with the images
  //       final newItem = Item(
  //         itemId: item.itemId,
  //         itemName: item.itemName,
  //         description: item.description,
  //         categoryId: item.categoryId,
  //         locationFound: item.locationFound,
  //         dateTimeFound: item.dateTimeFound,
  //         reportedBy: item.reportedBy,
  //         contactInfo: item.contactInfo,
  //         status: item.status,
  //         images: images,
  //       );
  //
  //       // Use the new item with images for the request
  //       item = newItem;
  //     }
  //
  //     final jsonData = item.toJson();
  //     final jsonBody = jsonEncode(jsonData);
  //     final url = ApiConfig.insertItemUrl;
  //
  //     print("Creating item at URL: $url");
  //     print("With headers: $headers");
  //     print("Sending JSON: $jsonBody");
  //
  //     // final response = await http.post(
  //     //   Uri.parse(url),
  //     //   headers: headers,
  //     //   body: jsonBody,
  //     // );
  //
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: {
  //         ..._headers,
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: jsonBody,
  //     );
  //
  //     _logResponse('Create Item', response);
  //
  //     if (response.statusCode >= 200 && response.statusCode < 300) {
  //       try {
  //         final responseJson = jsonDecode(response.body);
  //         return Item.fromJson(responseJson);
  //       } catch (e) {
  //         print('Error parsing response: $e');
  //         return null;
  //       }
  //     } else {
  //       print('Failed to create item: ${response.statusCode}');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('Error creating item: $e');
  //     return null;
  //   }
  // }

  Future<Item?> createItem(Item item, {List<Uint8List>? imageBytes, List<String>? imageNames}) async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final headers = _getHeaders();

      // If images are provided, map them into the updated ItemImage model
      if (imageBytes != null && imageBytes.isNotEmpty) {
        item = item.copyWith(
          images: List.generate(imageBytes.length, (i) {
            final base64Image = base64Encode(imageBytes[i]);
            final imageName = i < (imageNames?.length ?? 0) ? imageNames![i] : 'image_${i + 1}.jpg';

            return ItemImage(
              description: 'Image of ${item.itemName}',
              image: base64Image,
              locationFound: item.locationFound,
              dateTime: DateTime.now().toIso8601String(),
              status: item.status,
            );
          }),
        );
      }

      final jsonBody = jsonEncode(item.toJson());
      final url = ApiConfig.insertItemUrl;

      print("Creating item at URL: $url");
      print("With headers: $headers");
      print("Sending JSON: $jsonBody");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          ...headers,
          'Authorization': 'Bearer $token',
        },
        body: jsonBody,
      );

      _logResponse('Create Item', response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final responseJson = jsonDecode(response.body);
          return Item.fromJson(responseJson);
        } catch (e) {
          print('Error parsing response: $e');
          return null;
        }
      } else {
        print('Failed to create item: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating item: $e');
      return null;
    }
  }


  // Get item by ID
  Future<Item?> getItemById(int itemId) async {
    final token = await getToken();

    if (token == null) return null;

    try {

      final item_url = '${ApiConfig.getItemByIdUrl}/$itemId';
      print('Fetching items with URL: $item_url');

      final response = await http.get(
        Uri.parse(item_url),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token'
        },
      );


      // final headers = _getHeaders();
      // final url = '${ApiConfig.getItemByIdUrl}/$itemId';
      //
      // print('Getting item with URL: $url');
      //
      // final response = await http.get(
      //   Uri.parse(url),
      //   headers: headers,
      // );

      _logResponse('Get Item By ID', response);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final responseJson = jsonDecode(response.body);
          return Item.fromJson(responseJson);
        } catch (e) {
          print('Error parsing item response: $e');
          return null;
        }
      } else {
        print('Failed to get item: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting item: $e');
      return null;
    }
  }

  // This method will now upload an image for an item by updating the item
  // with a new image in base64 format
  Future<bool> uploadItemImage(int itemId, List<int> imageBytes, String imageName) async {
    try {
      // First, get the current item
      final item = await getItemById(itemId);
      if (item == null) {
        print('Failed to get item for image upload');
        return false;
      }

      // Convert image to base64
      final String base64Image = base64Encode(imageBytes);

      // Create a new image object
      final newImage = ItemImage(
        description: 'Image of ${item.itemName}',
        image: 'data:image/jpeg;base64,$base64Image',
        locationFound: item.locationFound,
        dateTime: DateTime.now().toIso8601String().substring(11, 19), // HH:MM:SS
        status: item.status,
      );

      // Add image to the item's images list
      final List<ItemImage> updatedImages = item.images?.toList() ?? [];
      updatedImages.add(newImage);

      // Create updated item
      final updatedItem = Item(
        itemId: item.itemId,
        itemName: item.itemName,
        description: item.description,
        categoryId: item.categoryId,
        locationFound: item.locationFound,
        dateTimeFound: item.dateTimeFound,
        reportedBy: item.reportedBy,
        contactInfo: item.contactInfo,
        status: item.status,
        images: updatedImages,
      );

      // Update the item with the new image
      final headers = _getHeaders();
      final jsonData = updatedItem.toJson();
      final jsonBody = jsonEncode(jsonData);
      final url = '${ApiConfig.updateItemUrl}/${item.itemId}';

      print('Uploading image to URL: $url');
      print('With headers: $headers');
      print('Sending JSON with image: ${jsonBody.substring(0, min(100, jsonBody.length))}...');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonBody,
      );

      _logResponse('Upload Image', response);

      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      print('Error uploading image: $e');
      return false;
    }
  }

  // Helper method to get minimum of two integers
  int min(int a, int b) {
    return a < b ? a : b;
  }
}