import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/organizer/presentation/state/organizer_state.dart';
import 'package:getagig/features/organizer/presentation/view_model/organizer_view_model.dart';

class CreateOrganizerProfilePage extends ConsumerStatefulWidget {
  const CreateOrganizerProfilePage({super.key});

  @override
  ConsumerState<CreateOrganizerProfilePage> createState() =>
      _CreateOrganizerProfilePageState();
}

class _CreateOrganizerProfilePageState
    extends ConsumerState<CreateOrganizerProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _organizationNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _websiteController = TextEditingController();

  String? _selectedOrgType;
  final List<String> _selectedEventTypes = [];

  final List<String> _orgTypes = [
    'Club',
    'Restaurant',
    'Festival',
    'Private Party',
    'Corporate',
    'Wedding Venue',
    'Bar',
    'Other',
  ];

  final List<String> _eventTypes = [
    'Concert',
    'Wedding',
    'Corporate Event',
    'Birthday',
    'Festival',
    'Pub Gig',
    'Private Party',
    'Product Launch',
  ];

  @override
  void dispose() {
    _organizationNameController.dispose();
    _bioController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _createProfile() {
    if (_formKey.currentState!.validate()) {
      if (_selectedOrgType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an organization type')),
        );
        return;
      }

      if (_selectedEventTypes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one event type'),
          ),
        );
        return;
      }

      ref
          .read(organizerProfileViewModelProvider.notifier)
          .createProfile(
            organizationName: _organizationNameController.text.trim(),
            bio: _bioController.text.trim(),
            contactPerson: _contactPersonController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            location: _locationController.text.trim(),
            organizationType: _selectedOrgType!,
            eventTypes: _selectedEventTypes,
            website: _websiteController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(organizerProfileViewModelProvider);

    ref.listen<OrganizerProfileState>(organizerProfileViewModelProvider, (
      previous,
      next,
    ) {
      if (next.status == OrganizerProfileStatus.created) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Organizer profile created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context, true);
      } else if (next.status == OrganizerProfileStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Organizer Profile'),
        elevation: 0,
      ),
      body: profileState.status == OrganizerProfileStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Setup your organizer profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tell us about your organization and events',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    // Organization Name
                    TextFormField(
                      controller: _organizationNameController,
                      decoration: const InputDecoration(
                        labelText: 'Organization Name *',
                        hintText: 'Enter your organization name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter organization name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Bio
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        hintText: 'Tell us about your organization...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 4,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 16),

                    // Contact Person
                    TextFormField(
                      controller: _contactPersonController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Person *',
                        hintText: 'Enter contact person name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter contact person name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone *',
                        hintText: '9841234567',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        hintText: 'info@org.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location *',
                        hintText: 'Kathmandu, Bagmati, Nepal',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Organization Type
                    const Text(
                      'Organization Type *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedOrgType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      hint: const Text('Select organization type'),
                      items: _orgTypes.map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedOrgType = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a type' : null,
                    ),
                    const SizedBox(height: 24),

                    // Event Types
                    const Text(
                      'Event Types *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _eventTypes.map((type) {
                        final isSelected = _selectedEventTypes.contains(type);
                        return FilterChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedEventTypes.add(type);
                              } else {
                                _selectedEventTypes.remove(type);
                              }
                            });
                          },
                          selectedColor: Colors.blue.withOpacity(0.3),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Website
                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Website (Optional)',
                        hintText: 'https://example.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.language),
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed:
                          profileState.status == OrganizerProfileStatus.loading
                          ? null
                          : _createProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          profileState.status == OrganizerProfileStatus.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Create Profile',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }
}
