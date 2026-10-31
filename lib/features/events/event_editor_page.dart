import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/custom_form_field.dart';
import '../../models/event.dart';
import '../../repositories/event_repository.dart';

class EventEditorPage extends StatefulWidget {
  final EventRepository repo;
  final RobocekEvent? event; // null = create, non-null = edit

  const EventEditorPage({super.key, required this.repo, this.event});

  @override
  State<EventEditorPage> createState() => _EventEditorPageState();
}

class _EventEditorPageState extends State<EventEditorPage> {
  final _formKey = GlobalKey<FormState>();

  // Core fields
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _date;
  late final TextEditingController _time;
  late final TextEditingController _venue;
  late final TextEditingController _imageUrl;
  late final TextEditingController _registrationUrl;
  late final TextEditingController _whatsappLink;
  late final TextEditingController _confirmationMsg;
  late final TextEditingController _paymentQr;
  late final TextEditingController _memberFee;
  late final TextEditingController _nonMemberFee;
  late final TextEditingController _openAt;
  late final TextEditingController _closeAt;
  late final TextEditingController _maxResponses;

  String _category = 'Workshop';
  String _status = 'Upcoming';
  bool _hasForm = false;
  bool _isPaid = false;
  bool _isFreeForMembers = false;
  List<CustomFormField> _customFields = [];
  bool _loading = false;

  // New field form
  final _newFieldLabel = TextEditingController();
  final _newFieldPlaceholder = TextEditingController();
  final _newFieldOptions = TextEditingController();
  String _newFieldType = 'text';
  bool _newFieldRequired = true;

  final _categories = ['Workshop', 'Competition', 'Seminar', 'Hackathon', 'Meetup', 'Other'];
  final _statuses = ['Upcoming', 'Ongoing', 'Completed', 'Cancelled'];
  final _fieldTypes = ['text', 'email', 'tel', 'number', 'select', 'textarea'];

  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final ev = widget.event;
    _title = TextEditingController(text: ev?.title ?? '');
    _description = TextEditingController(text: ev?.description ?? '');
    _date = TextEditingController(text: ev?.date ?? '');
    _time = TextEditingController(text: ev?.time ?? '');
    _venue = TextEditingController(text: ev?.venue ?? ev?.location ?? '');
    _imageUrl = TextEditingController(text: ev?.imageUrl ?? '');
    _registrationUrl = TextEditingController(text: ev?.registrationUrl ?? '');
    _whatsappLink = TextEditingController(text: ev?.whatsappGroupLink ?? '');
    _confirmationMsg = TextEditingController(
        text: ev?.confirmationMessage ?? 'Registration confirmed. Details and updates will be shared via official channels.');
    _paymentQr = TextEditingController(text: ev?.paymentQr ?? '/qr.jpg');
    _memberFee = TextEditingController(text: ev?.memberFee ?? 'Free');
    _nonMemberFee = TextEditingController(text: ev?.nonMemberFee ?? '₹50');
    _openAt = TextEditingController(text: ev?.openAt ?? '');
    _closeAt = TextEditingController(text: ev?.closeAt ?? '');
    _maxResponses = TextEditingController(text: ev?.maxResponses?.toString() ?? '');

