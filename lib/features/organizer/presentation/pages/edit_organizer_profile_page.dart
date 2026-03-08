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
  late final TextEditingController _eventTypesController;

  String? _selectedOrgType;

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
    _eventTypesController = TextEditingController(
      text: widget.organizer.eventTypes.join(', '),
    );

    _selectedOrgType = widget.organizer.organizationType;
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
    _eventTypesController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      if (_selectedOrgType == null || _selectedOrgType!.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an organization type')),
        );
        return;
      }

      final eventTypes = _splitCommaValues(_eventTypesController.text);
      if (eventTypes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter at least one event type')),
        );
        return;
      }

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
            eventTypes: eventTypes,
            website: _websiteController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(organizerProfileViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isSaving = profileState.status == OrganizerProfileStatus.loading;

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
      appBar: AppBar(
        title: const Text('Edit Organizer Profile'),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.business_center_rounded,
                        color: colorScheme.secondary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Keep your organization profile complete for better trust and hiring reach.',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildSectionCard(
                title: 'Organization',
                subtitle: 'Core business details visible to musicians.',
                icon: Icons.business_rounded,
                accentColor: colorScheme.secondary,
                children: [
                  TextFormField(
                    controller: _organizationNameController,
                    decoration: _fieldDecoration(
                      label: 'Organization Name *',
                      icon: Icons.apartment_rounded,
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bioController,
                    decoration: _fieldDecoration(
                      label: 'Bio',
                      icon: Icons.description_outlined,
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildSectionCard(
                title: 'Contact',
                subtitle: 'How applicants and musicians can reach you.',
                icon: Icons.contact_mail_outlined,
                accentColor: const Color(0xFF10B981),
                children: [
                  TextFormField(
                    controller: _contactPersonController,
                    decoration: _fieldDecoration(
                      label: 'Contact Person *',
                      icon: Icons.person_outline_rounded,
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: _fieldDecoration(
                      label: 'Phone *',
                      icon: Icons.phone_outlined,
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: _fieldDecoration(
                      label: 'Email *',
                      icon: Icons.alternate_email_rounded,
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationController,
                    decoration: _fieldDecoration(
                      label: 'Location *',
                      icon: Icons.location_on_outlined,
                      hintText: 'Kathmandu, Bagmati, Nepal',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Required'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _websiteController,
                    decoration: _fieldDecoration(
                      label: 'Website',
                      icon: Icons.language_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildSectionCard(
                title: 'Operations',
                subtitle: 'Set your organization and event focus.',
                icon: Icons.event_note_rounded,
                accentColor: const Color(0xFF6366F1),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedOrgType,
                    decoration: _fieldDecoration(
                      label: 'Organization Type *',
                      icon: Icons.category_outlined,
                    ),
                    items: _orgTypes
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedOrgType = v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _eventTypesController,
                    decoration: _fieldDecoration(
                      label: 'Event Types *',
                      icon: Icons.event_available_outlined,
                      hintText: 'Concert, Wedding, Festival',
                    ),
                    validator: (value) {
                      if (_splitCommaValues(value ?? '').isEmpty) {
                        return 'Please enter at least one event type';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: isSaving ? null : _updateProfile,
                icon: isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(isSaving ? 'Saving...' : 'Save Changes'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _splitCommaValues(String rawValue) {
    return rawValue
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    String? hintText,
    bool alignLabelWithHint = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    OutlineInputBorder inputBorder(Color color) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color),
      );
    }

    return InputDecoration(
      labelText: label,
      hintText: hintText,
      alignLabelWithHint: alignLabelWithHint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: colorScheme.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: inputBorder(colorScheme.outlineVariant),
      enabledBorder: inputBorder(
        colorScheme.outlineVariant.withValues(alpha: 0.7),
      ),
      focusedBorder: inputBorder(colorScheme.secondary),
    );
  }
}
