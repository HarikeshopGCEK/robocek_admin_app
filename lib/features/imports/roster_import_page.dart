import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../repositories/member_repository.dart';

/// Roster Import page
/// Note: Full Excel file import requires the 'excel' or 'spreadsheet_decoder' package.
/// This page provides a manual bulk-import UI where admins can paste CSV data.
class RosterImportPage extends StatefulWidget {
  const RosterImportPage({super.key});

  @override
  State<RosterImportPage> createState() => _RosterImportPageState();
}

class _RosterImportPageState extends State<RosterImportPage> {
  final _repo = MemberRepository();
  final _csvController = TextEditingController();
  List<Map<String, String>> _parsedRows = [];
  bool _importing = false;
  String? _parseError;

  @override
  void dispose() {
    _csvController.dispose();
    super.dispose();
  }

  // Parse CSV text → list of maps
  void _parseCsv() {
    setState(() {
      _parseError = null;
      _parsedRows = [];
    });

    final text = _csvController.text.trim();
    if (text.isEmpty) {
      setState(() => _parseError = 'Please paste some CSV data first.');
      return;
    }

    try {
      final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
      if (lines.length < 2) {
        setState(() => _parseError = 'Need at least a header row and one data row.');
        return;
      }

      final headers = _splitCsvLine(lines.first);
      final rows = <Map<String, String>>[];

      for (int i = 1; i < lines.length; i++) {
        final values = _splitCsvLine(lines[i]);
        final row = <String, String>{};
        for (int j = 0; j < headers.length; j++) {
          row[headers[j]] = j < values.length ? values[j] : '';
        }
        rows.add(row);
      }

      setState(() {
        _parsedRows = rows;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loaded ${rows.length} records from CSV'),
          backgroundColor: RobocekColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() => _parseError = 'Failed to parse CSV: $e');
    }
  }

  List<String> _splitCsvLine(String line) {
    final result = <String>[];
    bool inQuotes = false;
    final current = StringBuffer();

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString().trim());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString().trim());
    return result;
  }

  Future<void> _import() async {
    if (_parsedRows.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Roster'),
        content: Text(
          'Import ${_parsedRows.length} members to Firestore?\n\n'
          '• All members will be marked as "Approved"\n'
          '• Membership IDs will be auto-generated\n'
          '• Default password: Robocek\@2026',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _importing = true);

    try {
      // Normalize column names to standard field names
      final normalized = _parsedRows.map(_normalizeRow).toList();
      await _repo.batchImport(normalized);

      if (mounted) {
        setState(() {
          _parsedRows = [];
          _csvController.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported ${normalized.length} members successfully!'),
            backgroundColor: RobocekColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Map<String, dynamic> _normalizeRow(Map<String, String> row) {
    String get(List<String> keys) {
      for (final k in keys) {
        final normalized = k.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
        for (final entry in row.entries) {
          final entryKey = entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
          if (entryKey == normalized && entry.value.isNotEmpty) {
            return entry.value;
          }
        }
      }
      return '';
    }

    final fullName = get(['fullname', 'name', 'fullName']) == ''
        ? 'Member'
        : get(['fullname', 'name', 'fullName']);
    final email = get(['email']);
    final phone = get(['phone', 'mobile', 'phonenumber']);
    final branch = get(['branch']);
    final year = get(['year', 'batch', 'yearsemester', 'batchyear']);

    return {
      ...row.map((k, v) => MapEntry(k, v as dynamic)),
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'phoneNumber': phone,
      'branch': branch,
      'year': year,
      'yearSemester': year,
    };
  }

  void _clearAll() {
    setState(() {
      _parsedRows = [];
      _csvController.clear();
      _parseError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: RobocekColors.blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: RobocekColors.blue.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: RobocekColors.cyan, size: 20),
                      SizedBox(width: 8),
                      Text('CSV Roster Import', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: RobocekColors.cyan)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Paste CSV data below with headers. Recognized columns:\n'
                    '• Full Name / Name\n'
                    '• Email\n'
                    '• Phone / Mobile\n'
                    '• Branch\n'
                    '• Year / Batch / Year Semester\n\n'
                    'All imported members will be auto-approved with Membership IDs.',
                    style: TextStyle(color: RobocekColors.muted, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // CSV Paste Area
            const Text(
              'PASTE CSV DATA',
              style: TextStyle(color: RobocekColors.muted, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _csvController,
              maxLines: 10,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              decoration: const InputDecoration(
                hintText: 'Full Name,Email,Phone,Branch,Year\nJohn Doe,john@example.com,9876543210,CSE,S4',
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
              ),
            ),

            if (_parseError != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_parseError!, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _parseCsv,
                    icon: const Icon(Icons.table_rows_rounded),
                    label: const Text('Parse CSV'),
                  ),
                ),
                if (_parsedRows.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: _clearAll,
                    child: const Text('Clear'),
                  ),
                ],
              ],
            ),

            // Preview Table
            if (_parsedRows.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_parsedRows.length} records ready to import',
                    style: const TextStyle(color: RobocekColors.cyan, fontWeight: FontWeight.w700),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: RobocekColors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Preview', style: TextStyle(color: RobocekColors.green, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Show first 5 rows
              ...(_parsedRows.take(5).toList().asMap().entries.map((entry) {
                final i = entry.key;
                final row = entry.value;
                final nameKey = row.keys.firstWhere(
                    (k) => ['fullname', 'name', 'fullName'].any((n) => k.toLowerCase() == n),
                    orElse: () => row.keys.first);
                final emailKey = row.keys.firstWhere(
                    (k) => k.toLowerCase() == 'email',
                    orElse: () => '');
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: RobocekColors.blue.withValues(alpha: 0.2),
                          child: Text('${i + 1}', style: const TextStyle(color: RobocekColors.cyan, fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(row[nameKey] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              if (emailKey.isNotEmpty && row[emailKey]?.isNotEmpty == true)
                                Text(row[emailKey]!, style: const TextStyle(color: RobocekColors.muted, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              })),
              if (_parsedRows.length > 5)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '… and ${_parsedRows.length - 5} more records',
                    style: const TextStyle(color: RobocekColors.muted, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: _importing ? null : _import,
                  icon: _importing
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.upload_rounded),
                  label: Text(_importing ? 'Importing…' : 'Import ${_parsedRows.length} Members to Firestore'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
