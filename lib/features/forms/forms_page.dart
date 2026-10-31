import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../models/custom_form.dart';
import '../../repositories/form_repository.dart';
import 'form_editor_page.dart';
import 'responses_page.dart';

class FormsPage extends StatefulWidget {
  const FormsPage({super.key});

  @override
  State<FormsPage> createState() => _FormsPageState();
}

class _FormsPageState extends State<FormsPage> {
  final _repo = FormRepository();
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _search = _searchController.text.toLowerCase()));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CustomForm> _filtered(List<CustomForm> all) {
    if (_search.isEmpty) return all;
    return all.where((f) =>
        f.title.toLowerCase().contains(_search) ||
        f.id.toLowerCase().contains(_search) ||
        f.description.toLowerCase().contains(_search)).toList();
  }

  void _openCreate() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FormEditorPage(repo: _repo)),
      );

  void _openEdit(CustomForm form) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FormEditorPage(repo: _repo, form: form)),
      );

  void _openResponses(CustomForm form) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResponsesPage(formId: form.id, title: form.title)),
      );

  Future<void> _delete(CustomForm form) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Form'),
        content: Text('Delete form "${form.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _repo.deleteForm(form.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Form deleted'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _copyLink(CustomForm form) {
    const baseUrl = 'https://robocek.org/forms/';
    Clipboard.setData(ClipboardData(text: '$baseUrl${form.id}'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $baseUrl${form.id}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreate,
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Form'),
      ),
      body: StreamBuilder<List<CustomForm>>(
        stream: _repo.watchAll(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final all = snap.data ?? [];
          final filtered = _filtered(all);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search forms…',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => _searchController.clear(),
                          )
                        : null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '${all.length} form${all.length != 1 ? 's' : ''}  •  ${all.where((f) => f.isActive).length} active',
                      style: const TextStyle(color: RobocekColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.assignment_outlined, size: 48, color: RobocekColors.muted),
                            SizedBox(height: 12),
                            Text('No forms yet', style: TextStyle(color: RobocekColors.muted)),
                            SizedBox(height: 4),
                            Text('Create a custom registration form', style: TextStyle(color: RobocekColors.muted, fontSize: 12)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) => _FormCard(
                          form: filtered[i],
                          onEdit: () => _openEdit(filtered[i]),
                          onDelete: () => _delete(filtered[i]),
                          onViewResponses: () => _openResponses(filtered[i]),
                          onCopyLink: () => _copyLink(filtered[i]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Form Card ────────────────────────────────────────────────────────────────

class _FormCard extends StatelessWidget {
  final CustomForm form;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onViewResponses;
  final VoidCallback onCopyLink;

  const _FormCard({
    required this.form,
    required this.onEdit,
    required this.onDelete,
    required this.onViewResponses,
    required this.onCopyLink,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = form.isActive;
    final statusColor = isActive ? RobocekColors.green : RobocekColors.muted;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: RobocekColors.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.assignment_rounded, color: RobocekColors.cyan, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(form.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(
                        'forms/${form.id}',
                        style: const TextStyle(color: RobocekColors.muted, fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit'))),
                    const PopupMenuItem(value: 'responses', child: ListTile(leading: Icon(Icons.list_alt_rounded), title: Text('View Responses'))),
                    const PopupMenuItem(value: 'copy', child: ListTile(leading: Icon(Icons.copy_rounded), title: Text('Copy Link'))),
                    const PopupMenuDivider(),
                    const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline, color: Colors.red), title: Text('Delete', style: TextStyle(color: Colors.red)))),
                  ],
                  onSelected: (val) {
                    switch (val) {
                      case 'edit': onEdit(); break;
                      case 'responses': onViewResponses(); break;
                      case 'copy': onCopyLink(); break;
                      case 'delete': onDelete(); break;
                    }
                  },
                ),
              ],
            ),
            if (form.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(form.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: RobocekColors.muted, fontSize: 13)),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _Badge(form.status, statusColor),
                _Badge('${form.fields.length} fields', RobocekColors.blue),
                if (form.isPaid) _Badge('Paid', RobocekColors.amber),
                if (form.isFreeForMembers) _Badge('Free for members', RobocekColors.green),
                if (form.maxResponses != null) _Badge('Max: ${form.maxResponses}', RobocekColors.muted),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewResponses,
                    icon: const Icon(Icons.list_alt_rounded, size: 16),
                    label: const Text('Responses'),
                    style: OutlinedButton.styleFrom(foregroundColor: RobocekColors.cyan),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onCopyLink,
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy Link'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
