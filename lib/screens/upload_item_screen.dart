import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../models/item.dart';
import '../services/item_service.dart';
import '../auth/services/auth_service.dart';
import '../services/profile_service.dart';

class UploadItemScreen extends StatefulWidget {
  const UploadItemScreen({super.key});

  @override
  State<UploadItemScreen> createState() => _UploadItemScreenState();
}

class _UploadItemScreenState extends State<UploadItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemService = ItemService();
  final _profileService = ProfileService();

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _reporterController = TextEditingController();
  final _contactController = TextEditingController();

  int _categoryId = 1; // Default category
  DateTime _dateFound = DateTime.now();
  String _status = "FOUND"; // Default status
  bool _isLoading = false;
  String? _errorMessage;
  Item? _createdItem;
  String? _currentUsername;

  // Image picking
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _selectedImages;
  final List<Uint8List> _imageBytes = [];

  // Color scheme for dark theme with green accent
  final Color _backgroundColor = Colors.black;
  final Color _cardColor = Colors.grey.shade900;
  final Color _buttonColor = Colors.green;
  final Color _textColor = Colors.white;
  final Color _inputFillColor = Colors.grey.shade800;

  @override
  void initState() {
    super.initState();
    _loadCurrentUsername();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _reporterController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUsername() async {
    try {
      final profile = await _profileService.fetchUserProfile();
      setState(() {
        _currentUsername = profile.username;
        _reporterController.text = profile.username ?? '';
      });
    } catch (e) {
      print('Error loading username: $e');
      setState(() {
        _errorMessage = 'Could not retrieve username';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateFound,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _buttonColor,
              onPrimary: Colors.white,
              surface: _cardColor,
              onSurface: _textColor,
            ),
            dialogBackgroundColor: _cardColor,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateFound) {
      setState(() {
        _dateFound = picked;
      });
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages = images;
          _loadImageBytes();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking images: $e';
      });
    }
  }

  Future<void> _loadImageBytes() async {
    if (_selectedImages == null) return;

    _imageBytes.clear();
    for (var image in _selectedImages!) {
      try {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageBytes.add(bytes);
        });
      } catch (e) {
        print('Error loading image: $e');
      }
    }
  }

  Future<void> _submitItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _createdItem = null;
    });

    try {
      // Format date for backend
      final formattedDate = _dateFound.toIso8601String();

      final newItem = Item(
        itemName: _nameController.text,
        description: _descriptionController.text,
        categoryId: _categoryId,
        locationFound: _locationController.text,
        dateTimeFound: formattedDate,
        reportedBy: _reporterController.text,
        contactInfo: _contactController.text,
        status: _status,
      );

      // Create a list of image names to match the image bytes
      final List<String> imageNames = [];
      for (int i = 0; i < _imageBytes.length; i++) {
        imageNames.add('image_${i + 1}.jpg');
      }

      // Pass the images directly when creating the item
      final createdItem = await _itemService.createItem(
        newItem,
        imageBytes: _imageBytes.isNotEmpty ? _imageBytes : null,
        imageNames: _imageBytes.isNotEmpty ? imageNames : null,
      );

      setState(() {
        _isLoading = false;
        if (createdItem != null) {
          _createdItem = createdItem;
          // Clear form fields but don't reset the form since we won't be showing it
          _selectedImages = null;
          _imageBytes.clear();
          _dateFound = DateTime.now();
          _categoryId = 1;
          _status = "FOUND";
        } else {
          _errorMessage = 'Failed to create item. Please try again.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: $e';
      });
    }
  }

  void _resetForm() {
    setState(() {
      _createdItem = null;
      _formKey.currentState?.reset();
      _nameController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _reporterController.clear();
      _contactController.clear();
      _selectedImages = null;
      _imageBytes.clear();
      _dateFound = DateTime.now();
      _categoryId = 1;
      _status = "FOUND";
    });
  }

  InputDecoration _getInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade400),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey.shade700),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _buttonColor),
      ),
      filled: true,
      fillColor: _inputFillColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _backgroundColor,
        cardColor: _cardColor,
        primaryColor: _buttonColor,
        colorScheme: ColorScheme.dark(
          primary: _buttonColor,
          secondary: _buttonColor,
          surface: _cardColor,
          background: _backgroundColor,
          onBackground: _textColor,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _buttonColor,
            foregroundColor: Colors.white,
            elevation: 3,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _buttonColor,
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(_status == "FOUND" ? 'Report Found Item' : 'Report Lost Item'),
          backgroundColor: _cardColor,
          elevation: 0,
        ),
        body: Container(
          color: _backgroundColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: _createdItem != null
                ? _buildSuccessView()
                : _buildFormView(),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _buttonColor.withOpacity(0.5), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: _buttonColor,
            size: 80,
          ),
          const SizedBox(height: 24),
          Text(
            'Item successfully reported!',
            style: TextStyle(
              color: _textColor,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/view_item',
                    arguments: _createdItem!.itemId,
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _resetForm,
                icon: const Icon(Icons.add),
                label: const Text('Report Another'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _buttonColor,
                  side: BorderSide(color: _buttonColor),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status selector
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: _cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item Status',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: "FOUND",
                        label: Text('Found Item'),
                        icon: Icon(Icons.search),
                      ),
                      ButtonSegment(
                        value: "LOST",
                        label: Text('Lost Item'),
                        icon: Icon(Icons.help_outline),
                      ),
                    ],
                    selected: {_status},
                    onSelectionChanged: (Set<String> selectedStatus) {
                      setState(() {
                        _status = selectedStatus.first;
                      });
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.selected)) {
                            return _buttonColor;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Image picker
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: _cardColor,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item Images',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Select Images'),
                    ),
                  ),
                  if (_imageBytes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imageBytes.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade700),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.memory(
                                _imageBytes[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Item details form
          TextFormField(
            controller: _nameController,
            decoration: _getInputDecoration('Item Name*'),
            style: TextStyle(color: _textColor),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the item name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _descriptionController,
            decoration: _getInputDecoration('Description*'),
            style: TextStyle(color: _textColor),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<int>(
            value: _categoryId,
            decoration: _getInputDecoration('Category'),
            dropdownColor: _cardColor,
            style: TextStyle(color: _textColor),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Electronics')),
              DropdownMenuItem(value: 2, child: Text('Clothing')),
              DropdownMenuItem(value: 3, child: Text('Accessories')),
              DropdownMenuItem(value: 4, child: Text('Documents')),
              DropdownMenuItem(value: 5, child: Text('Other')),
            ],
            onChanged: (value) {
              setState(() {
                _categoryId = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _locationController,
            decoration: _getInputDecoration('Location Found/Lost*'),
            style: TextStyle(color: _textColor),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter where the item was found/lost';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Date Picker
          InkWell(
            onTap: () => _selectDate(context),
            child: InputDecorator(
              decoration: _getInputDecoration('Date Found/Lost'),
              child: Text(
                DateFormat('yyyy-MM-dd').format(_dateFound),
                style: TextStyle(color: _textColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _reporterController,
            decoration: _getInputDecoration('Your User Name*').copyWith(
              suffixIcon: _currentUsername != null
                  ? Icon(Icons.check, color: _buttonColor)
                  : Icon(Icons.error, color: Colors.red),
            ),
            style: TextStyle(color: _textColor),
            readOnly: true, // Make the field read-only
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Username could not be retrieved';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _contactController,
            decoration: _getInputDecoration('Contact Information*').copyWith(
              hintText: 'Email or phone number',
              hintStyle: TextStyle(color: Colors.grey.shade500),
            ),
            style: TextStyle(color: _textColor),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your contact information';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _isLoading ? null : _submitItem,
            child: _isLoading
                ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
              _status == "FOUND" ? 'SUBMIT FOUND ITEM' : 'SUBMIT LOST ITEM',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
