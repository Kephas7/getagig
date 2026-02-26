import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/gig_entity.dart';
import '../view_model/organizer_gigs_provider.dart';

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
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _payRateController;
  late TextEditingController _eventTypeController;
  late TextEditingController _genresController;
  late TextEditingController _instrumentsController;
  
  DateTime? _deadline;
  String _status = 'open';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.gig.title);
    _descriptionController = TextEditingController(text: widget.gig.description);
    _cityController = TextEditingController(text: widget.gig.city);
    _stateController = TextEditingController(text: widget.gig.state);
    _countryController = TextEditingController(text: widget.gig.country);
    _payRateController = TextEditingController(text: widget.gig.payRate.toString());
    _eventTypeController = TextEditingController(text: widget.gig.eventType);
    _genresController = TextEditingController(text: widget.gig.genres.join(', '));
    _instrumentsController = TextEditingController(text: widget.gig.instruments.join(', '));
    _deadline = widget.gig.deadline;
    _status = widget.gig.status;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a deadline')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final updates = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': {
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'country': _countryController.text.trim(),
      },
      'genres': _genresController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'instruments': _instrumentsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'payRate': double.tryParse(_payRateController.text) ?? 0,
      'eventType': _eventTypeController.text.trim(),
      'deadline': _deadline!.toIso8601String(),
      'status': _status,
    };

    try {
      await ref.read(organizerGigsProvider.notifier).updateGig(widget.gig.id, updates);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gig updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Gig', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
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
                  return DropdownMenuItem(value: s, child: Text(s.toUpperCase()));
                }).toList(),
                onChanged: (v) => setState(() => _status = v!),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.info_outline, color: Colors.black45),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
                ),
              ),
              const SizedBox(height: 32),
              
              _buildSectionTitle('Gig Overview'),
              _buildTextField(_titleController, 'Gig Title', Icons.title, validator: (v) => v!.length < 3 ? 'Title too short' : null),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 4, validator: (v) => v!.length < 10 ? 'Description too short' : null),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Location'),
              _buildTextField(_cityController, 'City', Icons.location_city),
              const SizedBox(height: 16),
              _buildTextField(_stateController, 'State', Icons.map),
              const SizedBox(height: 16),
              _buildTextField(_countryController, 'Country', Icons.public),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Requirements & Pay'),
              _buildTextField(_eventTypeController, 'Event Type', Icons.event),
              const SizedBox(height: 16),
              _buildTextField(_payRateController, 'Pay Rate (Rs.)', Icons.payments, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField(_genresController, 'Genres (comma separated)', Icons.music_note),
              const SizedBox(height: 16),
              _buildTextField(_instrumentsController, 'Instruments Required (comma separated)', Icons.piano),
              
              const SizedBox(height: 32),
              _buildSectionTitle('Deadline'),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        _deadline == null ? 'Select Application Deadline' : DateFormat('yyyy-MM-dd').format(_deadline!),
                        style: const TextStyle(color: Colors.black87),
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
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    {int maxLines = 1, TextInputType keyboardType = TextInputType.text, String? Function(String?)? validator}
  ) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator ?? (v) => v!.isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black45),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black87)),
      ),
    );
  }
}

