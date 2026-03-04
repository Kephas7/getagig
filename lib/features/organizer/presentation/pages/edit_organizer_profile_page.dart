import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/organizer/domain/entities/organizer_entity.dart';
import 'package:getagig/features/organizer/presentation/state/organizer_state.dart';
import 'package:getagig/features/organizer/presentation/view_model/organizer_view_model.dart';

class EditOrganizerProfilePage extends ConsumerStatefulWidget {
  final OrganizerEntity organizer;
  const EditOrganizerProfilePage({super.key, required this.organizer});

  @override
  ConsumerState<EditOrganizerProfilePage> createState() =>
      _EditOrganizerProfilePageState();
}

class _EditOrganizerProfilePageState
    extends ConsumerState<EditOrganizerProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _organizationNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _contactPersonController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _locationController;
  late final TextEditingController _websiteController;

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
  void initState() {
    super.initState();
    _organizationNameController = TextEditingController(
      text: widget.organizer.organizationName,
    );
    _bioController = TextEditingController(text: widget.organizer.bio);
    _contactPersonController = TextEditingController(
      text: widget.organizer.contactPerson,
    );
    _phoneController = TextEditingController(text: widget.organizer.phone);
    _emailController = TextEditingController(text: widget.organizer.email);
    _locationController = TextEditingController(
      text: widget.organizer.location,
    );
    _websiteController = TextEditingController(text: widget.organizer.website);

    _selectedOrgType = widget.organizer.organizationType;
    _selectedEventTypes.addAll(widget.organizer.eventTypes);
  }

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

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      ref
          .read(organizerProfileViewModelProvider.notifier)
          .updateProfile(
            organizationName: _organizationNameController.text.trim(),
            bio: _bioController.text.trim(),
            contactPerson: _contactPersonController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            location: _locationController.text.trim(),
            organizationType: _selectedOrgType,
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
      if (next.status == OrganizerProfileStatus.updated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Edit Profile'), elevation: 0),
      body: profileState.status == OrganizerProfileStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _organizationNameController,
                      decoration: const InputDecoration(
                        labelText: 'Organization Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _contactPersonController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Person',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'Kathmandu, Bagmati, Nepal',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Required'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Organization Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedOrgType,
                      items: _orgTypes
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedOrgType = v),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Event Types',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: _eventTypes.map((t) {
                        return FilterChip(
                          label: Text(t),
                          selected: _selectedEventTypes.contains(t),
                          onSelected: (s) {
                            setState(() {
                              if (s) {
                                _selectedEventTypes.add(t);
                              } else {
                                _selectedEventTypes.remove(t);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _websiteController,
                      decoration: const InputDecoration(
                        labelText: 'Website',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
