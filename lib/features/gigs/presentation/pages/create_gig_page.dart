import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../view_model/organizer_gigs_viewmodel.dart';

class CreateGigPage extends ConsumerStatefulWidget {
  const CreateGigPage({super.key});

  @override
  ConsumerState<CreateGigPage> createState() => _CreateGigPageState();
}

class _CreateGigPageState extends ConsumerState<CreateGigPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _payRateController = TextEditingController();
  final _eventTypeController = TextEditingController();
  final _genresController = TextEditingController();
  final _instrumentsController = TextEditingController();

  DateTime? _eventDate;
  DateTime? _deadline;
  bool _isLoading = false;

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
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _selectEventDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
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

    final data = {
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
    };

    try {
      await ref.read(organizerGigsProvider.notifier).createGig(data);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gig posted successfully!')),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Post a New Gig',
          style: TextStyle(
            color: Color(0xFF1A1B61),
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('GIG OVERVIEW'),
              _buildCardWrapper([
                _buildTextField(
                  _titleController,
                  'Gig Title',
                  Icons.title_rounded,
                  validator: (v) => v!.length < 3 ? 'Title too short' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  _descriptionController,
                  'Description',
                  Icons.description_rounded,
                  maxLines: 4,
                  validator: (v) =>
                      v!.length < 10 ? 'Description too short' : null,
                ),
              ]),
              const SizedBox(height: 32),
              _buildSectionTitle('LOCATION'),
              _buildCardWrapper([
                _buildTextField(
                  _locationController,
                  'Location (City, State, Country)',
                  Icons.location_on_rounded,
                ),
              ]),
              const SizedBox(height: 32),
              _buildSectionTitle('REQUIREMENTS & PAY'),
              _buildCardWrapper([
                _buildTextField(
                  _eventTypeController,
                  'Event Type (e.g. Concert, Wedding)',
                  Icons.event_rounded,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  _payRateController,
                  'Pay Rate (Rs.)',
                  Icons.payments_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  _genresController,
                  'Genres (comma separated)',
                  Icons.music_note_rounded,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  _instrumentsController,
                  'Instruments Required (comma separated)',
                  Icons.piano_rounded,
                ),
              ]),
              const SizedBox(height: 32),
              _buildSectionTitle('SCHEDULE'),
              InkWell(
                onTap: _selectEventDate,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey[100]!, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.event_rounded,
                          color: Color(0xFF6366F1),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _eventDate == null
                            ? 'Select Event Date'
                            : DateFormat('MMMM d, yyyy').format(_eventDate!),
                        style: TextStyle(
                          color: _eventDate == null
                              ? Colors.black26
                              : const Color(0xFF1A1B61),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey[100]!, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          color: Color(0xFF6366F1),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        _deadline == null
                            ? 'Select Application Deadline'
                            : DateFormat('MMMM d, yyyy').format(_deadline!),
                        style: TextStyle(
                          color: _deadline == null
                              ? Colors.black26
                              : const Color(0xFF1A1B61),
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_drop_down_rounded,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Publish Gig',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.black26,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCardWrapper(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey[100]!, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15),
        ],
      ),
      child: Column(children: children),
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
      style: const TextStyle(
        color: Color(0xFF1A1B61),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.black26,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: Colors.indigo[200], size: 22),
        filled: true,
        fillColor: const Color(0xFFFBFBFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[100]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
