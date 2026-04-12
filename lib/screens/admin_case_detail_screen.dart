import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/case_history.dart';
import 'admin_case_chat_screen.dart';

/// Admin-only view of a case.
/// Allows admin to update status, assign an officer, and add internal notes.
/// All changes are written to Firestore and immediately reflected on the user side.
class AdminCaseDetailScreen extends StatefulWidget {
  final CaseModel caseModel;
  const AdminCaseDetailScreen({super.key, required this.caseModel});

  @override
  State<AdminCaseDetailScreen> createState() => _AdminCaseDetailScreenState();
}

class _AdminCaseDetailScreenState extends State<AdminCaseDetailScreen> {
  static const Color _bronze = Color(0xFFCD7F32);

  late String _selectedStatus;
  late TextEditingController _officerController;
  late TextEditingController _noteController;
  bool _isSaving = false;

  final List<String> _statusOptions = [
    'Open',
    'In Progress',
    'Pending',
    'Resolved',
    'Closed',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.caseModel.status.isNotEmpty
        ? widget.caseModel.status
        : 'Open';
    _officerController = TextEditingController(text: widget.caseModel.officer == 'Awaiting Assignment' ? '' : widget.caseModel.officer);
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _officerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (widget.caseModel.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Case ID is missing')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> updates = {
        'status': _selectedStatus,
        'officer': _officerController.text.trim().isEmpty
            ? 'Awaiting Assignment'
            : _officerController.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Append note to updates array if provided
      if (_noteController.text.trim().isNotEmpty) {
        final now = DateTime.now();
        final dateStr =
            '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
        updates['updates'] = FieldValue.arrayUnion([
          {
            'date': dateStr,
            'message': _noteController.text.trim(),
            'author': 'Renel Ghana Staff',
          }
        ]);
      }

      await FirebaseFirestore.instance
          .collection('cases')
          .doc(widget.caseModel.id!)
          .update(updates);

      if (mounted) {
        _noteController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Case updated — changes visible to user'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update case: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _sendChatMessage(String message) async {
    if (widget.caseModel.id == null || message.trim().isEmpty) return;
    await FirebaseFirestore.instance
        .collection('cases')
        .doc(widget.caseModel.id!)
        .collection('messages')
        .add({
      'text': message.trim(),
      'imageUrl': '',
      'senderRole': 'staff',
      'isMe': false, // false = admin/officer side
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'closed':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _bronze,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.caseModel.incidentNumber,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const Text('Admin Case Management',
                style: TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Case Summary Card ──
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(widget.caseModel.status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.caseModel.status.isEmpty ? 'Open' : widget.caseModel.status,
                          style: TextStyle(
                            color: _statusColor(widget.caseModel.status),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Priority: ${widget.caseModel.priorityLevel}',
                          style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _infoRow(Icons.person, 'Victim', widget.caseModel.victimName),
                  _infoRow(Icons.phone, 'Contact', widget.caseModel.victimPhone),
                  _infoRow(Icons.location_on, 'Location', widget.caseModel.location),
                  _infoRow(Icons.category, 'Type', widget.caseModel.caseType),
                  _infoRow(Icons.calendar_today, 'Incident Date', widget.caseModel.incidentDate),
                  const SizedBox(height: 8),
                  const Text('Description:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(widget.caseModel.description,
                      style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
                  if (widget.caseModel.immediateNeeds.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text('Immediate Needs:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: widget.caseModel.immediateNeeds
                          .map((n) => Chip(
                                label: Text(n, style: const TextStyle(fontSize: 11)),
                                backgroundColor: _bronze.withOpacity(0.1),
                                side: BorderSide(color: _bronze.withOpacity(0.3)),
                              ))
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Admin Actions ──
            _buildCard(
              title: 'Update Case',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Dropdown
                  DropdownButtonFormField<String>(
                    value: _statusOptions.contains(_selectedStatus) ? _selectedStatus : 'Open',
                    decoration: const InputDecoration(
                      labelText: 'Case Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: _statusOptions
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedStatus = v ?? _selectedStatus),
                  ),
                  const SizedBox(height: 12),

                  // Officer Assignment
                  TextField(
                    controller: _officerController,
                    decoration: const InputDecoration(
                      labelText: 'Assigned Officer (name or badge)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Internal Note
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Add Internal Note (optional)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(Icons.note_add),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Save Button
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveChanges,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.save_alt, size: 18),
                    label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _bronze,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Case Updates Log ──
            if (widget.caseModel.updates.isNotEmpty)
              _buildCard(
                title: 'Case Updates Log',
                child: Column(
                  children: widget.caseModel.updates.map((u) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.history, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(u.author,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600, fontSize: 12)),
                                    Text(u.date,
                                        style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(u.message, style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            // ── Quick Chat to Victim ──
            _buildCard(
              title: 'Send Message to Victim',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Send a message that will appear in the victim\'s case chat.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  _QuickMessagePanel(onSend: _sendChatMessage),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminCaseChatScreen(caseModel: widget.caseModel),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('View Full Chat History'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _bronze,
                      side: const BorderSide(color: _bronze),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({Widget? child, String? title}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFCD7F32))),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
            ],
            if (child != null) child,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFCD7F32)),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 13)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }
}

class _QuickMessagePanel extends StatefulWidget {
  final Future<void> Function(String) onSend;
  const _QuickMessagePanel({required this.onSend});

  @override
  State<_QuickMessagePanel> createState() => _QuickMessagePanelState();
}

class _QuickMessagePanelState extends State<_QuickMessagePanel> {
  final TextEditingController _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              hintText: 'Type a message...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: _sending
              ? null
              : () async {
                  if (_ctrl.text.trim().isEmpty) return;
                  setState(() => _sending = true);
                  await widget.onSend(_ctrl.text);
                  _ctrl.clear();
                  setState(() => _sending = false);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message sent to victim'), backgroundColor: Colors.green),
                    );
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFCD7F32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _sending
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.send, size: 18),
        ),
      ],
    );
  }
}
