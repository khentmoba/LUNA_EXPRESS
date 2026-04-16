import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../services/storage_service.dart';

class CreatePropertyScreen extends StatefulWidget {
  const CreatePropertyScreen({super.key});

  @override
  State<CreatePropertyScreen> createState() => _CreatePropertyScreenState();
}

class _CreatePropertyScreenState extends State<CreatePropertyScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  final GenderOrientation _genderOrientation = GenderOrientation.mixed;
  final List<String> _selectedAmenities = [];
  final List<XFile> _selectedImages = [];
  bool _isUploadingImages = false;

  final List<String> _availableAmenities = [
    'WiFi',
    'Air Conditioning',
    'Laundry',
    'Kitchen',
    'Parking',
    'Security',
    'Study Area',
    'Gym',
    'Pool',
    'Pet Friendly',
  ];

  final Map<String, String?> _errors = {};
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _validateAndSubmit() {
    setState(() {
      _errors['name'] = _nameController.text.isEmpty ? 'Property name is required' : null;
      _errors['address'] = _addressController.text.isEmpty ? 'Address is required' : null;
      _errors['minPrice'] = _minPriceController.text.isEmpty ? 'Required' : null;
      _errors['maxPrice'] = _maxPriceController.text.isEmpty ? 'Required' : null;
    });

    if (_errors.values.every((e) => e == null)) {
      _createProperty();
    }
  }

  Future<void> _createProperty() async {
    final authProvider = context.read<AuthProvider>();
    final propertyProvider = context.read<PropertyProvider>();
    final storageService = StorageService();

    final minPrice = int.tryParse(_minPriceController.text) ?? 0;
    final maxPrice = int.tryParse(_maxPriceController.text) ?? 0;

    setState(() => _isUploadingImages = true);

    try {
      // Create property first to get the property ID
      final property = await propertyProvider.createPropertyWithId(
        ownerId: authProvider.user!.uid,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        location: const GeoPoint(0, 0),
        genderOrientation: _genderOrientation,
        amenities: _selectedAmenities,
        priceRange: PriceRange(min: minPrice, max: maxPrice),
        description: _descriptionController.text.trim(),
      );

      // Upload images if any
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        final files = _selectedImages.map((xfile) => File(xfile.path)).toList();
        imageUrls = await storageService.uploadPropertyImages(
          propertyId: property.propertyId,
          files: files,
        );

        // Update property with image URLs
        await propertyProvider.updateProperty(
          property.copyWith(
            coverImageUrl: imageUrls.first,
            // Store additional images in a separate field if needed
          ),
        );
      }

      if (mounted) {
        setState(() => _isUploadingImages = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isUploadingImages = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = context.watch<PropertyProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Property'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D1B16),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Add New Boarding House',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1B16),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in the details to create a new listing',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              if (propertyProvider.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          propertyProvider.errorMessage!,
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: propertyProvider.clearError,
                      ),
                    ],
                  ),
                ),

              // Image Upload Section
              _buildSectionTitle('Property Images'),
              const SizedBox(height: 12),
              _buildImageUploadArea(),
              const SizedBox(height: 24),

              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),

              _buildLabel('Boarding House Name *'),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(
                  hintText: 'e.g., Sunshine Boarding House',
                  error: _errors['name'],
                ),
              ),
              if (_errors['name'] != null)
                _buildErrorText(_errors['name']!),
              const SizedBox(height: 16),

              _buildLabel('Location *'),
              TextFormField(
                controller: _addressController,
                decoration: _buildInputDecoration(
                  hintText: 'e.g., Quezon City, Metro Manila',
                  error: _errors['address'],
                ),
              ),
              if (_errors['address'] != null)
                _buildErrorText(_errors['address']!),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Monthly Price (₱) *'),
                        TextFormField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration(
                            hintText: '5000',
                            error: _errors['minPrice'],
                          ),
                        ),
                        if (_errors['minPrice'] != null)
                          _buildErrorText(_errors['minPrice']!),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Total Rooms *'),
                        TextFormField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration(
                            hintText: '10',
                            error: _errors['maxPrice'],
                          ),
                        ),
                        if (_errors['maxPrice'] != null)
                          _buildErrorText(_errors['maxPrice']!),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildLabel('Description *'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: _buildInputDecoration(
                  hintText: 'Describe your boarding house, its features, and what makes it special...',
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Amenities'),
              const SizedBox(height: 8),
              Text(
                'Quick add common amenities:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              _buildAmenitiesSection(),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: propertyProvider.isLoading || _isUploadingImages ? null : _validateAndSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5287B2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: propertyProvider.isLoading || _isUploadingImages
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Create Listing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadArea() {
    if (_selectedImages.isEmpty) {
      // Empty state - large upload area
      return InkWell(
        onTap: _pickImage,
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[300]!,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                'Click to upload or drag and drop',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PNG, JPG, or JPEG (Max 5MB each)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show grid when images are selected
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _selectedImages.length + 1,
      itemBuilder: (context, index) {
        if (index == _selectedImages.length) {
          // Add button
          return InkWell(
            onTap: _pickImage,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey[600]),
                  const SizedBox(height: 4),
                  Text(
                    'Add Photo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Image thumbnail
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_selectedImages[index].path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
            if (index == 0)
              Positioned(
                bottom: 4,
                left: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5287B2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Cover',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableAmenities.map((amenity) {
            final isSelected = _selectedAmenities.contains(amenity);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedAmenities.remove(amenity);
                  } else {
                    _selectedAmenities.add(amenity);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF5287B2) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF5287B2) : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  amenity,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF5287B2),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Custom amenity input
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Add custom amenity...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF5287B2), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5287B2),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1D1B16),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1D1B16),
        ),
      ),
    );
  }

  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 12)),
    );
  }

  InputDecoration _buildInputDecoration({required String hintText, String? error}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF999999)),
      filled: true,
      fillColor: error != null ? Colors.red[50] : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: error != null ? Colors.red : const Color(0xFFE0E0E0), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: error != null ? Colors.red : const Color(0xFFE0E0E0), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF5287B2), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
