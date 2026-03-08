import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/musician/presentation/state/musician_state.dart';
import 'package:getagig/features/musician/presentation/view_model/musician_viewmodel.dart';
import '../../domain/entities/musician_entity.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final MusicianEntity musician;

  const EditProfilePage({super.key, required this.musician});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _stageNameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _experienceYearsController;
  late TextEditingController _hourlyRateController;
  late TextEditingController _genresController;
  late TextEditingController _instrumentsController;

  @override
  void initState() {
    super.initState();
    _stageNameController = TextEditingController(
      text: widget.musician.stageName,
    );
    _bioController = TextEditingController(text: widget.musician.bio ?? '');
    _phoneController = TextEditingController(text: widget.musician.phone);

    _locationController = TextEditingController(text: widget.musician.location);

    _experienceYearsController = TextEditingController(
      text: widget.musician.experienceYears.toString(),
    );
    _hourlyRateController = TextEditingController(
      text: widget.musician.hourlyRate?.toString() ?? '',
    );
    _genresController = TextEditingController(
      text: widget.musician.genres.join(', '),
    );
    _instrumentsController = TextEditingController(
      text: widget.musician.instruments.join(', '),
    );
  }

  @override
  void dispose() {
    _stageNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _experienceYearsController.dispose();
    _hourlyRateController.dispose();
    _genresController.dispose();
    _instrumentsController.dispose();
    super.dispose();
  }

  void _updateProfile() {
    if (_formKey.currentState!.validate()) {
      final genres = _splitCommaValues(_genresController.text);
      if (genres.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter at least one genre')),
        );
        return;
      }

      final instruments = _splitCommaValues(_instrumentsController.text);
      if (instruments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter at least one instrument')),
        );
        return;
      }

      ref
          .read(musicianProfileViewModelProvider.notifier)
          .updateProfile(
            stageName: _stageNameController.text.trim(),
            bio: _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
            phone: _phoneController.text.trim(),
            location: _locationController.text.trim(),
            genres: genres,
            instruments: instruments,
            experienceYears: int.parse(_experienceYearsController.text.trim()),
            hourlyRate: _hourlyRateController.text.trim().isEmpty
                ? null
                : double.parse(_hourlyRateController.text.trim()),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(musicianProfileViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isSaving = profileState.status == MusicianProfileStatus.loading;

    ref.listen<MusicianProfileState>(musicianProfileViewModelProvider, (
      previous,
      next,
    ) {
      if (next.status == MusicianProfileStatus.updated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      } else if (next.status == MusicianProfileStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage ?? 'An error occurred')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Musician Profile'),
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
                        Icons.music_note_rounded,
                        color: colorScheme.secondary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Update your profile details to help organizers discover you faster.',
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
                title: 'Identity',
                subtitle: 'How your profile appears publicly.',
                icon: Icons.person_outline_rounded,
                accentColor: colorScheme.secondary,
                children: [
                  TextFormField(
                    controller: _stageNameController,
                    decoration: _fieldDecoration(
                      label: 'Stage Name *',
                      icon: Icons.person,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your stage name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bioController,
                    decoration: _fieldDecoration(
                      label: 'Bio',
                      icon: Icons.description,
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    maxLength: 500,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildSectionCard(
                title: 'Contact',
                subtitle: 'Where organizers can reach and locate you.',
                icon: Icons.contact_phone_outlined,
                accentColor: const Color(0xFF10B981),
                children: [
                  TextFormField(
                    controller: _phoneController,
                    decoration: _fieldDecoration(
                      label: 'Phone *',
                      icon: Icons.phone,
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _locationController,
                    decoration: _fieldDecoration(
                      label: 'Location *',
                      icon: Icons.location_on,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your location';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildSectionCard(
                title: 'Style & Skills',
                subtitle: 'Type your genres and instruments.',
                icon: Icons.piano_rounded,
                accentColor: const Color(0xFFF59E0B),
                children: [
                  TextFormField(
                    controller: _genresController,
                    decoration: _fieldDecoration(
                      label: 'Genres *',
                      icon: Icons.category_outlined,
                      hintText: 'Rock, Pop, Jazz',
                    ),
                    validator: (value) {
                      if (_splitCommaValues(value ?? '').isEmpty) {
                        return 'Please enter at least one genre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _instrumentsController,
                    decoration: _fieldDecoration(
                      label: 'Instruments *',
                      icon: Icons.music_note_outlined,
                      hintText: 'Guitar, Vocals, Piano',
                    ),
                    validator: (value) {
                      if (_splitCommaValues(value ?? '').isEmpty) {
                        return 'Please enter at least one instrument';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildSectionCard(
                title: 'Experience & Rate',
                subtitle: 'Share your experience and expected pay.',
                icon: Icons.analytics_outlined,
                accentColor: const Color(0xFF6366F1),
                children: [
                  TextFormField(
                    controller: _experienceYearsController,
                    decoration: _fieldDecoration(
                      label: 'Years of Experience *',
                      icon: Icons.work,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter years of experience';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _hourlyRateController,
                    decoration: _fieldDecoration(
                      label: 'Hourly Rate (Optional)',
                      icon: Icons.payments_outlined,
                      suffixText: 'NPR',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
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
                label: Text(isSaving ? 'Saving...' : 'Update Profile'),
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
    String? suffixText,
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
      suffixText: suffixText,
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
