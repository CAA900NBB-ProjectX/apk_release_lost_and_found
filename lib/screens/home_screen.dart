import 'package:flutter/material.dart';
import 'package:found_it_frontend/screens/search_results_screen.dart';
import '../models/item.dart';
import '../services/item_service.dart';
import '../auth/services/auth_service.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'profile_page.dart'; // Import ProfilePage

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ItemService _itemService = ItemService();
  final AuthService _authService = AuthService();
  List<Item> _allItems = [];
  List<Item> _foundItems = [];
  List<Item> _lostItems = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _itemService.getAllItems();

      if (mounted) {
        setState(() {
          _allItems = items!;
          _foundItems = items.where((item) => item.status == "FOUND").toList();
          _lostItems = items.where((item) => item.status == "LOST").toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load items: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Search functionality
      _showSearchDialog();
      return;
    }

    // Directly navigate to ProfilePage
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  // void _showSearchDialog() {
  //   final TextEditingController searchController = TextEditingController();
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       backgroundColor: Colors.grey[900],
  //       title: const Text('Search Items', style: TextStyle(color: Colors.white)),
  //       content: TextField(
  //         controller: searchController,
  //         style: const TextStyle(color: Colors.white),
  //         decoration: InputDecoration(
  //           hintText: 'Enter item name or description',
  //           hintStyle: TextStyle(color: Colors.grey[400]),
  //           filled: true,
  //           fillColor: Colors.grey[800],
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(8),
  //             borderSide: BorderSide.none,
  //           ),
  //           prefixIcon: const Icon(Icons.search, color: Colors.green),
  //         ),
  //         onSubmitted: (value) {
  //           _performSearch(value);
  //           Navigator.pop(context);
  //         },
  //       ),
  //       actions: [
  //         TextButton(
  //           child: const Text('Cancel', style: TextStyle(color: Colors.green)),
  //           onPressed: () => Navigator.pop(context),
  //         ),
  //         TextButton(
  //           child: const Text('Search', style: TextStyle(color: Colors.green)),
  //           onPressed: () {
  //             _performSearch(searchController.text);
  //             Navigator.pop(context);
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showSearchDialog() {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Search Items', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter item name or description',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.green),
          ),
          onSubmitted: (value) {
            Navigator.pop(context); // Close the dialog first
            _performSearch(value); // Then perform the search
          },
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.green)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Search', style: TextStyle(color: Colors.green)),
            onPressed: () {
              Navigator.pop(context); // Close the dialog first
              _performSearch(searchController.text); // Then perform the search
            },
          ),
        ],
      ),
    );
  }
  // void _performSearch(String query) {
  //   if (query.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Please enter a search term'),
  //         backgroundColor: Colors.amber,
  //       ),
  //     );
  //     return;
  //   }
  //
  //   final String searchTerm = query.toLowerCase();
  //
  //   // Create filtered lists based on the search query
  //   final List<Item> filteredFoundItems = _allItems
  //       .where((item) =>
  //   item.status == "FOUND" && (_itemMatchesSearch(item, searchTerm)))
  //       .toList();
  //
  //   final List<Item> filteredLostItems = _allItems
  //       .where((item) =>
  //   item.status == "LOST" && (_itemMatchesSearch(item, searchTerm)))
  //       .toList();
  //
  //   // Show search results
  //   if (filteredFoundItems.isEmpty && filteredLostItems.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('No items match "$query"'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }
  //
  //   // Navigate to search results screen
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => SearchResultsScreen(
  //         query: query,
  //         foundItems: filteredFoundItems,
  //         lostItems: filteredLostItems,
  //       ),
  //     ),
  //   ).then((_) => _loadItems()); // Refresh items when returning
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content:
  //       Text('Found ${filteredFoundItems.length + filteredLostItems.length} matching items'),
  //       backgroundColor: Colors.green,
  //     ),
  //   );
  // }

  void _performSearch(String query) {
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a search term'),
          backgroundColor: Colors.amber,
        ),
      );
      return;
    }

    final String searchTerm = query.toLowerCase();

    // Create filtered lists based on the search query
    final List<Item> filteredFoundItems = _allItems
        .where((item) =>
    item.status == "FOUND" && (_itemMatchesSearch(item, searchTerm)))
        .toList();

    final List<Item> filteredLostItems = _allItems
        .where((item) =>
    item.status == "LOST" && (_itemMatchesSearch(item, searchTerm)))
        .toList();

    // Check if any items match the search
    if (filteredFoundItems.isEmpty && filteredLostItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No items match "$query"'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to search results screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          query: query,
          foundItems: filteredFoundItems,
          lostItems: filteredLostItems,
        ),
      ),
    ).then((_) => _loadItems()); // Refresh items when returning

    // Show a snackbar with the number of matching items
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Found ${filteredFoundItems.length + filteredLostItems.length} matching items',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  bool _itemMatchesSearch(Item item, String searchTerm) {
    // Check for matches in various item fields
    return item.itemName.toLowerCase().contains(searchTerm) ||
        item.description.toLowerCase().contains(searchTerm) ||
        item.locationFound.toLowerCase().contains(searchTerm) ||
        item.getCategoryName().toLowerCase().contains(searchTerm);
  }


  Widget _getBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.green));
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }

    switch (_selectedIndex) {
      case 0:
        return _buildItemGrid(_foundItems);
      case 1:
        return _buildItemGrid(_lostItems);
      default:
        return _buildItemGrid(_foundItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Found It!', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: Colors.green,
        onRefresh: _loadItems,
        child: _getBody(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex:
        _selectedIndex > 1 ? _selectedIndex - 2 : _selectedIndex, // Adjust for additional items
        type: BottomNavigationBarType.fixed, // Important for 4+ items
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Found Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Lost Items',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_search),
            activeIcon: Icon(Icons.manage_search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.pushNamed(context, '/upload_item').then((_) => _loadItems());
        },
        label: Text(_selectedIndex == 0 ? 'Report Found Item' : 'Report Lost Item'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildItemGrid(List<Item> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No items available', style: TextStyle(fontSize: 18, color: Colors.white)),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemTile(item);
      },
    );
  }

  Widget _buildItemTile(Item item) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/view_item',
          arguments: item.itemId,
        ).then((_) => _loadItems());
      },
      child: Card(
        elevation: 4,
        color: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image or placeholder - Fixed height to prevent overflow
            Container(
              height: 120, // Fixed height for image section
              decoration: BoxDecoration(
                color: _getCategoryColor(item.categoryId),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              width: double.infinity,
              child: item.images != null && item.images!.isNotEmpty
                  ? Image.memory(
                _decodeBase64Image(item.images![0].image),
                fit: BoxFit.cover,
              )
                  : Center(
                child: Icon(
                  _getCategoryIcon(item.categoryId),
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            // Item details - Using Expanded for the remaining space
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Important for preventing overflow
                  children: [
                    Text(
                      item.itemName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14, // Reduced font size
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), // Reduced spacing
                    Text(
                      item.getCategoryName(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10, // Reduced font size
                      ),
                    ),
                    const SizedBox(height: 2), // Reduced spacing
                    Text(
                      'Location: ${item.locationFound}',
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), // Reduced spacing
                    Text(
                      'Date: ${_formatDate(item.dateTimeFound)}',
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to safely decode base64 images
  Uint8List _decodeBase64Image(String base64String) {
    // Remove data:image/jpeg;base64, or similar prefixes if present
    String sanitized = base64String;
    if (base64String.contains(',')) {
      sanitized = base64String.split(',')[1];
    }

    try {
      return base64Decode(sanitized);
    } catch (e) {
      // Return a 1x1 transparent pixel as fallback
      return Uint8List.fromList([0, 0, 0, 0]);
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, hh:mm a').format(date);
    } catch (e) {
      return dateString;
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
    // You might want to adjust these colors to match your green theme
    switch (categoryId) {
      case 1: return Colors.green[700]!;
      case 2: return Colors.green[500]!;
      case 3: return Colors.green[300]!;
      case 4: return Colors.teal;
      default: return Colors.green;
    }
  }
}