    _category = ev?.category ?? 'Workshop';
    _status = ev?.status ?? 'Upcoming';
    _hasForm = ev?.hasRegistrationForm ?? false;
    _isPaid = ev?.isPaid ?? false;
    _isFreeForMembers = ev?.isFreeForMembers ?? false;
    _customFields = List.from(ev?.customFields ?? []);
  }

  @override
  void dispose() {
    _title.dispose(); _description.dispose(); _date.dispose(); _time.dispose();
    _venue.dispose(); _imageUrl.dispose(); _registrationUrl.dispose();
    _whatsappLink.dispose(); _confirmationMsg.dispose(); _paymentQr.dispose();
    _memberFee.dispose(); _nonMemberFee.dispose(); _openAt.dispose();
    _closeAt.dispose(); _maxResponses.dispose();
    _newFieldLabel.dispose(); _newFieldPlaceholder.dispose(); _newFieldOptions.dispose();
    super.dispose();
  }

  void _addField() {
    if (_newFieldLabel.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a field label'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() {
      _customFields.add(CustomFormField(
        id: 'field_${DateTime.now().millisecondsSinceEpoch}',
        label: _newFieldLabel.text.trim(),
        type: _newFieldType,
        placeholder: _newFieldPlaceholder.text.trim().isEmpty ? null : _newFieldPlaceholder.text.trim(),
        required: _newFieldRequired,
        options: _newFieldType == 'select'
            ? _newFieldOptions.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
            : null,
      ));
      _newFieldLabel.clear();
      _newFieldPlaceholder.clear();
      _newFieldOptions.clear();
      _newFieldType = 'text';
      _newFieldRequired = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final event = RobocekEvent(
        id: widget.event?.id ?? '',
        title: _title.text.trim(),
        category: _category,
        date: _date.text.trim(),
        time: _time.text.trim().isEmpty ? null : _time.text.trim(),
        venue: _venue.text.trim().isEmpty ? 'GCE Kannur Campus' : _venue.text.trim(),
        description: _description.text.trim(),
        registrationUrl: _registrationUrl.text.trim().isEmpty ? null : _registrationUrl.text.trim(),
        imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
        status: _status,
        hasRegistrationForm: _hasForm,
        isPaid: _hasForm && _isPaid,
        isFreeForMembers: _isFreeForMembers,
        memberFee: _isFreeForMembers ? 'Free' : _memberFee.text.trim(),
        nonMemberFee: _isPaid ? _nonMemberFee.text.trim() : 'Free',
        registrationFee: _isPaid ? _nonMemberFee.text.trim() : 'Free',
        whatsappGroupLink: _whatsappLink.text.trim().isEmpty ? null : _whatsappLink.text.trim(),
        confirmationMessage: _confirmationMsg.text.trim(),
        customFields: _customFields,
        paymentQr: _paymentQr.text.trim().isEmpty ? '/qr.jpg' : _paymentQr.text.trim(),
        openAt: _openAt.text.trim().isEmpty ? null : _openAt.text.trim(),
        closeAt: _closeAt.text.trim().isEmpty ? null : _closeAt.text.trim(),
        maxResponses: _maxResponses.text.trim().isEmpty ? null : int.tryParse(_maxResponses.text.trim()),
      );

      if (_isEditing) {
        await widget.repo.updateEvent(event);
      } else {
        await widget.repo.createEvent(event);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Event updated!' : 'Event published!'),
            backgroundColor: RobocekColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Event' : 'New Event'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isEditing ? 'Update' : 'Publish'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            _SectionHeader('Basic Information'),
            // Title
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Event Title *', prefixIcon: Icon(Icons.title_rounded)),
              validator: (v) => v?.trim().isEmpty == true ? 'Title is required' : null,
            ),
            const SizedBox(height: 14),
            // Category & Status
            Row(
              children: [
                Expanded(child: _Dropdown(label: 'Category', value: _category, items: _categories, onChanged: (v) => setState(() => _category = v!))),
                const SizedBox(width: 12),
                Expanded(child: _Dropdown(label: 'Status', value: _status, items: _statuses, onChanged: (v) => setState(() => _status = v!))),
              ],
            ),
            const SizedBox(height: 14),
            // Date & Time
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _date,
                    decoration: const InputDecoration(labelText: 'Date *', prefixIcon: Icon(Icons.calendar_today_outlined), hintText: 'YYYY-MM-DD'),
                    validator: (v) => v?.trim().isEmpty == true ? 'Date is required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _time,
                    decoration: const InputDecoration(labelText: 'Time', prefixIcon: Icon(Icons.access_time_outlined), hintText: 'e.g. 10:00 AM'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Venue
            TextFormField(
              controller: _venue,
              decoration: const InputDecoration(labelText: 'Venue', prefixIcon: Icon(Icons.location_on_outlined), hintText: 'GCE Kannur Campus'),
            ),
            const SizedBox(height: 14),
            // Description
            TextFormField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined), alignLabelWithHint: true),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _imageUrl,
              decoration: const InputDecoration(labelText: 'Image URL', prefixIcon: Icon(Icons.image_outlined)),
            ),

            const SizedBox(height: 24),
            _SectionHeader('Registration'),

            // Has Registration Form
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Registration Form', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Let attendees register via ROBOCEK portal', style: TextStyle(color: RobocekColors.muted, fontSize: 12)),
              value: _hasForm,
              onChanged: (v) => setState(() => _hasForm = v),
              activeColor: RobocekColors.cyan,
            ),

            if (_hasForm) ...[
              const SizedBox(height: 4),
              TextFormField(
                controller: _registrationUrl,
                decoration: const InputDecoration(labelText: 'External Registration URL (optional)', prefixIcon: Icon(Icons.link_rounded)),
              ),
              const SizedBox(height: 14),

              // Paid event
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Paid Event', style: TextStyle(fontWeight: FontWeight.w600)),
                value: _isPaid,
                onChanged: (v) => setState(() => _isPaid = v),
                activeColor: RobocekColors.amber,
              ),

              if (_isPaid) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nonMemberFee,
                        decoration: const InputDecoration(labelText: 'Non-Member Fee', prefixIcon: Icon(Icons.currency_rupee_rounded)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _memberFee,
                        decoration: const InputDecoration(labelText: 'Member Fee', prefixIcon: Icon(Icons.currency_rupee_rounded)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Free for ROBOCEK Members', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  value: _isFreeForMembers,
                  onChanged: (v) => setState(() => _isFreeForMembers = v),
                  activeColor: RobocekColors.green,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _paymentQr,
                  decoration: const InputDecoration(labelText: 'Payment QR Code URL', prefixIcon: Icon(Icons.qr_code_rounded)),
                ),
              ],

              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _openAt,
                      decoration: const InputDecoration(labelText: 'Opens At', hintText: 'YYYY-MM-DDTHH:mm', prefixIcon: Icon(Icons.play_circle_outline)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _closeAt,
                      decoration: const InputDecoration(labelText: 'Closes At', hintText: 'YYYY-MM-DDTHH:mm', prefixIcon: Icon(Icons.stop_circle_outlined)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _maxResponses,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Max Responses (optional)', prefixIcon: Icon(Icons.people_outline_rounded)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _whatsappLink,
                decoration: const InputDecoration(labelText: 'WhatsApp Group Link (optional)', prefixIcon: Icon(Icons.chat_bubble_outline_rounded)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _confirmationMsg,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Confirmation Message', alignLabelWithHint: true),
              ),

              const SizedBox(height: 24),
              _SectionHeader('Custom Form Fields'),

              // Existing fields
              if (_customFields.isNotEmpty) ...[
                ..._customFields.asMap().entries.map((entry) {
                  final i = entry.key;
                  final field = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(field.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text('${field.type}${field.required ? ' · required' : ''}${field.options != null ? ' · options: ${field.options!.join(', ')}' : ''}', style: const TextStyle(fontSize: 12, color: RobocekColors.muted)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                        onPressed: () => setState(() => _customFields.removeAt(i)),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
              ],

              // Add new field
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Add Field', style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _newFieldLabel,
                        decoration: const InputDecoration(labelText: 'Field Label', isDense: true),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _newFieldType,
                              decoration: const InputDecoration(labelText: 'Type', isDense: true),
                              isExpanded: true,
                              items: _fieldTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (v) => setState(() => _newFieldType = v!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              Checkbox(
                                value: _newFieldRequired,
                                onChanged: (v) => setState(() => _newFieldRequired = v!),
                                activeColor: RobocekColors.cyan,
                              ),
                              const Text('Required', style: TextStyle(fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _newFieldPlaceholder,
                        decoration: const InputDecoration(labelText: 'Placeholder (optional)', isDense: true),
                      ),
                      if (_newFieldType == 'select') ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _newFieldOptions,
                          decoration: const InputDecoration(labelText: 'Options (comma separated)', isDense: true),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _addField,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Field'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(color: RobocekColors.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
      );
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _Dropdown({required this.label, required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
      onChanged: onChanged,
    );
  }
}
