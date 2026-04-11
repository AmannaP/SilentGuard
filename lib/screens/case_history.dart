import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../services/case_history.dart'; 
import 'case_screens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CASE HISTORY SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class CaseHistory extends StatefulWidget {
  const CaseHistory({super.key});
  @override
  State<CaseHistory> createState() => _CaseHistoryState();
}

class _CaseHistoryState extends State<CaseHistory> {
  static const Color _bronze = Color(0xFFCD7F32);
  final CaseService _service = CaseService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<CaseModel> _filter(List<CaseModel> all) {
    final q = _searchQuery.toLowerCase().trim();
    if (q.isEmpty) return all;
    return all
        .where((c) =>
            c.incidentNumber.toLowerCase().contains(q) ||
            c.caseType.toLowerCase().contains(q) ||
            c.status.toLowerCase().contains(q) ||
            c.location.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bronze,
      resizeToAvoidBottomInset: false, // Prevents navbar overflow when keyboard opens
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar matching original design
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
              child: Container(
                height: 52,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Color(0x3FD8D0D0),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF181D27),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search name, type, status, location…',
                    hintStyle: const TextStyle(
                      color: Color(0xFFCFC7C7),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFCFC7C7),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Color(0xFFCFC7C7),
                              size: 18,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Live List of Cases
            Expanded(
              child: StreamBuilder<List<CaseModel>>(
                stream: _service.getCasesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Connectivity Error. Please check wifi.', style: TextStyle(color: Colors.white)));
                  }
                  final cases = _filter(snapshot.data ?? []);
                  if (cases.isEmpty) {
                    return const Center(
                      child: Text('No cases found', style: TextStyle(color: Colors.white, fontSize: 16)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: cases.length,
                    itemBuilder: (_, i) => _buildCaseCard(cases[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: _bronze,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const NewCasePage()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'closed':
        return const Color(0xFF2ECC71);
      case 'pending':
      case 'open':
        return const Color(0xFFE67E22);
      default:
        return const Color(0xFFABABAB);
    }
  }

  Widget _buildCaseCard(CaseModel c) {
    final statusColor = _statusColor(c.status);
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => CaseDetailsPage(caseModel: c)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          shadows: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const ShapeDecoration(
                color: Color(0x0D0600B3),
                shape: OvalBorder(),
              ),
              child: const Icon(
                Icons.folder_outlined,
                color: Color(0xFF0600B3),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        c.incidentNumber,
                        style: const TextStyle(
                          color: Color(0xFF181D27),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          c.status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${c.date} • ${c.time}',
                    style: const TextStyle(
                      color: Color(0xFFABABAB),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    c.caseType,
                    style: const TextStyle(
                      color: Color(0xFF181D27),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${c.victimName} · Priority: ${c.priorityLevel} · ${c.location}',
                    style: const TextStyle(
                      color: Color(0xFFABABAB),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Color(0xFFABABAB), size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CASE DETAILS PAGE (Standardized)
// ─────────────────────────────────────────────────────────────────────────────

class CaseDetailsPage extends StatelessWidget {
  final CaseModel caseModel;
  const CaseDetailsPage({super.key, required this.caseModel});

  void _viewImage(BuildContext context, String path) {
    if (path.isEmpty || !File(path).existsSync()) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(path), fit: BoxFit.contain),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(ctx),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Case Details', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFCD7F32), // Bronze
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFCD7F32),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.chat),
        label: const Text('Chat with Officer'),
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/chat_provider',
            arguments: {
              'uid': caseModel.officer.isNotEmpty && caseModel.officer != 'Awaiting Assignment' ? caseModel.officer : 'renel_ghana_default',
              'name': caseModel.officer.isNotEmpty && caseModel.officer != 'Awaiting Assignment' ? caseModel.officer : 'Renel Ghana (Default)',
              'phone': 'N/A',
            }
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildSectionTitle('Case # ${caseModel.incidentNumber}'),
            _buildDetailText('Status', '🟠 ${caseModel.status}'),
            _buildDetailText('System Date', '${caseModel.date} • ${caseModel.time}'),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Section 1: Client Information
            _buildSectionTitle('Client Information'),
            _buildDetailText('Full Name', caseModel.victimName),
            _buildDetailText('Age / DOB', caseModel.victimDob),
            _buildDetailText('Gender', caseModel.victimGender),
            _buildDetailText('Contact Number', caseModel.victimPhone),
            _buildDetailText('Address', caseModel.location),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Section 2: Incident Details
            _buildSectionTitle('Incident Details'),
            _buildDetailText('Type of GBV', caseModel.caseType),
            _buildDetailText('Incident Date', caseModel.incidentDate),
            const SizedBox(height: 8),
            const Text('Description:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              caseModel.description,
              style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Section 3: Immediate Needs
            _buildSectionTitle('Immediate Needs Request'),
            if (caseModel.immediateNeeds.isEmpty) 
               const Text('None selected.', style: TextStyle(color: Colors.grey)),
            ...caseModel.immediateNeeds.map((n) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Color(0xFFCD7F32)),
                  const SizedBox(width: 8),
                  Text(n, style: const TextStyle(fontSize: 15)),
                ],
              ),
            )),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Evidence Upload Section
            _buildSectionTitle('Evidence (${caseModel.media.length})'),
            if (caseModel.media.isEmpty) const Text('No evidence uploaded yet.', style: TextStyle(color: Colors.grey)),
            ...caseModel.media.map((m) => InkWell(
                  onTap: (m.type == 'image' && m.path.isNotEmpty) ? () => _viewImage(context, m.path) : null,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      children: [
                        (m.type == 'image' && m.path.isNotEmpty && File(m.path).existsSync())
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(File(m.path), width: 44, height: 44, fit: BoxFit.cover),
                            )
                          : Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                              child: Icon(m.type == 'image' ? Icons.camera_alt : m.type == 'voice' ? Icons.mic : Icons.insert_drive_file, color: Colors.grey),
                            ),
                        const SizedBox(width: 12),
                        Text('${m.label} • ${m.size}', style: const TextStyle(fontSize: 16)),
                        if (m.type == 'image' && m.path.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.open_in_new, size: 14, color: Colors.grey),
                          )
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Section 4: System Assigned Information
            _buildSectionTitle('System Assigned Information'),
            _buildDetailText('Case ID', caseModel.incidentNumber),
            _buildDetailText('Priority Level', caseModel.priorityLevel),
            _buildDetailText('Assigned Officer', caseModel.officer.isEmpty ? 'Awaiting Assignment' : caseModel.officer),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _buildDetailText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black, height: 1.4),
          children: [
            TextSpan(text: '$label:  ', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW CASE FORM PAGE (GBV Case Intake Form)
// ─────────────────────────────────────────────────────────────────────────────

class NewCasePage extends StatefulWidget {
  const NewCasePage({super.key});
  @override
  State<NewCasePage> createState() => _NewCasePageState();
}

class _NewCasePageState extends State<NewCasePage> {
  final CaseService _service = CaseService();
  final _formKey = GlobalKey<FormState>();

  // Form State
  String _victimName = '';
  String _victimDob = '';
  String _victimGender = 'Female';
  String _victimPhone = '';
  String _location = '';

  String _caseType = 'Physical';
  String _otherCaseType = ''; // Used if "Other" is selected
  String _incidentDate = '';
  String _description = '';

  final Map<String, bool> _immediateNeeds = {
    'Medical Support': false,
    'Legal Support': false,
    'Shelter Support': false,
    'Psychosocial Support': false,
  };

  // Uploaded media files
  final List<CaseMedia> _uploadedMedia = [];

  bool _isLoading = false;

  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _incidentDateController = TextEditingController();

  Future<void> _pickDate(bool isDob) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFCD7F32), // Bronze headers
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      setState(() {
        if (isDob) {
          _victimDob = formatted;
          _dobController.text = formatted;
        } else {
          _incidentDate = formatted;
          _incidentDateController.text = formatted;
        }
      });
    }
  }

  void _showConfirmationModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Submission Successful', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Your case has been submitted successfully.\n\nYour assigned officer will contact you soon.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFCD7F32)),
            onPressed: () {
              Navigator.pop(ctx); // Dismiss modal
              Navigator.pop(context); // Go back to history
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    setState(() => _isLoading = true);
    
    try {
      final now = DateTime.now();
      
      // Auto-assigners
      final generatedId = 'SG-${now.year}-${now.millisecondsSinceEpoch.toString().substring(8, 12)}';
      const autoPriority = 'High'; // Can be logic based later
      final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      
      final needs = _immediateNeeds.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      final actualCaseType = _caseType == 'Other' && _otherCaseType.isNotEmpty 
          ? 'Other: $_otherCaseType' 
          : _caseType;

      final newCase = CaseModel(
        incidentNumber: generatedId,
        priorityLevel: autoPriority,
        date: dateStr,
        time: timeStr,
        status: 'Open',
        officer: 'Awaiting Assignment',
        
        victimName: _victimName,
        victimDob: _victimDob,
        victimGender: _victimGender,
        victimPhone: _victimPhone,
        location: _location,
        
        incidentDate: _incidentDate,
        caseType: actualCaseType,
        description: _description,
        immediateNeeds: needs,
        media: _uploadedMedia,
      );

      await _service.createCase(newCase);
      
      if (mounted) {
        _showConfirmationModal();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
      }
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFCD7F32)),
      ),
    );
  }

  @override
  void dispose() {
    _dobController.dispose();
    _incidentDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('GBV Case Intake Form', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFCD7F32), // Bronze
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFCD7F32)))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  // ── SECTION 1: Client Information ──
                  _buildSectionHeader('Section 1: Client Information'),
                  
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Please enter a name' : null,
                    onSaved: (v) => _victimName = v!,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => _pickDate(true),
                    decoration: const InputDecoration(
                      labelText: 'Age / Date of Birth *', 
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today)
                    ),
                    validator: (v) => v!.isEmpty ? 'Please select a date' : null,
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Gender *', border: OutlineInputBorder()),
                    initialValue: _victimGender,
                    items: ['Female', 'Male', 'Other', 'Prefer not to say']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _victimGender = v!),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Contact Number *', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Please enter contact number' : null,
                    onSaved: (v) => _victimPhone = v!,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Address / Location *', border: OutlineInputBorder(), hintText: 'Current location or address'),
                    validator: (v) => v!.isEmpty ? 'Please enter location' : null,
                    onSaved: (v) => _location = v!,
                  ),
                  
                  const Divider(height: 48),

                  // ── SECTION 2: Incident Details ──
                  _buildSectionHeader('Section 2: Incident Details'),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Type of GBV Experienced *', border: OutlineInputBorder()),
                    initialValue: _caseType,
                    items: ['Physical', 'Sexual', 'Emotional', 'Economic', 'Other']
                        .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _caseType = v!),
                  ),
                  if (_caseType == 'Other') ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Please specify *', border: OutlineInputBorder()),
                      validator: (v) => _caseType == 'Other' && v!.isEmpty ? 'Required' : null,
                      onSaved: (v) => _otherCaseType = v!,
                    ),
                  ],
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _incidentDateController,
                    readOnly: true,
                    onTap: () => _pickDate(false),
                    decoration: const InputDecoration(
                      labelText: 'Date of Incident *', 
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today)
                    ),
                    validator: (v) => v!.isEmpty ? 'Please select incident date' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Brief Description of Incident *', 
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true
                    ),
                    maxLines: 4,
                    validator: (v) => v!.isEmpty ? 'Please describe the incident' : null,
                    onSaved: (v) => _description = v!,
                  ),

                  const Divider(height: 48),

                  // ── EVIDENCE UPLOAD ──
                  _buildSectionHeader('Evidence / Media (Optional)'),
                  const Text('Upload photos, videos, audio, or documents related to the incident.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFCD7F32)),
                    ),
                    onPressed: () async {
                      try {
                        FilePickerResult? result = await FilePicker.pickFiles(
                          allowMultiple: true,
                        );
                        if (result != null && mounted) {
                          setState(() {
                            for (var file in result.files) {
                              final double mbBytes = file.size / (1024 * 1024);
                              final ext = file.extension?.toLowerCase() ?? '';
                              String type = 'document';
                              if (['jpg', 'jpeg', 'png', 'gif'].contains(ext)) type = 'image';
                              if (['mp3', 'wav', 'm4a'].contains(ext)) type = 'voice';
                              if (['mp4', 'mov', 'avi'].contains(ext)) type = 'video';
                              
                              _uploadedMedia.add(CaseMedia(
                                type: type, 
                                label: file.name, 
                                size: '${mbBytes.toStringAsFixed(1)} MB',
                                path: file.path ?? '',
                              ));
                            }
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${result.files.length} file(s) attached!')));
                        }
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
                      }
                    },
                    icon: const Icon(Icons.upload_file, color: Color(0xFFCD7F32)),
                    label: const Text('Pick Evidence Files', style: TextStyle(color: Colors.black87, fontSize: 16)),
                  ),
                  if (_uploadedMedia.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ..._uploadedMedia.map((m) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: (m.type == 'image' && m.path.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(File(m.path), width: 44, height: 44, fit: BoxFit.cover),
                            )
                          : Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                              child: Icon(m.type == 'voice' ? Icons.mic : m.type == 'video' ? Icons.videocam : Icons.insert_drive_file, color: Colors.grey),
                            ),
                      title: Text(m.label),
                      subtitle: Text(m.size),
                      trailing: IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                        onPressed: () => setState(() => _uploadedMedia.remove(m)),
                      ),
                    )),
                  ],

                  const Divider(height: 48),

                  // ── SECTION 3: Immediate Needs ──
                  _buildSectionHeader('Section 3: Immediate Needs (Optional)'),
                  
                  ..._immediateNeeds.keys.map((key) => CheckboxListTile(
                    title: Text(key),
                    value: _immediateNeeds[key],
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFCD7F32),
                    onChanged: (bool? val) {
                      setState(() {
                         _immediateNeeds[key] = val ?? false;
                      });
                    },
                  )),

                  const SizedBox(height: 48),

                  // ── SECTION 5: Submission ──
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCD7F32), // Bronze
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _submit,
                    child: const Text('SUBMIT CASE', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
    );
  }
}
