import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/features/musician/presentation/state/musician_state.dart';
import 'package:getagig/features/musician/presentation/view_model/musician_viewmodel.dart';

class CreateProfilePage extends ConsumerStatefulWidget {
  const CreateProfilePage({super.key});

  @override
  ConsumerState<CreateProfilePage> createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends ConsumerState<CreateProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _stageNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _experienceYearsController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  final List<String> _selectedGenres = [];
  final List<String> _selectedInstruments = [];

  final List<String> _availableGenres = [
    'Rock',
    'Jazz',
    'Classical',
    'Pop',
    'Hip Hop',
    'Blues',
    'Country',
    'Electronic',
    'Folk',
    'Metal',
  ];

  final List<String> _availableInstruments = [
    'Guitar',
    'Piano',
    'Drums',
    'Bass',
    'Violin',
    'Saxophone',
    'Trumpet',
    'Flute',
    'Vocals',
    'Keyboard',
  ];

  @override
  void dispose() {
    _stageNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _experienceYearsController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  void _createProfile() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGenres.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one genre')),
        );
        return;
      }

      if (_selectedInstruments.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one instrument'),
          ),
        );
        return;
      }

      ref
          .read(musicianProfileViewModelProvider.notifier)
          .createProfile(
            stageName: _stageNameController.text.trim(),
            bio: _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
            phone: _phoneController.text.trim(),
            city: _cityController.text.trim(),
            stateProvince: _stateController.text.trim(),
            country: _countryController.text.trim(),
            genres: _selectedGenres,
            instruments: _selectedInstruments,
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

    ref.listen<MusicianProfileState>(musicianProfileViewModelProvider, (
      previous,
      next,
    ) {
      if (next.status == MusicianProfileStatus.created) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pop(context, true);
      } else if (next.status == MusicianProfileStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'An error occurred'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile'), elevation: 0),
      body: profileState.status == MusicianProfileStatus.loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Set up your musician profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tell us about yourself and your music',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _stageNameController,
                      decoration: const InputDecoration(
                        labelText: 'Stage Name *',
                        hintText: 'Enter your stage name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your stage name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        hintText: 'Tell us about yourself...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 4,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 16),

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
                          return 'Please enter your phone number';
                        }
                        if (value.length < 10) {
                          return 'Phone number must be at least 10 digits';
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
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'City *',
                        hintText: 'Kathmandu',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _stateController,
                      decoration: const InputDecoration(
                        labelText: 'State/Province *',
                        hintText: 'Bagmati',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.map),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your state/province';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Country *',
                        hintText: 'Nepal',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your country';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Genres *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _availableGenres.map((genre) {
                        final isSelected = _selectedGenres.contains(genre);
                        return FilterChip(
                          label: Text(genre),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedGenres.add(genre);
                              } else {
                                _selectedGenres.remove(genre);
                              }
                            });
                          },
                          selectedColor: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Instruments *',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _availableInstruments.map((instrument) {
                        final isSelected = _selectedInstruments.contains(
                          instrument,
                        );
                        return FilterChip(
                          label: Text(instrument),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedInstruments.add(instrument);
                              } else {
                                _selectedInstruments.remove(instrument);
                              }
                            });
                          },
                          selectedColor: Colors.orange.withOpacity(0.3),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _experienceYearsController,
                      decoration: const InputDecoration(
                        labelText: 'Years of Experience *',
                        hintText: '10',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter years of experience';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (int.parse(value) < 0) {
                          return 'Experience cannot be negative';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _hourlyRateController,
                      decoration: const InputDecoration(
                        labelText: 'Hourly Rate (Optional)',
                        hintText: '5000',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: 'NPR',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          if (double.parse(value) < 0) {
                            return 'Rate cannot be negative';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed:
                          profileState.status == MusicianProfileStatus.loading
                          ? null
                          : _createProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          profileState.status == MusicianProfileStatus.loading
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
                  ],
                ),
              ),
            ),
    );
  }
}
