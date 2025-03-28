
// class ItemImage {
//   final String? description;
//   final String image; // Base64 encoded image
//   final String? locationFound;
//   final String? dateTime;
//   final String? status;
//
//   ItemImage({
//     this.description,
//     required this.image,
//     this.locationFound,
//     this.dateTime,
//     this.status,
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       if (description != null) 'description': description,
//       'image': image,
//       if (locationFound != null) 'locationFound': locationFound,
//       if (dateTime != null) 'dateTime': dateTime,
//       if (status != null) 'status': status,
//     };
//   }
//
//   factory ItemImage.fromJson(Map<String, dynamic> json) {
//     return ItemImage(
//       description: json['description'],
//       image: json['image'],
//       locationFound: json['locationFound'],
//       dateTime: json['dateTime'],
//       status: json['status'],
//     );
//   }
// }

class ItemImage {
  final String? description;
  final String image; // Base64 encoded image
  final String? locationFound;
  final String? dateTime;
  final String? status;

  ItemImage({
    this.description,
    required this.image,
    this.locationFound,
    this.dateTime,
    this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      if (description != null) 'description': description,
      'image': image,
      if (locationFound != null) 'locationFound': locationFound,
      if (dateTime != null) 'dateTime': dateTime,
      if (status != null) 'status': status,
    };
  }

  factory ItemImage.fromJson(Map<String, dynamic> json) {
    // Parse date time from array or string
    String? parseDateTimeValue(dynamic value) {
      if (value == null) {
        return null;
      }

      if (value is List) {
        try {
          // Handle different array lengths
          if (value.length >= 3) {
            final year = value.length > 0 ? value[0] : DateTime.now().year;
            final month = value.length > 1 ? value[1] : 1;
            final day = value.length > 2 ? value[2] : 1;
            final hour = value.length > 3 ? value[3] : 0;
            final minute = value.length > 4 ? value[4] : 0;
            final second = value.length > 5 ? value[5] : 0;

            return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}T' '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
          } else {
            print('Date array too short');
            return null;
          }
        } catch (e) {
          print('Error parsing dateTime array: $e');
          return null;
        }
      } else if (value is String) {
        return value;
      }
      return null;
    }

    return ItemImage(
      description: json['description'],
      image: json['image'],
      locationFound: json['locationFound'],
      dateTime: parseDateTimeValue(json['dateTime']),
      status: json['status'],
    );
  }
}

class Item {
  final int? itemId;
  final String itemName;
  final String description;
  final int categoryId;
  final String locationFound;
  final String dateTimeFound;
  final String reportedBy;
  final String contactInfo;
  final String status;
  final List<ItemImage>? images;

  Item({
    this.itemId,
    required this.itemName,
    required this.description,
    required this.categoryId,
    required this.locationFound,
    required this.dateTimeFound,
    required this.reportedBy,
    required this.contactInfo,
    this.status = "FOUND",
    this.images,
  });

  // factory Item.fromJson(Map<String, dynamic> json) {
  //   // This method stays mostly the same, but let's make sure the dateTimeFound parsing works:
  //
  //   String parseDateTimeFound(dynamic value) {
  //     if (value == null) {
  //       return DateTime.now().toIso8601String();
  //     }
  //
  //     if (value is List) {
  //       // Convert [2025, 3, 14, 17, 42, 38] to a DateTime string
  //       try {
  //         final year = value[0];
  //         final month = value[1];
  //         final day = value[2];
  //         final hour = value.length > 3 ? value[3] : 0;
  //         final minute = value.length > 4 ? value[4] : 0;
  //         final second = value.length > 5 ? value[5] : 0;
  //
  //         return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}T' '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
  //       } catch (e) {
  //         print('Error parsing dateTime array: $e');
  //         return DateTime.now().toIso8601String();
  //       }
  //     } else if (value is String) {
  //       return value;
  //     } else {
  //       return DateTime.now().toIso8601String();
  //     }
  //   }
  //
  //
  //
  //   // Handle multiple possible keys for itemId
  //   int? getItemId() {
  //     if (json.containsKey('item_id')) {
  //       return json['item_id'] as int?;
  //     }
  //     if (json.containsKey('itemId')) {
  //       return json['itemId'] as int?;
  //     }
  //     if (json.containsKey('id')) {
  //       return json['id'] as int?;
  //     }
  //     return null;
  //   }
  //
  //   // Parse images if available
  //   List<ItemImage>? parseImages() {
  //     if (json['images'] != null && json['images'] is List) {
  //       return (json['images'] as List)
  //           .map((imgJson) => ItemImage.fromJson(imgJson))
  //           .toList();
  //     }
  //     return null;
  //   }
  //
  //   return Item(
  //     itemId: getItemId(),
  //     itemName: json['itemName'] ?? '',
  //     description: json['description'] ?? '',
  //     categoryId: json['categoryId'] ?? 0,
  //     locationFound: json['locationFound'] ?? '',
  //     dateTimeFound: parseDateTimeFound(json['dateTimeFound']),
  //     reportedBy: json['reportedBy'] ?? '',
  //     contactInfo: json['contactInfo'] ?? '',
  //     status: json['status'] ?? "FOUND",
  //     images: parseImages(),
  //   );
  // }

