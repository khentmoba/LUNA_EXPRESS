import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/errand_provider.dart';
import '../widgets/map_pin_picker.dart';
import '../services/pasugo_constants.dart';

/// Screen for creating a new errand post.
class CreateErrandScreen extends StatefulWidget {
  const CreateErrandScreen({super.key});

  @override
  State<CreateErrandScreen> createState() => _CreateErrandScreenState();
}

class _CreateErrandScreenState extends State<CreateErrandScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _messageController = TextEditingController();

  GeoPoint? _selectedLocation;
  bool _showMapPicker = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return PasugoErrorMessages.nameRequired;
    }
    if (value.trim().length < ErrandConstraints.nameMinLength) {
      return PasugoErrorMessages.nameTooShort;
    }
    if (value.trim().length > ErrandConstraints.nameMaxLength) {
      return PasugoErrorMessages.nameTooLong;
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return PasugoErrorMessages.phoneRequired;
    }
    final cleaned = value.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!RegExp(r'^(09\d{9}|\+63\d{10}|639\d{9})$').hasMatch(cleaned)) {
      return PasugoErrorMessages.phoneInvalid;
    }
    return null;
  }

  String? _validatePin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return PasugoErrorMessages.pinRequired;
    }
    if (value.trim().length != ErrandConstraints.pinLength) {
      return PasugoErrorMessages.pinInvalid;
    }
    if (int.tryParse(value.trim()) == null) {
      return PasugoErrorMessages.pinInvalid;
    }
    return null;
  }

  String? _validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return PasugoErrorMessages.messageRequired;
    }
    if (value.trim().length < ErrandConstraints.messageMinLength) {
      return PasugoErrorMessages.messageTooShort;
    }
    if (value.trim().length > ErrandConstraints.messageMaxLength) {
      return PasugoErrorMessages.messageTooLong;
    }
    return null;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ErrandProvider>();
    final success = await provider.createErrand(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      pin: _pinController.text.trim(),
      message: _messageController.text.trim(),
      locationPin: _selectedLocation,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Errand posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      provider.resetCreationState();
      // Navigate to bulletin board
      Navigator.pushReplacementNamed(context, '/pasugo/bulletin');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.creationError ?? 'Failed to post errand'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post an Errand'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Your Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: _validateName,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: '0917xxxxxxx',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                validator: _validatePhone,
              ),
              const SizedBox(height: 16),

              // PIN
              TextFormField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: '4-digit PIN',
                  hintText: 'Used to access your errand later',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                validator: _validatePin,
              ),
              const SizedBox(height: 16),

              // Message
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                maxLength: ErrandConstraints.messageMaxLength,
                decoration: const InputDecoration(
                  labelText: 'What do you need?',
                  hintText:
                      'Describe what you need done (e.g., "Buy 2 burgers from McDo and deliver to 123 Street")',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: _validateMessage,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Optional Map Pin
              InkWell(
                onTap: () => setState(() => _showMapPicker = !_showMapPicker),
                child: Row(
                  children: [
                    Icon(
                      _selectedLocation != null
                          ? Icons.location_on
                          : Icons.location_on_outlined,
                      color: _selectedLocation != null
                          ? theme.colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedLocation != null
                          ? 'Location pin set'
                          : 'Add a location pin (optional)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _selectedLocation != null
                            ? theme.colorScheme.primary
                            : null,
                      ),
                    ),
                    if (_selectedLocation != null) ...[
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () =>
                            setState(() => _selectedLocation = null),
                      ),
                    ],
                  ],
                ),
              ),
              if (_showMapPicker) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: 250,
                  child: MapPinPicker(
                    onPinSelected: (geoPoint) {
                      setState(() => _selectedLocation = geoPoint);
                    },
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Submit button
              Consumer<ErrandProvider>(
                builder: (context, provider, _) {
                  return FilledButton.icon(
                    onPressed: provider.isCreating ? null : _handleSubmit,
                    icon: provider.isCreating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label:
                        Text(provider.isCreating ? 'Posting...' : 'Post Errand'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
