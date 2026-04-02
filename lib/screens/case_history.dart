import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';

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
  final String type; // 'image' | 'voice' | 'document'
  final String label;
  final String size;

  const CaseMedia({
    required this.type,
    required this.label,
    required this.size,
  });
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
    // Note: Assuming NewCasePage exists in case_screens.dart or similar
    // For now, using a placeholder if not found.
    // await Navigator.push(context, MaterialPageRoute(builder: (_) => const NewCasePage()));
  }

  Future<void> _goToDetail(CaseModel c) async {
    // await Navigator.push(context, MaterialPageRoute(builder: (_) => CaseDetailPage(caseModel: c)));
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
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: Column(
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
            Expanded(
              child: _displayedCases.isEmpty
                  ? const Center(child: Text("No cases found", style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                itemCount: _displayedCases.length,
                itemBuilder: (ctx, idx) => _buildCaseCard(_displayedCases[idx]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseCard(CaseModel c) {
    return GestureDetector(
      onTap: () => _goToDetail(c),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(c.incidentNumber, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(c.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(c.status, style: TextStyle(color: _statusColor(c.status), fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(c.victimName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("${c.caseType} • ${c.date}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(c.location, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Minimal placeholders for navigation if missing
class NewCasePage extends StatelessWidget { const NewCasePage({super.key}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text("New Case"))); }
class CaseDetailPage extends StatelessWidget { final CaseModel caseModel; const CaseDetailPage({super.key, required this.caseModel}); @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(caseModel.incidentNumber))); }
