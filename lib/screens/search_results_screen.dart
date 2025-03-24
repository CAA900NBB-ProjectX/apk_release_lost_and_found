import 'package:flutter/material.dart';
import '../models/item.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:intl/intl.dart';


class SearchResultsScreen extends StatefulWidget {
  final String query;
  final List<Item> foundItems;
  final List<Item> lostItems;

  const SearchResultsScreen({
    Key? key,
    required this.query,
    required this.foundItems,
    required this.lostItems,
  }) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Results for "${widget.query}"',
          style: const TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              text: 'Found Items (${widget.foundItems.length})',
            ),
            Tab(
              text: 'Lost Items (${widget.lostItems.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildItemList(widget.foundItems),
          _buildItemList(widget.lostItems),
        ],
      ),
    );
  }

  Widget _buildItemList(List<Item> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No matching items found',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _getCategoryColor(item.categoryId),
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.images != null && item.images!.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  _decodeBase64Image(item.images![0].image),
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(
                _getCategoryIcon(item.categoryId),
                color: Colors.white,
                size: 30,
              ),
            ),
            title: Text(
              item.itemName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  item.getCategoryName(),
                  style: TextStyle(color: Colors.green[300], fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  'Location: ${item.locationFound}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  'Date: ${_formatDate(item.dateTimeFound)}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/view_item',
                arguments: item.itemId,
              );
            },
          ),
        );
      },
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
      return DateFormat('MMM d, yyyy').format(date);
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
    switch (categoryId) {
      case 1: return Colors.green[700]!;
      case 2: return Colors.green[500]!;
      case 3: return Colors.green[300]!;
      case 4: return Colors.teal;
      default: return Colors.green;
    }
  }
}