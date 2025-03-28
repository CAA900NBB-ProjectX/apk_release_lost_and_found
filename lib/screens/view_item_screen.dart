import 'dart:io';

import 'package:flutter/material.dart';
import 'package:found_it_frontend/screens/home_screen.dart';
import 'package:found_it_frontend/screens/profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/item.dart';
import '../services/item_service.dart';
import 'dart:convert';
import '../auth/services/auth_service.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';
import 'chat_list_screen.dart';


class ViewItemScreen extends StatefulWidget {
  final int itemId;

  const ViewItemScreen({Key? key, required this.itemId}) : super(key: key);

  @override
  State<ViewItemScreen> createState() => _ViewItemScreenState();
}

class _ViewItemScreenState extends State<ViewItemScreen> {
  final ItemService _itemService = ItemService();
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  String? _errorMessage;
  Item? _item;
  List<Uint8List> _images = [];
  int _selectedIndex = 0;

  // Define a green color for buttons
  final Color buttonColor = Colors.green;

  @override
  void initState() {
    super.initState();
    _fetchItemDetails();
  }

  Future<void> _fetchItemDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final item = await _itemService.getItemById(widget.itemId);

      if (mounted) {
        if (item != null) {
          setState(() {
            _item = item;
            _isLoading = false;
          });


          if (item.images != null && item.images!.isNotEmpty) {
            _loadImagesFromBase64(item.images!);
          }
        } else {
          setState(() {
            _errorMessage = 'Item not found';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load item: $e';
          _isLoading = false;
        });
      }
    }
  }

  // void _loadImagesFromBase64(List<ItemImage> images) {
  //   for (var image in images) {
  //     try {
  //       final base64Data = image.image.split(',')[1];
  //       final imageData = base64Decode(base64Data);
  //
  //       if (mounted) {
  //         setState(() {
  //           _images.add(Uint8List.fromList(imageData));
  //         });
  //       }
  //     } catch (e) {
  //       print('Error loading image from base64: $e');
  //     }
  //   }
  // }


  void _loadImagesFromBase64(List<ItemImage> images) {
    for (var image in images) {
      try {
        // Safely handle base64 data with or without prefix
        String base64Data = image.image;
        if (base64Data.contains(',')) {
          base64Data = base64Data.split(',')[1];
        }

        final imageData = base64Decode(base64Data);

        if (mounted) {
          setState(() {
            _images.add(Uint8List.fromList(imageData));
          });
        }
      } catch (e) {
        print('Error loading image from base64: $e');
        // Optionally add a placeholder image when decoding fails
        // _images.add(Uint8List.fromList([0, 0, 0, 0])); // 1x1 transparent pixel
      }
    }
  }
  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate based on the selected tab
    switch (index) {
      case 0:
      // Found Items - You would navigate to this screen
      //   ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text('Navigate to Found Items'))
      //   );
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen())
            );
        break;
      case 1:
      // Lost Items - You would navigate to this screen
      //   ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text('Navigate to Lost Items'))
      //   );
      //
      //
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen())
        );
        break;
      case 2:
      // Profile - You would navigate to this screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text('Navigate to Profile'))
        // );
        break;
    }
  }

  Future<void> _initiateChat() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        content: Row(
          children: [
            CircularProgressIndicator(color: buttonColor),
            SizedBox(width: 16),
            Text('Connecting to chat...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );

    try {
      final chatService = ChatService();
      final token = await _authService.getToken();

      if (token == null) {
        if (context.mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please log in to chat'),
              backgroundColor: Colors.red,
            )
        );
        return;
      }


      final String? currentUsername = extractUsernameFromToken(token);
      if (currentUsername == null) {
        if (context.mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to get user information from token'),
              backgroundColor: Colors.red,
            )
        );
        return;
      }

      final int itemId = _item?.itemId ?? 0;
      final String reportedBy = _item?.reportedBy ?? "";


      if (currentUsername == reportedBy) {
        // Close loading dialog
        if (context.mounted) Navigator.pop(context);

        //Bro  if the current user is the reporter, show the chat list
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatListScreen(
                itemId: itemId,
                itemName: _item?.itemName ?? "Item",
                reportedBy: reportedBy,
              ),
            ),
          );
        }
        return;
      }


      final existingChat = await chatService.checkExistingChat(
        token,
        reportedBy,
        itemId,
      );

      String? chatId;

      if (existingChat != null) {
        chatId = existingChat['id'] as String?;
      } else {
        chatId = await chatService.createChat(
          token,
          reportedBy,
          itemId,
        );
      }

      if (context.mounted) Navigator.pop(context);

      if (chatId != null && chatId.isNotEmpty && context.mounted) {
        final String nonNullChatId = chatId;
        final String itemName = _item?.itemName ?? "Item";

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              chatId: nonNullChatId,
              currentUsername: currentUsername,
              receiverUsername: reportedBy,
              itemId: itemId,
              itemName: itemName,
              receiver: reportedBy, // need to check n]bro
            ),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to start chat. Please try again.'),
              backgroundColor: Colors.red,
            )
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          )
      );
    }
  }

  String? extractUsernameFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> data = json.decode(decoded);


      return data['username'] ??
          data['preferred_username'] ??
          data['email'] ??
          data['sub'] ??
          data['userId'] ??
          data['name'];
    } catch (e) {
      print('Error extracting username from token: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          _item?.itemName ?? 'Item Details',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: buttonColor))
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!, style: TextStyle(color: Colors.red)))
            : _buildItemDetails(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: buttonColor,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Found Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Lost Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildItemDetails() {
    if (_item == null) {
      return Center(child: Text('No item data available', style: TextStyle(color: Colors.white)));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Reduced vertical padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_images.isNotEmpty)
            SizedBox(
              height: 200, // Reduced from 250
              child: PageView.builder(
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.grey[900],
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 4.0), // Smaller margins
                    child: Padding(
                      padding: const EdgeInsets.all(4.0), // Reduced padding
                      child: Image.memory(
                        _images[index],
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 180, // Reduced from 200
              width: double.infinity,
              decoration: BoxDecoration(
                color: _getCategoryColor(_item!.categoryId),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  _getCategoryIcon(_item!.categoryId),
                  size: 70, // Reduced from 80
                  color: Colors.white,
                ),
              ),
            ),

          const SizedBox(height: 12), // Reduced from 20

          // Item details
          Card(
            color: Colors.grey[900],
            elevation: 4,
            margin: EdgeInsets.symmetric(vertical: 4.0), // Smaller margins
            child: Padding(
              padding: const EdgeInsets.all(12.0), // Reduced from 16
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _item!.itemName,
                    style: TextStyle(
                      fontSize: 20, // Reduced from 24
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Chip(
                    label: Text(
                      _item!.status,
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: _item!.status == "FOUND" ? Colors.green : Colors.orange,
                    padding: EdgeInsets.all(0), // Minimize internal padding
                  ),
                  const Divider(height: 16, color: Colors.grey), // Reduced from 24

                  _buildDetailRow(Icons.category, 'Category', _item!.getCategoryName()),
                  _buildDetailRow(Icons.description, 'Description', _item!.description),
                  _buildDetailRow(Icons.location_on, 'Location Found', _item!.locationFound),
                  _buildDetailRow(Icons.calendar_today, 'Date Found', _formatDate(_item!.dateTimeFound)),
                  _buildDetailRow(Icons.person, 'Reported By', _item!.reportedBy),

                  const SizedBox(height: 12), // Reduced from 20

                  // Contact section
                  Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 16, // Reduced from 18
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6), // Reduced from 10
                  Container(
                    padding: const EdgeInsets.all(8), // Reduced from 12
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.contact_mail, color: Colors.white, size: 18), // Reduced size
                        const SizedBox(width: 8), // Reduced from 12
                        Expanded(
                          child: Text(
                            _item!.contactInfo,
                            style: TextStyle(fontSize: 14, color: Colors.white), // Reduced from 16
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12), // Reduced from 20

          // Add bottom padding to avoid overflow with bottom navigation bar
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _initiateChat,
                    icon: Icon(Icons.email, color: Colors.white, size: 18), // Reduced icon size
                    label: Text('Chat', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      padding: const EdgeInsets.symmetric(vertical: 8), // Reduced from 12
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _shareItemDetails,
    icon: Icon(Icons.share, color: buttonColor, size: 18),
    label: Text('Share', style: TextStyle(color: buttonColor)),
    style: OutlinedButton.styleFrom(
    side: BorderSide(color: buttonColor),
    padding: const EdgeInsets.symmetric(vertical: 8),
    ),
    ),
                    // icon: Icon(Icons.share, color: buttonColor, size: 18), // Reduced icon size
                    // label: Text('Share', style: TextStyle(color: buttonColor)),
                    // style: OutlinedButton.styleFrom(
                    //   side: BorderSide(color: buttonColor),
                    //   padding: const EdgeInsets.symmetric(vertical: 8), // Reduced from 12
                    // ),
                  ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0), // Reduced from 8
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[400]), // Reduced from 20
          const SizedBox(width: 8), // Reduced from 12
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12, // Reduced from 14
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 2), // Reduced from 4
                Text(
                  value,
                  style: TextStyle(fontSize: 14, color: Colors.white), // Reduced from 16
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareItemDetails() async {
    if (_item == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No item details available to share'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Construct a readable share text
    final shareText = '''
Found Item Details:
Name: ${_item!.itemName}
Category: ${_item!.getCategoryName()}
Location: ${_item!.locationFound}
Date Found: ${_formatDate(_item!.dateTimeFound)}
Description: ${_item!.description}

Contact: ${_item!.contactInfo}
Status: ${_item!.status}
''';

    // Prepare image to share (optional)
    XFile? imageToShare;
    if (_images.isNotEmpty) {
      try {
        // Save the first image to a temporary file
        final tempDir = await getTemporaryDirectory();
        final tempFile = await File('${tempDir.path}/item_image.png').create();
        await tempFile.writeAsBytes(_images.first);
        imageToShare = XFile(tempFile.path);
      } catch (e) {
        print('Error preparing image for sharing: $e');
      }
    }

    try {
      // Share with optional image
      await Share.shareXFiles(
        imageToShare != null ? [imageToShare] : [],
        text: shareText,
        subject: 'Found Item: ${_item!.itemName}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to share item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  IconData _getCategoryIcon(int categoryId) {
    switch (categoryId) {
      case 1: return Icons.devices;
      case 2: return Icons.checkroom;
      case 3: return Icons.watch;
      case 4: return Icons.description;
      default: return Icons.category;
    }
  }

  Color _getCategoryColor(int categoryId) {
    switch (categoryId) {
      case 1: return Colors.blue;
      case 2: return Colors.green;
      case 3: return Colors.orange;
      case 4: return Colors.purple;
      default: return Colors.grey;
    }
  }
}