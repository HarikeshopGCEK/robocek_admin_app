import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/custom_form.dart';
import '../../models/custom_form_field.dart';
import '../../repositories/form_repository.dart';

class FormEditorPage extends StatefulWidget {
  final FormRepository repo;
  final CustomForm? form; // null = create

  const FormEditorPage({super.key, required this.repo, this.form});

  @override
  State<FormEditorPage> createState() => _FormEditorPageState();
}

class _FormEditorPageState extends State<FormEditorPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _slug;
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _whatsappLink;
  late final TextEditingController _confirmationMsg;
  late final TextEditingController _paymentQr;
  late final TextEditingController _memberFee;
  late final TextEditingController _nonMemberFee;
  late final TextEditingController _openAt;
  late final TextEditingController _closeAt;
  late final TextEditingController _maxResponses;

  String _status = 'Active';
  bool _isPaid = false;
  bool _isFreeForMembers = false;
  List<CustomFormField> _fields = [];
  bool _loading = false;

  // New field
  final _newFieldLabel = TextEditingController();
  final _newFieldPlaceholder = TextEditingController();
  final _newFieldOptions = TextEditingController();
  String _newFieldType = 'text';
  bool _newFieldRequired = true;

  final _fieldTypes = ['text', 'email', 'tel', 'number', 'select', 'textarea'];

  bool get _isEditing => widget.form != null;

  @override
  void initState() {
    super.initState();
    final f = widget.form;
    _slug = TextEditingController(text: f?.id ?? '');
    _title = TextEditingController(text: f?.title ?? '');
    _description = TextEditingController(text: f?.description ?? '');
    _whatsappLink = TextEditingController(text: f?.whatsappGroupLink ?? '');
    _confirmationMsg = TextEditingController(
        text: f?.confirmationMessage ?? 'Registration confirmed. Details and updates will be shared via official channels.');
    _paymentQr = TextEditingController(text: f?.paymentQr ?? '/qr.jpg');
    _memberFee = TextEditingController(text: f?.memberFee ?? 'Free');
    _nonMemberFee = TextEditingController(text: f?.nonMemberFee ?? '₹50');
    _openAt = TextEditingController(text: f?.openAt ?? '');
    _closeAt = TextEditingController(text: f?.closeAt ?? '');
    _maxResponses = TextEditingController(text: f?.maxResponses?.toString() ?? '');
    _status = f?.status ?? 'Active';
    _isPaid = f?.isPaid ?? false;
    _isFreeForMembers = f?.isFreeForMembers ?? false;
    _fields = List.from(f?.fields ?? []);
  }

  @override
  void dispose() {
    _slug.dispose(); _title.dispose(); _description.dispose();
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
      _fields.add(CustomFormField(
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

    // Build slug from title if empty
    final rawSlug = _slug.text.trim().isEmpty
        ? _title.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-').replaceAll(RegExp(r'^-+|-+$'), '')
        : _slug.text.trim();

    try {
      final form = CustomForm(
        id: _isEditing ? widget.form!.id : rawSlug,
        title: _title.text.trim(),
        description: _description.text.trim(),
        status: _status,
        isPaid: _isPaid,
        registrationFee: _isPaid ? _nonMemberFee.text.trim() : 'Free',
        isFreeForMembers: _isFreeForMembers,
        memberFee: _isFreeForMembers ? 'Free' : _memberFee.text.trim(),
        nonMemberFee: _isPaid ? _nonMemberFee.text.trim() : 'Free',
        whatsappGroupLink: _whatsappLink.text.trim().isEmpty ? null : _whatsappLink.text.trim(),
        confirmationMessage: _confirmationMsg.text.trim(),
        fields: _fields,
        paymentQr: _paymentQr.text.trim().isEmpty ? '/qr.jpg' : _paymentQr.text.trim(),
        openAt: _openAt.text.trim().isEmpty ? null : _openAt.text.trim(),
        closeAt: _closeAt.text.trim().isEmpty ? null : _closeAt.text.trim(),
        maxResponses: _maxResponses.text.trim().isEmpty ? null : int.tryParse(_maxResponses.text.trim()),
      );

      await widget.repo.saveForm(form);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Form updated!' : 'Form created! URL: /forms/${form.id}'),
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
        title: Text(_isEditing ? 'Edit Form' : 'New Form'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_isEditing ? 'Update' : 'Create'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          children: [
            _SectionHeader('Form Details'),
            if (!_isEditing) ...[
              TextFormField(
                controller: _slug,
                decoration: const InputDecoration(
                  labelText: 'Form Slug (URL)',
                  prefixIcon: Icon(Icons.link_rounded),
                  hintText: 'e.g. workshop-2026 → /forms/workshop-2026',
                ),
              ),
              const SizedBox(height: 14),
            ],
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Form Title *', prefixIcon: Icon(Icons.title_rounded)),
              validator: (v) => v?.trim().isEmpty == true ? 'Title is required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true, prefixIcon: Icon(Icons.description_outlined)),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: ['Active', 'Closed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => _status = v!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            _SectionHeader('Payment Settings'),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Paid Registration', style: TextStyle(fontWeight: FontWeight.w600)),
              value: _isPaid,
              onChanged: (v) => setState(() => _isPaid = v),
              activeColor: RobocekColors.amber,
            ),

            if (_isPaid) ...[
              const SizedBox(height: 8),
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
                decoration: const InputDecoration(labelText: 'Payment QR URL', prefixIcon: Icon(Icons.qr_code_rounded)),
              ),
            ],

            const SizedBox(height: 24),
            _SectionHeader('Advanced Settings'),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _openAt,
                    decoration: const InputDecoration(labelText: 'Opens At', hintText: 'YYYY-MM-DDTHH:mm'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _closeAt,
                    decoration: const InputDecoration(labelText: 'Closes At', hintText: 'YYYY-MM-DDTHH:mm'),
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
            _SectionHeader('Form Fields'),

            // Existing fields
            if (_fields.isNotEmpty) ...[
              ..._fields.asMap().entries.map((entry) {
                final i = entry.key;
                final field = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(field.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      '${field.type}${field.required ? ' · required' : ''}${field.options != null ? ' · options: ${field.options!.join(', ')}' : ''}',
                      style: const TextStyle(fontSize: 12, color: RobocekColors.muted),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      onPressed: () => setState(() => _fields.removeAt(i)),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],

            // Add field card
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
        ),
      ),
    );
  }
}

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