  factory Item.fromJson(Map<String, dynamic> json) {
    // Parse date time function
    String parseDateTimeFound(dynamic value) {
      if (value == null) {
        return DateTime.now().toIso8601String();
      }

      if (value is List) {
        try {
          // Handle different array lengths
          if (value.length >= 3) {
            final year = value.length > 0 ? value[0] : DateTime.now().year;
            final month = value.length > 1 ? value[1] : 1;
            final day = value.length > 2 ? value[2] : 1;
            final hour = value.length > 3 ? value[3] : 0;
            final minute = value.length > 4 ? value[4] : 0;
            final second = value.length > 5 ? value[5] : 0;

            return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}T' '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}';
          } else {
            print('Date array too short, using current time');
            return DateTime.now().toIso8601String();
          }
        } catch (e) {
          print('Error parsing dateTime array: $e');
          return DateTime.now().toIso8601String();
        }
      } else if (value is String) {
        return value;
      } else {
        return DateTime.now().toIso8601String();
      }
    }

    // Handle multiple possible keys for itemId
    int? getItemId() {
      if (json.containsKey('item_id')) {
        return json['item_id'] as int?;
      }
      if (json.containsKey('itemId')) {
        return json['itemId'] as int?;
      }
      if (json.containsKey('id')) {
        return json['id'] as int?;
      }
      return null;
    }

    // Parse images if available
    List<ItemImage>? parseImages() {
      if (json['images'] != null && json['images'] is List) {
        return (json['images'] as List)
            .map((imgJson) => ItemImage.fromJson(imgJson))
            .toList();
      }
      return null;
    }

    return Item(
      itemId: getItemId(),
      itemName: json['itemName'] ?? '',
      description: json['description'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      locationFound: json['locationFound'] ?? '',
      dateTimeFound: parseDateTimeFound(json['dateTimeFound']),
      reportedBy: json['reportedBy'] ?? '',
      contactInfo: json['contactInfo'] ?? '',
      status: json['status'] ?? "FOUND",
      images: parseImages(),
    );
  }


  Map<String, dynamic> toJson() {
    final map = {
      'itemName': itemName,
      'description': description,
      'categoryId': categoryId,
      'locationFound': locationFound,
      'dateTimeFound': dateTimeFound,
      'reportedBy': reportedBy,
      'contactInfo': contactInfo,
      'status': status,
    };

    if (images != null && images!.isNotEmpty) {
      map['images'] = images!.map((img) => img.toJson()).toList();
    }

    return map;
  }

  // Helper method to get category name from category ID
  String getCategoryName() {
    switch (categoryId) {
      case 1:
        return 'Electronics';
      case 2:
        return 'Clothing';
      case 3:
        return 'Accessories';
      case 4:
        return 'Documents';
      case 5:
        return 'Other';
      default:
        return 'Unknown';
    }
  }

  Item copyWith({
    int? itemId,
    String? itemName,
    String? description,
    int? categoryId,
    String? locationFound,
    String? dateTimeFound,
    String? reportedBy,
    String? contactInfo,
    String? status,
    List<ItemImage>? images,
  }) {
    return Item(
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      locationFound: locationFound ?? this.locationFound,
      dateTimeFound: dateTimeFound ?? this.dateTimeFound,
      reportedBy: reportedBy ?? this.reportedBy,
      contactInfo: contactInfo ?? this.contactInfo,
      status: status ?? this.status,
      images: images ?? this.images,
    );
  }


}