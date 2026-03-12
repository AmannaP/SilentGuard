import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

class CaseUpdate {
  final String date;
  final String message;
  final String author;

  const CaseUpdate({
    required this.date,
    required this.message,
    required this.author,
  });
}

class CaseMedia {
  final String type;   // 'image' | 'voice' | 'document'
  final String label;
  final String size;

  const CaseMedia({required this.type, required this.label, required this.size});
}

class CaseModel {
  final String incidentNumber;
  final String date;
  final String caseType;
  String status;
  final String victimName;
  final int victimAge;
  final String location;
  final String description;
  final String officer;
  final List<CaseUpdate> updates;
  final List<CaseMedia> media;

  CaseModel({
    required this.incidentNumber,
    required this.date,
    required this.caseType,
    required this.status,
    required this.victimName,
    required this.victimAge,
    required this.location,
    required this.description,
    required this.officer,
    this.updates = const [],
    this.media = const [],
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// DUMMY DATABASE
// ─────────────────────────────────────────────────────────────────────────────

class CaseDatabase {
  static final CaseDatabase instance = CaseDatabase._internal();
  CaseDatabase._internal();

  final List<CaseModel> _cases = [
    CaseModel(
      incidentNumber: 'Incident No.1',
      date: '02/02/2026',
      caseType: 'Rape Case',
      status: 'Resolved',
      victimName: 'Abena Mensah',
      victimAge: 24,
      location: 'Accra, Greater Accra',
      description: 'Victim reported an assault at her residence. Case investigated and perpetrator apprehended.',
      officer: 'Sgt. Kofi Adu',
      updates: [
        CaseUpdate(date: '02/02/2026', message: 'Case opened. Initial report received.', author: 'System'),
        CaseUpdate(date: '05/02/2026', message: 'Officer assigned. Victim interviewed.', author: 'Sgt. Kofi Adu'),
        CaseUpdate(date: '12/02/2026', message: 'Suspect apprehended. Evidence collected.', author: 'Sgt. Kofi Adu'),
        CaseUpdate(date: '20/02/2026', message: 'Case resolved. Perpetrator charged.', author: 'Sgt. Kofi Adu'),
      ],
      media: [
        CaseMedia(type: 'image', label: 'Scene Photo 1.jpg', size: '2.1 MB'),
        CaseMedia(type: 'document', label: 'Medical Report.pdf', size: '540 KB'),
        CaseMedia(type: 'voice', label: 'Victim Statement.mp3', size: '3.4 MB'),
      ],
    ),
    CaseModel(
      incidentNumber: 'Incident No.2',
      date: '02/02/2026',
      caseType: 'Rape Case',
      status: 'Pending',
      victimName: 'Akosua Darko',
      victimAge: 19,
      location: 'Kumasi, Ashanti',
      description: 'Victim reported an incident near her school. Investigation ongoing.',
      officer: 'Sgt. Ama Boateng',
      updates: [
        CaseUpdate(date: '02/02/2026', message: 'Case opened. Awaiting officer assignment.', author: 'System'),
        CaseUpdate(date: '04/02/2026', message: 'Officer assigned. Scene visited.', author: 'Sgt. Ama Boateng'),
      ],
      media: [
        CaseMedia(type: 'voice', label: 'Voice Note.mp3', size: '1.8 MB'),
      ],
    ),
    CaseModel(
      incidentNumber: 'Incident No.3',
      date: '05/02/2026',
      caseType: 'Domestic Violence',
      status: 'Pending',
      victimName: 'Efua Asante',
      victimAge: 31,
      location: 'Takoradi, Western',
      description: 'Victim sustained injuries from a domestic dispute. Medical report filed.',
      officer: 'Cpl. Yaw Owusu',
      updates: [
        CaseUpdate(date: '05/02/2026', message: 'Case opened. Medical report attached.', author: 'System'),
      ],
      media: [
        CaseMedia(type: 'image', label: 'Injury Photo.jpg', size: '1.2 MB'),
        CaseMedia(type: 'document', label: 'Medical Report.pdf', size: '320 KB'),
      ],
    ),
    CaseModel(
      incidentNumber: 'Incident No.4',
      date: '08/02/2026',
      caseType: 'Sexual Harassment',
      status: 'Resolved',
      victimName: 'Adwoa Frimpong',
      victimAge: 27,
      location: 'Tamale, Northern',
      description: 'Workplace harassment complaint. Employer reprimanded and victim transferred to a safe unit.',
      officer: 'Insp. Kojo Mensah',
      updates: [
        CaseUpdate(date: '08/02/2026', message: 'Case opened.', author: 'System'),
        CaseUpdate(date: '10/02/2026', message: 'Workplace visited. Witnesses interviewed.', author: 'Insp. Kojo Mensah'),
        CaseUpdate(date: '15/02/2026', message: 'Case resolved. Employer issued formal warning.', author: 'Insp. Kojo Mensah'),
      ],
      media: [],
    ),
    CaseModel(
      incidentNumber: 'Incident No.5',
      date: '10/02/2026',
      caseType: 'Stalking',
      status: 'Pending',
      victimName: 'Serwa Quaye',
      victimAge: 22,
      location: 'Cape Coast, Central',
      description: 'Victim has been followed repeatedly. CCTV evidence collected.',
      officer: 'Sgt. Kofi Adu',
      updates: [
        CaseUpdate(date: '10/02/2026', message: 'Case opened. CCTV footage requested.', author: 'System'),
      ],
      media: [
        CaseMedia(type: 'image', label: 'CCTV Screenshot.jpg', size: '890 KB'),
      ],
    ),
  ];

  List<CaseModel> get allCases => List.unmodifiable(_cases);
  void addCase(CaseModel c) => _cases.add(c);

  List<CaseModel> search(String query) {
    final q = query.toLowerCase();
    return _cases.where((c) =>
    c.incidentNumber.toLowerCase().contains(q) ||
        c.caseType.toLowerCase().contains(q) ||
        c.status.toLowerCase().contains(q) ||
        c.victimName.toLowerCase().contains(q) ||
        c.location.toLowerCase().contains(q) ||
        c.officer.toLowerCase().contains(q) ||
        c.victimAge.toString().contains(q),
    ).toList();
  }
}

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
  final TextEditingController _searchController = TextEditingController();
  List<CaseModel> _displayedCases = [];

  @override
  void initState() {
    super.initState();
    _displayedCases = CaseDatabase.instance.allCases;
  }

  void _onSearchChanged(String query) {
    setState(() {
      _displayedCases = query.trim().isEmpty
          ? CaseDatabase.instance.allCases
          : CaseDatabase.instance.search(query);
    });
  }

  Future<void> _goToNewCase() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const NewCasePage()));
    setState(() {
      _displayedCases = _searchController.text.trim().isEmpty
          ? CaseDatabase.instance.allCases
          : CaseDatabase.instance.search(_searchController.text);
    });
  }

  Future<void> _goToDetail(CaseModel c) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => CaseDetailPage(caseModel: c)));
    setState(() {
      _displayedCases = _searchController.text.trim().isEmpty
          ? CaseDatabase.instance.allCases
          : CaseDatabase.instance.search(_searchController.text);
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved': return const Color(0xFF2ECC71);
      case 'pending':  return const Color(0xFFE67E22);
      case 'closed':   return const Color(0xFF95A5A6);
      default:         return const Color(0xFFABABAB);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bronze,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(width: double.infinity, height: 44, color: Colors.white),

                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                  child: Container(
                    height: 52,
                    decoration: ShapeDecoration(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      shadows: const [BoxShadow(color: Color(0x3FD8D0D0), blurRadius: 4, offset: Offset(0, 4))],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF181D27)),
                      decoration: InputDecoration(
                        hintText: 'Search name, type, status, age…',
                        hintStyle: const TextStyle(color: Color(0xFFCFC7C7), fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFFCFC7C7)),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, color: Color(0xFFCFC7C7), size: 18),
                          onPressed: () { _searchController.clear(); _onSearchChanged(''); },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_displayedCases.length} case(s) found',
                          style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      TextButton.icon(
                        onPressed: _goToNewCase,
                        icon: const Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
                        label: const Text('New Case', style: TextStyle(color: Colors.white, fontSize: 13)),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: _displayedCases.isEmpty
                      ? const Center(
                      child: Text('No cases match your search.',
                          style: TextStyle(color: Colors.white70, fontSize: 14)))
                      : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 104),
                    itemCount: _displayedCases.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final c = _displayedCases[i];
                      return GestureDetector(
                        onTap: () => _goToDetail(c),
                        child: _CaseCard(c: c, statusColor: _statusColor(c.status)),
                      );
                    },
                  ),
                ),
              ],
            ),

            Positioned(
              left: 20, right: 20, bottom: 16,
              child: Container(
                height: 72,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  shadows: const [BoxShadow(color: Color(0x3F000000), blurRadius: 8, offset: Offset(0, 4))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _NavBarItem(label: 'Home',    isActive: false),
                    _NavBarItem(label: 'History', isActive: true),
                    _NavBarItem(label: 'Archive', isActive: false),
                    _NavBarItem(label: 'Profile', isActive: false),
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

// ─────────────────────────────────────────────────────────────────────────────
// CASE DETAIL PAGE
// ─────────────────────────────────────────────────────────────────────────────

class CaseDetailPage extends StatelessWidget {
  final CaseModel caseModel;
  const CaseDetailPage({super.key, required this.caseModel});

  static const Color _bronze = Color(0xFFCD7F32);

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'resolved': return const Color(0xFF2ECC71);
      case 'pending':  return const Color(0xFFE67E22);
      case 'closed':   return const Color(0xFF95A5A6);
      default:         return const Color(0xFFABABAB);
    }
  }

  IconData _mediaIcon(String type) {
    switch (type) {
      case 'image':    return Icons.image_outlined;
      case 'voice':    return Icons.mic_outlined;
      case 'document': return Icons.description_outlined;
      default:         return Icons.attach_file;
    }
  }

  Color _mediaColor(String type) {
    switch (type) {
      case 'image':    return const Color(0xFF3498DB);
      case 'voice':    return const Color(0xFFE67E22);
      case 'document': return const Color(0xFF9B59B6);
      default:         return const Color(0xFFABABAB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(caseModel.status);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Bronze header ──────────────────────────────────────
            Container(
              color: _bronze,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(caseModel.incidentNumber,
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withOpacity(0.5)),
                        ),
                        child: Text(caseModel.status,
                            style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(caseModel.caseType,
                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white54, size: 13),
                      const SizedBox(width: 4),
                      Text(caseModel.date, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on_outlined, color: Colors.white54, size: 13),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(caseModel.location,
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Scrollable body ────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // Victim info card
                    _sectionCard(
                      title: 'Victim Information',
                      icon: Icons.person_outline,
                      child: Column(
                        children: [
                          _infoRow('Name',    caseModel.victimName),
                          _infoRow('Age',     '${caseModel.victimAge} years'),
                          _infoRow('Location', caseModel.location),
                          _infoRow('Officer',  caseModel.officer),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Description card
                    _sectionCard(
                      title: 'Incident Description',
                      icon: Icons.notes_outlined,
                      child: Text(caseModel.description,
                          style: const TextStyle(color: Color(0xFF4A4A4A), fontSize: 13, height: 1.6)),
                    ),
                    const SizedBox(height: 16),

                    // Media card
                    _sectionCard(
                      title: 'Uploaded Evidence',
                      icon: Icons.attach_file_outlined,
                      trailing: Text('${caseModel.media.length} file(s)',
                          style: const TextStyle(color: Color(0xFFABABAB), fontSize: 12)),
                      child: caseModel.media.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text('No files uploaded.',
                            style: TextStyle(color: Color(0xFFABABAB), fontSize: 13)),
                      )
                          : Column(
                        children: caseModel.media.map((m) => _mediaRow(m)).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Updates / Timeline card
                    _sectionCard(
                      title: 'Case Updates',
                      icon: Icons.timeline_outlined,
                      child: Column(
                        children: List.generate(caseModel.updates.length, (i) {
                          final u = caseModel.updates[i];
                          final isLast = i == caseModel.updates.length - 1;
                          return _timelineItem(u, isLast: isLast);
                        }),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 8, offset: Offset(0, 2))],
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: _bronze.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _bronze, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: const TextStyle(color: Color(0xFF181D27), fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(color: Color(0xFFABABAB), fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Color(0xFF181D27), fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _mediaRow(CaseMedia m) {
    final color = _mediaColor(m.type);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_mediaIcon(m.type), color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.label,
                    style: const TextStyle(color: Color(0xFF181D27), fontSize: 13, fontWeight: FontWeight.w500)),
                Text(m.size, style: const TextStyle(color: Color(0xFFABABAB), fontSize: 11)),
              ],
            ),
          ),
          Icon(Icons.download_outlined, color: _bronze, size: 20),
        ],
      ),
    );
  }

  Widget _timelineItem(CaseUpdate u, {required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: _bronze,
                shape: BoxShape.circle,
                border: Border.all(color: _bronze.withOpacity(0.3), width: 3),
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 48, color: const Color(0xFFE8E8E8)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.message,
                    style: const TextStyle(color: Color(0xFF181D27), fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(u.date, style: const TextStyle(color: Color(0xFFABABAB), fontSize: 11)),
                    const SizedBox(width: 8),
                    Text('• ${u.author}', style: const TextStyle(color: Color(0xFFABABAB), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NEW CASE PAGE  (user view — no officer / status)
// ─────────────────────────────────────────────────────────────────────────────

class NewCasePage extends StatefulWidget {
  const NewCasePage({super.key});
  @override
  State<NewCasePage> createState() => _NewCasePageState();
}

class _NewCasePageState extends State<NewCasePage> {
  static const Color _bronze = Color(0xFFCD7F32);
  final _formKey = GlobalKey<FormState>();

  final _victimNameCtrl  = TextEditingController();
  final _victimAgeCtrl   = TextEditingController();
  final _locationCtrl    = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String _caseType = 'Rape Case';
  final List<String> _caseTypes = [
    'Rape Case', 'Domestic Violence', 'Sexual Harassment',
    'Stalking', 'Child Abuse', 'Other',
  ];

  // Dummy uploaded files list (label + type)
  final List<CaseMedia> _uploadedMedia = [];

  void _pickMedia(String type) {
    // In production replace with file_picker / image_picker
    final labels = {
      'image':    'Photo_${_uploadedMedia.length + 1}.jpg',
      'voice':    'VoiceNote_${_uploadedMedia.length + 1}.mp3',
      'document': 'Document_${_uploadedMedia.length + 1}.pdf',
    };
    setState(() {
      _uploadedMedia.add(CaseMedia(
        type: type,
        label: labels[type]!,
        size: '—',
      ));
    });
  }

  void _removeMedia(int index) => setState(() => _uploadedMedia.removeAt(index));

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final count = CaseDatabase.instance.allCases.length + 1;
    final now   = DateTime.now();
    final date  = '${now.day.toString().padLeft(2,'0')}/${now.month.toString().padLeft(2,'0')}/${now.year}';

    CaseDatabase.instance.addCase(CaseModel(
      incidentNumber: 'Incident No.$count',
      date: date,
      caseType: _caseType,
      status: 'Pending',
      victimName: _victimNameCtrl.text.trim(),
      victimAge: int.tryParse(_victimAgeCtrl.text.trim()) ?? 0,
      location: _locationCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      officer: 'Unassigned',
      updates: [
        CaseUpdate(date: date, message: 'Case submitted by user.', author: 'System'),
      ],
      media: List.from(_uploadedMedia),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Case submitted successfully!'), backgroundColor: Color(0xFF2ECC71)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bronze,
      appBar: AppBar(
        backgroundColor: _bronze,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Report a Case',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Victim info ───────────────────────────────────
                _sectionLabel('Your Information'),
                const SizedBox(height: 10),
                _field('Full Name', _victimNameCtrl, hint: 'Your full name',
                    validator: (v) => v!.trim().isEmpty ? 'Required' : null),
                _field('Age', _victimAgeCtrl, hint: 'Your age',
                    keyboard: TextInputType.number,
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'Required';
                      if (int.tryParse(v.trim()) == null) return 'Numbers only';
                      return null;
                    }),
                _field('Location', _locationCtrl, hint: 'City, Region',
                    validator: (v) => v!.trim().isEmpty ? 'Required' : null),

                const SizedBox(height: 16),

                // ── Incident info ─────────────────────────────────
                _sectionLabel('Incident Details'),
                const SizedBox(height: 10),
                _dropdown('Incident Type', _caseTypes, _caseType,
                        (v) => setState(() => _caseType = v!)),
                _field('Description', _descriptionCtrl,
                    hint: 'Describe what happened in as much detail as you feel comfortable sharing…',
                    maxLines: 5,
                    validator: (v) => v!.trim().isEmpty ? 'Required' : null),

                const SizedBox(height: 16),

                // ── Media upload ──────────────────────────────────
                _sectionLabel('Upload Evidence  (optional)'),
                const SizedBox(height: 6),
                const Text(
                  'You can attach photos, voice notes, or documents to support your report.',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 14),

                // Upload buttons row
                Row(
                  children: [
                    _uploadBtn(Icons.image_outlined,       'Photo',    () => _pickMedia('image')),
                    const SizedBox(width: 10),
                    _uploadBtn(Icons.mic_outlined,         'Voice',    () => _pickMedia('voice')),
                    const SizedBox(width: 10),
                    _uploadBtn(Icons.description_outlined, 'Document', () => _pickMedia('document')),
                  ],
                ),

                // Uploaded files list
                if (_uploadedMedia.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: List.generate(_uploadedMedia.length, (i) {
                        final m = _uploadedMedia[i];
                        return ListTile(
                          dense: true,
                          leading: Icon(_mediaIcon(m.type), color: Colors.white70, size: 20),
                          title: Text(m.label,
                              style: const TextStyle(color: Colors.white, fontSize: 13)),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                            onPressed: () => _removeMedia(i),
                          ),
                        );
                      }),
                    ),
                  ),
                ],

                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _bronze,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    child: const Text('Submit Report',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _mediaIcon(String type) {
    switch (type) {
      case 'image':    return Icons.image_outlined;
      case 'voice':    return Icons.mic_outlined;
      case 'document': return Icons.description_outlined;
      default:         return Icons.attach_file;
    }
  }

  Widget _uploadBtn(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white30),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(text,
      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold));

  Widget _field(String label, TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboard,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Color(0xFF181D27)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCFC7C7), fontSize: 13),
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(color: Colors.yellowAccent, fontSize: 11),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }

  Widget _dropdown(String label, List<String> items, String value, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: Color(0xFF181D27)),
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CASE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _CaseCard extends StatelessWidget {
  final CaseModel c;
  final Color statusColor;
  const _CaseCard({required this.c, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadows: const [BoxShadow(color: Color(0x1A000000), blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: const ShapeDecoration(color: Color(0x0D0600B3), shape: OvalBorder()),
            child: const Icon(Icons.folder_outlined, color: Color(0xFF0600B3), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(c.incidentNumber,
                        style: const TextStyle(color: Color(0xFF181D27), fontSize: 13, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(c.status,
                          style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(c.date, style: const TextStyle(color: Color(0xFFABABAB), fontSize: 11)),
                const SizedBox(height: 5),
                Text(c.caseType,
                    style: const TextStyle(color: Color(0xFF181D27), fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('${c.victimName} · Age ${c.victimAge} · ${c.location}',
                    style: const TextStyle(color: Color(0xFFABABAB), fontSize: 11),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: Color(0xFFABABAB), size: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAV BAR ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _NavBarItem extends StatelessWidget {
  final String label;
  final bool isActive;
  const _NavBarItem({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color  = isActive ? const Color(0xFFFF8852) : const Color(0xFF313A51);
    final weight = isActive ? FontWeight.w600 : FontWeight.w500;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(_icon(label), color: color, size: 22),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: weight)),
      ],
    );
  }

  IconData _icon(String l) {
    switch (l) {
      case 'Home':    return Icons.home_outlined;
      case 'History': return Icons.history;
      case 'Archive': return Icons.archive_outlined;
      case 'Profile': return Icons.person_outline;
      default:        return Icons.circle;
    }
  }
}