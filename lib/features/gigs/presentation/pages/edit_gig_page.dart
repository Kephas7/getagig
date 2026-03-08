import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getagig/app/theme/app_shell_styles.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/gig_entity.dart';
import '../view_model/organizer_gigs_viewmodel.dart';

class EditGigPage extends ConsumerStatefulWidget {
  final GigEntity gig;
  const EditGigPage({super.key, required this.gig});

  @override
  ConsumerState<EditGigPage> createState() => _EditGigPageState();
}

class _EditGigPageState extends ConsumerState<EditGigPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _payRateController;
  late TextEditingController _eventTypeController;
  late TextEditingController _genresController;
  late TextEditingController _instrumentsController;

  DateTime? _eventDate;
  DateTime? _deadline;
  String _status = 'open';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.gig.title);
    _descriptionController = TextEditingController(
      text: widget.gig.description,
    );
    _locationController = TextEditingController(text: widget.gig.location);
    _payRateController = TextEditingController(
      text: widget.gig.payRate.toString(),
    );
    _eventTypeController = TextEditingController(text: widget.gig.eventType);
    _genresController = TextEditingController(
      text: widget.gig.genres.join(', '),
    );
    _instrumentsController = TextEditingController(
      text: widget.gig.instruments.join(', '),
    );
    _eventDate = widget.gig.deadline;
    _deadline = widget.gig.deadline;
    _status = widget.gig.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _payRateController.dispose();
    _eventTypeController.dispose();
    _genresController.dispose();
    _instrumentsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _selectEventDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() => _eventDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_eventDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an event date')),
      );
      return;
    }

    if (_deadline == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a deadline')));
      return;
    }

    if (_deadline!.isAfter(_eventDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application deadline must be on or before event date'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final updates = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'genres': _genresController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'instruments': _instrumentsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      'payRate': double.tryParse(_payRateController.text) ?? 0,
      'eventType': _eventTypeController.text.trim(),
      'eventDate': _eventDate!.toIso8601String(),
      'deadline': _deadline!.toIso8601String(),
      'status': _status,
    };

    try {
      await ref
          .read(organizerGigsProvider.notifier)
          .updateGig(widget.gig.id, updates);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gig updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Edit Gig', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Status'),
              DropdownButtonFormField<String>(
                initialValue: _status,
                items: ['open', 'closed', 'filled'].map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s.toUpperCase()),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _status = v!),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.info_outline,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: AppShellStyles.mutedSurface(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppShellStyles.border(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('Gig Overview'),
              _buildTextField(
                _titleController,
                'Gig Title',
                Icons.title,
                validator: (v) => v!.length < 3 ? 'Title too short' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _descriptionController,
                'Description',
                Icons.description,
                maxLines: 4,
                validator: (v) =>
                    v!.length < 10 ? 'Description too short' : null,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Location'),
              _buildTextField(
                _locationController,
                'Location (City, State, Country)',
                Icons.location_on,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Requirements & Pay'),
              _buildTextField(_eventTypeController, 'Event Type', Icons.event),
              const SizedBox(height: 16),
              _buildTextField(
                _payRateController,
                'Pay Rate (Rs.)',
                Icons.payments,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _genresController,
                'Genres (comma separated)',
                Icons.music_note,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _instrumentsController,
                'Instruments Required (comma separated)',
                Icons.piano,
              ),

              const SizedBox(height: 32),
              _buildSectionTitle('Schedule'),
              InkWell(
                onTap: _selectEventDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppShellStyles.mutedSurface(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppShellStyles.border(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.event, color: colorScheme.secondary),
                      const SizedBox(width: 12),
                      Text(
                        _eventDate == null
                            ? 'Select Event Date'
                            : DateFormat('yyyy-MM-dd').format(_eventDate!),
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppShellStyles.mutedSurface(context),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppShellStyles.border(context)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: colorScheme.secondary),
                      const SizedBox(width: 12),
                      Text(
                        _deadline == null
                            ? 'Select Application Deadline'
                            : DateFormat('yyyy-MM-dd').format(_deadline!),
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: colorScheme.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: colorScheme.onSecondary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator:
          validator ?? (v) => v!.isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: AppShellStyles.mutedSurface(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppShellStyles.border(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppShellStyles.border(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
