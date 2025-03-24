class Item {
  final int? itemId;
  final String? itemName;
  final String? description;
  final String? locationFound;
  final String? reportedBy;
  final String? contactInfo;
  final String? status;
  final DateTime? dateTimeFound;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Item({
    this.itemId,
    this.itemName,
    this.description,
    this.locationFound,
    this.reportedBy,
    this.contactInfo,
    this.status,
    this.dateTimeFound,
    this.createdAt,
    this.updatedAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json['item_id'],
      itemName: json['itemName'],
      description: json['description'],
      locationFound: json['locationFound'],
      reportedBy: json['reportedBy'],
      contactInfo: json['contactInfo'],
      status: json['status'],
      dateTimeFound: _parseDateTime(json['dateTimeFound']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'itemName': itemName,
      'description': description,
      'locationFound': locationFound,
      'reportedBy': reportedBy,
      'contactInfo': contactInfo,
      'status': status,
      'dateTimeFound': dateTimeFound?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic dateList) {
    if (dateList is List && dateList.length >= 6) {
      return DateTime(
        dateList[0],
        dateList[1],
        dateList[2],
        dateList[3],
        dateList[4],
        dateList[5],
      );
    }
    return null;
  }
}
